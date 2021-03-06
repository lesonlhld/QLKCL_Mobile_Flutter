// To parse this JSON data, do
//
//     final notification = notificationFromJson(jsonString);

import 'dart:convert';

import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/api.dart';

Notification notificationFromJson(String str) =>
    Notification.fromJson(json.decode(str));

String notificationToJson(Notification data) => json.encode(data.toJson());

class Notification {
  Notification({
    required this.notification,
    required this.isRead,
  });

  final NotificationClass notification;
  final bool isRead;

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        notification: NotificationClass.fromJson(json["notification"]),
        isRead: json["is_read"],
      );

  Map<String, dynamic> toJson() => {
        "notification": notification.toJson(),
        "is_read": isRead,
      };
}

class NotificationClass {
  NotificationClass({
    required this.id,
    required this.createdBy,
    required this.title,
    required this.description,
    required this.image,
    required this.url,
    required this.type,
    required this.createdAt,
  });

  final int id;
  final CreatedBy? createdBy;
  final String title;
  final String description;
  final dynamic image;
  final dynamic url;
  final String type;
  final DateTime createdAt;

  factory NotificationClass.fromJson(Map<String, dynamic> json) =>
      NotificationClass(
        id: json["id"],
        createdBy: json["created_by"] != null
            ? CreatedBy.fromJson(json["created_by"])
            : null,
        title: json["title"],
        description: json["description"],
        image: json["image"],
        url: json["url"],
        type: json["type"],
        createdAt: DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_by": createdBy?.toJson(),
        "title": title,
        "description": description,
        "image": image,
        "url": url,
        "type": type,
        "created_at": createdAt.toIso8601String(),
      };
}

class CreatedBy {
  CreatedBy({
    required this.code,
    required this.fullName,
  });

  final String code;
  final String fullName;

  factory CreatedBy.fromJson(Map<String, dynamic> json) => CreatedBy(
        code: json["code"],
        fullName: json["full_name"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "full_name": fullName,
      };
}

Future<dynamic> fetchUserNotification({id}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.getHTTP('${Api.getUserNotification}?id=$id');
  return response["data"];
}

Future<dynamic> fetchUserNotificationList({data}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.filterUserNotification, data);
  return response != null && response['data'] != null
      ? response['data']['content']
      : null;
}

Future<Response> changeStateUserNotification({data}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.changeStateUserNotification, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success, data: response['data']['is_read']);
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> createNotification({data}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.createNotification, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success, message: "T???o th??ng b??o th??nh c??ng!");
    } else if (response['error_code'] == 400) {
      if (response['message']['users'] != null &&
          response['message']['users'] == "empty") {
        return Response(
            status: Status.error, message: "Vui l??ng ch???n ng?????i nh???n!");
      } else if (response['message']['description'] != null &&
          response['message']['description'] == "empty") {
        return Response(
            status: Status.error, message: "N???i dung kh??ng ???????c ????? tr???ng!");
      } else if (response['message']['title'] != null &&
          response['message']['title'] == "empty") {
        return Response(
            status: Status.error, message: "Ti??u ????? kh??ng ???????c ????? tr???ng!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}
