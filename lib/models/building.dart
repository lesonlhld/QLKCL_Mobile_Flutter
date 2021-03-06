// To parse this JSON data, do
//
//     final building = buildingFromJson(jsonString);

import 'dart:convert';

import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/api.dart';

Building buildingFromJson(String str) => Building.fromJson(json.decode(str));

String buildingToJson(Building data) => json.encode(data.toJson());

class Building {
  Building({
    required this.id,
    required this.name,
    required this.quarantineWard,
    required this.currentMem,
    this.capacity,
  });

  final int id;
  late final String name;
  final dynamic quarantineWard;
  final int currentMem;
  final int? capacity;

  factory Building.fromJson(Map<String, dynamic> json) => Building(
        id: json["id"],
        name: json["name"],
        quarantineWard: json["quarantine_ward"],
        currentMem: json["num_current_member"],
        capacity: json["total_capacity"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "quarantine_ward": quarantineWard,
        "num_current_member": currentMem,
        "total_capacity": capacity,
      };
}

Future<dynamic> fetchBuilding({id}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.getHTTP('${Api.getBuilding}?id=$id');
  return response["data"];
}

//fetchBuildingList is in quarantine.dart
Future<Response> createBuilding(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.createBuilding, data);
  if (response == null) {
    return Response(status: Status.error, message: "Lỗi kết nối!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "Tạo tòa thành công!",
          data: response['data']);
    } else if (response['error_code'] == 400) {
      if (response['message']['name'] != null &&
          response['message']['name'] == "Exist") {
        return Response(status: Status.error, message: 'Tên tòa đã tồn tại!');
      } else {
        return Response(status: Status.error, message: "Có lỗi xảy ra!");
      }
    } else {
      return Response(status: Status.error, message: "Có lỗi xảy ra!");
    }
  }
}

Future<Response> updateBuilding(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.updateBuilding, data);
  if (response == null) {
    return Response(status: Status.error, message: "Lỗi kết nối!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "Cập nhật thông tin thành công!",
          data: Building.fromJson(response['data']));
    } else if (response['error_code'] == 400) {
      if (response['message']['name'] != null &&
          response['message']['name'] == "Exist") {
        return Response(status: Status.error, message: 'Tên tòa đã tồn tại!');
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
