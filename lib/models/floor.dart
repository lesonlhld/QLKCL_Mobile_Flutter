// To parse this JSON data, do
//
//     final floor = floorFromJson(jsonString);

import 'dart:convert';

import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/api.dart';

Floor floorFromJson(String str) => Floor.fromJson(json.decode(str));

String floorToJson(Floor data) => json.encode(data.toJson());

class Floor {
  Floor({
    required this.id,
    required this.name,
    required this.quarantineBuilding,
    required this.numCurrentMember,
    this.totalCapacity,
  });

  final int id;
  final String name;
  final dynamic quarantineBuilding;
  final int numCurrentMember;
  final int? totalCapacity;

  factory Floor.fromJson(Map<String, dynamic> json) => Floor(
        id: json["id"],
        name: json["name"],
        quarantineBuilding: json["quarantine_building"],
        numCurrentMember: json["num_current_member"],
        totalCapacity: json["total_capacity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "quarantine_building": quarantineBuilding,
        "num_current_member": numCurrentMember,
        "total_capacity": totalCapacity,
      };
}

Future<dynamic> fetchFloor({id}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.getHTTP('${Api.getFloor}?id=$id');
  return response["data"];
}

Future<Response> createFloor(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.createFloor, data);
  if (response == null) {
    return Response(status: Status.error, message: "Lỗi kết nối!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "Tạo tầng thành công!",
          data: response['data']);
    } else if (response['error_code'] == 400) {
      if (response['message']['name'] != null &&
          response['message']['name'] == "Exist") {
        return Response(status: Status.error, message: 'Tên tầng đã tồn tại!');
      } else {
        return Response(status: Status.error, message: "Có lỗi xảy ra!");
      }
    } else {
      return Response(status: Status.error, message: "Có lỗi xảy ra!");
    }
  }
}

Future<dynamic> fetchFloorList(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.getListFloor, data);
  return response != null && response['data'] != null
      ? response['data']['content']
      : null;
}

Future<int> fetchNumOfFloor(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.getListFloor, data);
  return response != null && response['data'] != null
      ? response['data']['totalRows']
      : null;
}

Future<Response> updateFloor(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.updateFloor, data);
  if (response == null) {
    return Response(status: Status.error, message: "Lỗi kết nối!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "Cập nhật thông tin thành công!",
          data: Floor.fromJson(response['data']));
    } else if (response['error_code'] == 400) {
      if (response['message']['name'] != null &&
          response['message']['name'] == "Exist") {
        return Response(status: Status.error, message: 'Tên tầng đã tồn tại!');
      } else {
        return Response(status: Status.error, message: "Có lỗi xảy ra!");
      }
    } else if (response['error_code'] == 401) {
      if (response['message'] != null &&
          response['message'] == "Permission denied") {
        return Response(
            status: Status.error,
            message: 'Không có quyền thực hiện chức năng này!');
      } else {
        return Response(status: Status.error, message: "Có lỗi xảy ra!");
      }
    } else {
      return Response(status: Status.error, message: "Có lỗi xảy ra!");
    }
  }
}
