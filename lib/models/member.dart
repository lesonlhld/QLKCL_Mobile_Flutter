// To parse this JSON data, do
//
//     final member = memberFromJson(jsonString);

import 'dart:convert';

import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/api.dart';

Member memberFromJson(String str) => Member.fromJson(json.decode(str));

String memberToJson(Member data) => json.encode(data.toJson());

class Member {
  Member({
    required this.id,
    this.quarantineRoom,
    this.quarantineFloor,
    this.quarantineBuilding,
    this.quarantineWard,
    required this.label,
    this.positiveTestedBefore,
    this.abroad,
    this.quarantinedAt,
    this.quarantinedFinishExpectedAt,
    this.quarantinedFinishAt,
    this.quarantinedStatus,
    this.lastTested,
    this.healthStatus,
    this.healthNote,
    this.positiveTestNow,
    this.backgroundDisease,
    this.otherBackgroundDisease,
    this.backgroundDiseaseNote,
    this.careStaff,
    this.customUserCode,
    this.numberOfVaccineDoses = "0",
    this.quarantineReason,
    this.firstPositiveTestDate,
    this.lastHealthStatusTime,
  });

  final int id;
  final dynamic quarantineRoom;
  final dynamic quarantineFloor;
  final dynamic quarantineBuilding;
  KeyValue? quarantineWard;
  final String? label;
  final bool? positiveTestedBefore;
  final bool? abroad;
  final dynamic quarantinedAt;
  final dynamic quarantinedFinishExpectedAt;
  final dynamic quarantinedFinishAt;
  final String? quarantinedStatus;
  final dynamic lastTested;
  final String? healthStatus;
  final dynamic healthNote;
  final bool? positiveTestNow;
  final dynamic backgroundDisease;
  final dynamic otherBackgroundDisease;
  final dynamic backgroundDiseaseNote;
  final KeyValue? careStaff;
  String? customUserCode;
  final String numberOfVaccineDoses;
  final String? quarantineReason;
  final String? firstPositiveTestDate;
  final String? lastHealthStatusTime;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
        id: json["id"],
        quarantineRoom: json["quarantine_room"],
        quarantineFloor: json["quarantine_floor"],
        quarantineBuilding: json["quarantine_building"],
        quarantineWard: json["quarantine_ward"] != null
            ? KeyValue.fromJson(json["quarantine_ward"])
            : null,
        label: json["label"],
        positiveTestedBefore: json["positive_tested_before"],
        abroad: json["abroad"],
        quarantinedAt: json["quarantined_at"],
        quarantinedFinishExpectedAt: json["quarantined_finish_expected_at"],
        quarantinedFinishAt: json["quarantined_finished_at"],
        quarantinedStatus: json["quarantined_status"],
        lastTested: json["last_tested"],
        healthStatus: json["health_status"],
        healthNote: json["health_note"],
        positiveTestNow: json["positive_test_now"],
        backgroundDisease: json["background_disease"],
        otherBackgroundDisease: json["other_background_disease"],
        backgroundDiseaseNote: json["background_disease_note"],
        careStaff: json["care_staff"] != null
            ? KeyValue.fromJson(json["care_staff"])
            : null,
        numberOfVaccineDoses: json["number_of_vaccine_doses"],
        quarantineReason: json["quarantine_reason"],
        firstPositiveTestDate: json["first_positive_test_date"],
        lastHealthStatusTime: json["last_health_status_time"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "quarantine_room": quarantineRoom,
        "quarantine_floor": quarantineFloor,
        "quarantine_building": quarantineBuilding,
        "quarantine_ward": quarantineWard,
        "label": label,
        "positive_tested_before": positiveTestedBefore,
        "abroad": abroad,
        "quarantined_at": quarantinedAt,
        "quarantined_finish_expected_at": quarantinedFinishExpectedAt,
        "quarantined_finished_at": quarantinedFinishAt,
        "quarantined_status": quarantinedStatus,
        "last_tested": lastTested,
        "health_status": healthStatus,
        "health_note": healthNote,
        "positive_test_now": positiveTestNow,
        "background_disease": backgroundDisease,
        "other_background_disease": otherBackgroundDisease,
        "background_disease_note": backgroundDiseaseNote,
        "care_staff": careStaff?.toJson(),
        "number_of_vaccine_doses": numberOfVaccineDoses,
        "quarantine_reason": quarantineReason,
        "first_positive_test_date": firstPositiveTestDate,
        "last_health_status_time": lastHealthStatusTime,
      };
}

Future<FilterResponse<FilterMember>> fetchMemberList({data}) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.getListMembers, data);
  if (response != null) {
    if (response['error_code'] == 0 && response['data'] != null) {
      final List<FilterMember> itemList = response['data']['content']
          .map<FilterMember>((json) => FilterMember.fromJson(json))
          .toList();
      return FilterResponse<FilterMember>(
          data: itemList,
          totalPages: response['data']['totalPages'],
          totalRows: response['data']['totalRows'],
          currentPage: response['data']['currentPage']);
    } else if (response['error_code'] == 401) {
      if (response['message']['quarantine_ward_id'] != null &&
          response['message']['quarantine_ward_id'] == "Permission denied") {
        showNotification('Kh??ng c?? quy???n th???c hi???n ch???c n??ng n??y!',
            status: Status.error);
      }
      return FilterResponse<FilterMember>();
    } else {
      showNotification('C?? l???i x???y ra!', status: Status.error);
      return FilterResponse<FilterMember>();
    }
  }

  return FilterResponse<FilterMember>();
}

Future<Response> createMember(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.createMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "T???o ng?????i c??ch ly th??nh c??ng!",
          data: response['data']);
    } else if (response['error_code'] == 400) {
      if (response['message']['phone_number'] != null &&
          response['message']['phone_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? ??i???n tho???i ???? ???????c s??? d???ng!");
      } else if (response['message']['email'] != null &&
          response['message']['email'] == "Exist") {
        return Response(
            status: Status.error, message: "Email ???? ???????c s??? d???ng!");
      } else if (response['message']['identity_number'] != null &&
          response['message']['identity_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? CMND/CCCD ???? t???n t???i!");
      } else if (response['message']['health_insurance_number'] != null &&
          response['message']['health_insurance_number'] == "Invalid") {
        return Response(
            status: Status.error, message: "S??? b???o hi???m y t??? kh??ng h???p l???!");
      } else if (response['message']['passport_number'] != null &&
          response['message']['passport_number'] == "Invalid") {
        return Response(
            status: Status.error, message: "S??? h??? chi???u kh??ng h???p l???!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] == "Full") {
        return Response(
            status: Status.error, message: "Ph??ng ???? h???t ch??? tr???ng!");
      } else if (response['message']['quarantine_ward_id'] != null &&
          response['message']['quarantine_ward_id'] == "Cannot change") {
        return Response(
            status: Status.error, message: "Kh??ng th??? thay ?????i khu c??ch ly!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room does not satisfy max_day_quarantined") {
        return Response(
            status: Status.error, message: "Ph??ng ???? ch???n kh??ng ph?? h???p!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This member positive, but this room has member that is not positive") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? th??m ng?????i d????ng t??nh v??o ph??ng n??y!");
      } else if (response['message']['passport_number'] != null &&
          response['message']['passport_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? h??? chi???u ???? t???n t???i!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room is close (not accept any more member)") {
        return Response(
            status: Status.error,
            message:
                "Ph??ng ???? ch???n kh??ng ph?? h???p (kh??ng ch???p nh???n th??m ng?????i c??ch ly m???i)!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room has member that is positive") {
        return Response(
            status: Status.error, message: "Ph??ng n??y c?? ng?????i d????ng t??nh!");
      } else if (response['message']['main'] != null &&
          (response['message']['main'] ==
                  "All rooms are not accept any more member" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full or dont meet with this user positive_test_now")) {
        return Response(
            status: Status.error,
            message: "Khu c??ch ly n??y kh??ng th??? ti???p nh???n ng?????i c??ch ly m???i!");
      } else if (response['message']['quarantine_room_id'] != null &&
          (response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history exist" ||
              response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['quarantine_room_id'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> updateMember(Map<String, dynamic> data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.updateMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "C???p nh???t th??ng tin th??nh c??ng!",
          data: response['data']);
    } else if (response['error_code'] == 400) {
      if (response['message'] != null &&
          response['message'] == "Invalid argument") {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      } else if (response['message']['phone_number'] != null &&
          response['message']['phone_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? ??i???n tho???i ???? ???????c s??? d???ng!");
      } else if (response['message']['health_insurance_number'] != null &&
          response['message']['health_insurance_number'] == "Invalid") {
        return Response(
            status: Status.error, message: "S??? b???o hi???m y t??? kh??ng h???p l???!");
      } else if (response['message']['passport_number'] != null &&
          response['message']['passport_number'] == "Invalid") {
        return Response(
            status: Status.error, message: "S??? h??? chi???u kh??ng h???p l???!");
      } else if (response['message']['identity_number'] != null &&
          response['message']['identity_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? CMND/CCCD ???? t???n t???i!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] == "Full") {
        return Response(
            status: Status.error, message: "Ph??ng ???? h???t ch??? tr???ng!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] == "Must empty") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? g??n ph??ng cho ng?????i n??y!");
      } else if (response['message']['email'] != null &&
          response['message']['email'] == "Exist") {
        return Response(
            status: Status.error, message: "Email ???? ???????c s??? d???ng!");
      } else if (response['message']['quarantine_ward_id'] != null &&
          response['message']['quarantine_ward_id'] == "Cannot change") {
        return Response(
            status: Status.error, message: "Kh??ng th??? thay ?????i khu c??ch ly!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room does not satisfy max_day_quarantined") {
        return Response(
            status: Status.error, message: "Ph??ng ???? ch???n kh??ng ph?? h???p!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This member positive, but this room has member that is not positive") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? th??m ng?????i d????ng t??nh v??o ph??ng n??y!");
      } else if (response['message']['passport_number'] != null &&
          response['message']['passport_number'] == "Exist") {
        return Response(
            status: Status.error, message: "S??? h??? chi???u ???? t???n t???i!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room is close (not accept any more member)") {
        return Response(
            status: Status.error,
            message:
                "Ph??ng ???? ch???n kh??ng ph?? h???p (kh??ng ch???p nh???n th??m ng?????i c??ch ly m???i)!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room has member that is positive") {
        return Response(
            status: Status.error, message: "Ph??ng n??y c?? ng?????i d????ng t??nh!");
      } else if (response['message']['quarantine_room_id'] != null &&
          (response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history exist" ||
              response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['quarantine_room_id'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else if (response['message']['main'] != null &&
          (response['message']['main'] ==
                  "All rooms are not accept any more member" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full or dont meet with this user positive_test_now")) {
        return Response(
            status: Status.error,
            message: "Khu c??ch ly n??y kh??ng th??? ti???p nh???n ng?????i c??ch ly m???i!");
      } else if (response['message']['first_positive_test_date'] != null &&
          response['message']['first_positive_test_date'] == "Cannot change") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? thay ?????i ng??y nhi???m b???nh!");
      } else if (response['message']['main'] != null &&
          response['message']['main'] ==
              "Cannot change room and label together") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? thay ?????i ph??ng v?? di???n c??ch ly c??ng l??c!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else if (response['error_code'] == 401) {
      if (response['message'] != null &&
          response['message'] == "Permission denied") {
        return Response(
            status: Status.error,
            message: 'Kh??ng c?? quy???n th???c hi???n ch???c n??ng n??y!');
      } else if (response['message']['label'] != null &&
          response['message']['label'] == "Permission denied") {
        return Response(
            status: Status.error,
            message: "Kh??ng c?? quy???n c???p nh???t di???n c??ch ly!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> denyMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.denyMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(status: Status.success, message: "T??? ch???i th??nh c??ng!");
    } else if (response['error_code'] == 400) {
      if (response['message']['member_codes'] != null &&
          response['message']['member_codes'] == "empty") {
        return Response(
            status: Status.error,
            message: "Vui l??ng ch???n t??i kho???n c???n x??t duy???t!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> acceptManyMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.acceptManyMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0 && response['data'] == {}) {
      showNotification("X??t duy???t th??nh c??ng!");
      return Response(status: Status.success, message: "X??t duy???t th??nh c??ng!");
    } else if (response['error_code'] == 0 && response['data'] != {}) {
      showNotification(
          "M???t s??? t??i kho???n kh??ng th??? x??t duy???t. Vui l??ng ki???m tra l???i th??ng tin!",
          status: Status.warning);
      return Response(
          status: Status.success,
          message:
              "M???t s??? t??i kho???n kh??ng th??? x??t duy???t. Vui l??ng ki???m tra l???i th??ng tin!");
    } else if (response['error_code'] == 400) {
      if (response['message']['member_codes'] != null &&
          response['message']['member_codes'] == "empty") {
        showNotification("Vui l??ng ch???n t??i kho???n c???n x??t duy???t!",
            status: Status.error);
        return Response(
            status: Status.error,
            message: "Vui l??ng ch???n t??i kho???n c???n x??t duy???t!");
      } else {
        showNotification("C?? l???i x???y ra!", status: Status.error);
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      showNotification("C?? l???i x???y ra!", status: Status.error);
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> acceptOneMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.acceptOneMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(status: Status.success, message: "X??t duy???t th??nh c??ng!");
    } else if (response['error_code'] == 400) {
      if (response['message']['member_codes'] != null &&
          response['message']['member_codes'] == "empty") {
        return Response(
            status: Status.error,
            message: "Vui l??ng ch???n t??i kho???n c???n x??t duy???t!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] == "Full") {
        return Response(
            status: Status.error, message: "Ph??ng ???? h???t ch??? tr???ng!");
      } else if (response['message']['quarantine_ward_id'] != null &&
          response['message']['quarantine_ward_id'] == "Cannot change") {
        return Response(
            status: Status.error, message: "Kh??ng th??? thay ?????i khu c??ch ly!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room does not satisfy max_day_quarantined") {
        return Response(
            status: Status.error, message: "Ph??ng ???? ch???n kh??ng ph?? h???p!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This member positive, but this room has member that is not positive") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? th??m ng?????i d????ng t??nh v??o ph??ng n??y!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room is close (not accept any more member)") {
        return Response(
            status: Status.error,
            message:
                "Ph??ng ???? ch???n kh??ng ph?? h???p (kh??ng ch???p nh???n th??m ng?????i c??ch ly m???i)!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room has member that is positive") {
        return Response(
            status: Status.error, message: "Ph??ng n??y c?? ng?????i d????ng t??nh!");
      } else if (response['message']['quarantine_room_id'] != null &&
          (response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history exist" ||
              response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['quarantine_room_id'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else if (response['message']['main'] != null &&
          (response['message']['main'] ==
                  "All rooms are not accept any more member" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full" ||
              response['message']['main'] ==
                  "All rooms in this quarantine ward are full or dont meet with this user positive_test_now")) {
        return Response(
            status: Status.error,
            message: "Khu c??ch ly n??y kh??ng th??? ti???p nh???n ng?????i c??ch ly m???i!");
      } else if (response['message']['main'] != null &&
          (response['message']['main'] == "PRESENT quarantine history exist" ||
              response['message']['main'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['main'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else {
        return Response(
            status: Status.error,
            message:
                "Kh??ng th??? x??t duy???t t??i kho???n n??y. Vui l??ng ki???m tra l???i th??ng tin!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> finishMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.finishMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0 && response['data'].isEmpty) {
      return Response(
          status: Status.success, message: "???? ho??n th??nh c??ch ly!");
    } else if (response['error_code'] == 0 && response['data'].isNotEmpty) {
      return Response(
          status: Status.error, message: "Kh??ng th??? ho??n th??nh c??ch ly!");
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> changeRoomMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.changeRoomMember, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success, message: "Chuy???n ph??ng th??nh c??ng!");
    } else if (response['error_code'] == 400) {
      if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room does not satisfy max_day_quarantined") {
        return Response(
            status: Status.error, message: "Ph??ng ???? ch???n kh??ng ph?? h???p!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This member positive, but this room has member that is not positive") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? chuy???n ng?????i d????ng t??nh v??o ph??ng n??y!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room is close (not accept any more member)") {
        return Response(
            status: Status.error,
            message:
                "Ph??ng ???? ch???n kh??ng ph?? h???p (kh??ng ch???p nh???n th??m ng?????i c??ch ly m???i)!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room has member that is positive") {
        return Response(
            status: Status.error, message: "Ph??ng n??y c?? ng?????i d????ng t??nh!");
      } else if (response['message']['main'] != null &&
          (response['message']['main'] == "PRESENT quarantine history exist" ||
              response['message']['main'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['main'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> getSuitableRoom(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.getSuitableRoom, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(status: Status.success, data: response['data']);
    } else if (response['error_code'] == 400) {
      if (response['message'] == "All rooms are not accept any more member" ||
          response['message'] ==
              "All rooms in this quarantine ward are full or dont meet with this user positive_test_now") {
        return Response(
            status: Status.error, message: "Kh??ng t??m th???y ph??ng th??ch h???p!");
      } else if (response['message']['label'] != null &&
          response['message']['label'] == "empty") {
        return Response(
            status: Status.error, message: "Vui l??ng ch???n di???n c??ch ly!");
      } else {
        return Response(
            status: Status.error, message: "Kh??ng t??m th???y ph??ng th??ch h???p!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<dynamic> importMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.importMember, data);
  if (response == null) {
    showNotification("L???i k???t n???i!", status: Status.error);
  } else {
    if (response['error_code'] == 0) {
      return response['data'];
    } else {
      showNotification("C?? l???i x???y ra!", status: Status.error);
    }
  }
}

Future<Response> memberCallRequarantine(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.memberCallRequarantine, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
        status: Status.success,
        message: "????ng k?? t??i c??ch ly th??nh c??ng! Vui l??ng ch??? x??t duy???t.",
      );
    } else if (response['error_code'] == 400) {
      if (response['message']['sender'] != null &&
          response['message']['sender'] == "This user is not leave") {
        return Response(
            status: Status.error, message: "Kh??ng th??? t??i c??ch ly!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> managerCallRequarantine(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.managerCallRequarantine, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
        status: Status.success,
        message: "T??i c??ch ly th??nh c??ng!",
      );
    } else if (response['error_code'] == 400) {
      if (response['message']['sender'] != null &&
          response['message']['sender'] == "This user is not leave") {
        return Response(
            status: Status.error, message: "Kh??ng th??? t??i c??ch ly!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] == "Full") {
        return Response(
            status: Status.error, message: "Ph??ng ???? h???t ch??? tr???ng!");
      } else if (response['message']['quarantine_ward_id'] != null &&
          response['message']['quarantine_ward_id'] == "Cannot change") {
        return Response(
            status: Status.error, message: "Kh??ng th??? thay ?????i khu c??ch ly!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room does not satisfy max_day_quarantined") {
        return Response(
            status: Status.error, message: "Ph??ng ???? ch???n kh??ng ph?? h???p!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This member positive, but this room has member that is not positive") {
        return Response(
            status: Status.error,
            message: "Kh??ng th??? th??m ng?????i d????ng t??nh v??o ph??ng n??y!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room is close (not accept any more member)") {
        return Response(
            status: Status.error,
            message:
                "Ph??ng ???? ch???n kh??ng ph?? h???p (kh??ng ch???p nh???n th??m ng?????i c??ch ly m???i)!");
      } else if (response['message']['quarantine_room_id'] != null &&
          response['message']['quarantine_room_id'] ==
              "This room has member that is positive") {
        return Response(
            status: Status.error, message: "Ph??ng n??y c?? ng?????i d????ng t??nh!");
      } else if (response['message']['quarantine_room_id'] != null &&
          (response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history exist" ||
              response['message']['quarantine_room_id'] ==
                  "PRESENT quarantine history not exist" ||
              response['message']['quarantine_room_id'] ==
                  "Many PRESENT quarantine history exist")) {
        return Response(status: Status.error, message: "L???i l???ch s??? c??ch ly!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

Future<Response> hospitalizeMember(data) async {
  final ApiHelper api = ApiHelper();
  final response = await api.postHTTP(Api.hospitalize, data);
  if (response == null) {
    return Response(status: Status.error, message: "L???i k???t n???i!");
  } else {
    if (response['error_code'] == 0) {
      return Response(
          status: Status.success,
          message: "Vui l??ng ch??? x??t duy???t t??? ph??a b???nh vi???n!");
    } else if (response['error_code'] == 400) {
      if (response['message']['code'] != null &&
          (response['message']['code'] ==
              "This member is already hospitalize waiting")) {
        return Response(
            status: Status.error,
            message:
                "T??i kho???n n??y ???? th???c hi???n chuy???n vi???n. Vui l??ng ch??? x??c nh???n t??? ph??a b???nh vi???n!");
      } else {
        return Response(status: Status.error, message: "C?? l???i x???y ra!");
      }
    } else {
      return Response(status: Status.error, message: "C?? l???i x???y ra!");
    }
  }
}

// To parse this JSON data, do
//
//     final filterMember = filterMemberFromJson(jsonString);

FilterMember filterMemberFromJson(String str) =>
    FilterMember.fromJson(json.decode(str));

String filterMemberToJson(FilterMember data) => json.encode(data.toJson());

class FilterMember {
  FilterMember({
    required this.code,
    required this.status,
    required this.fullName,
    required this.gender,
    this.birthday,
    this.quarantineRoom,
    required this.phoneNumber,
    required this.createdAt,
    this.quarantinedAt,
    this.quarantinedFinishExpectedAt,
    this.quarantinedFinishAt,
    this.quarantineFloor,
    this.quarantineBuilding,
    required this.quarantineWard,
    required this.healthStatus,
    this.positiveTestNow,
    this.lastTested,
    this.lastTestedHadResult,
    required this.label,
    required this.numberOfVaccineDoses,
    this.quarantineLocation,
    this.quarantineLocationWithWard,
    this.quarantinedStatus,
  });

  final String code;
  final String status;
  final String fullName;
  final String gender;
  final String? birthday;
  final KeyValue? quarantineRoom;
  final String phoneNumber;
  final String createdAt;
  final String? quarantinedAt;
  final String? quarantinedFinishExpectedAt;
  final String? quarantinedFinishAt;
  final KeyValue? quarantineFloor;
  final KeyValue? quarantineBuilding;
  final KeyValue? quarantineWard;
  final String healthStatus;
  final bool? positiveTestNow;
  final String? lastTested;
  final String? lastTestedHadResult;
  final String? label;
  final String numberOfVaccineDoses;
  final String? quarantineLocation;
  final String? quarantineLocationWithWard;
  final String? quarantinedStatus;

  factory FilterMember.fromJson(Map<String, dynamic> json) => FilterMember(
        code: json["code"],
        status: json["status"],
        fullName: json["full_name"],
        gender: json["gender"],
        birthday: json["birthday"],
        quarantineRoom: json["quarantine_room"] != null
            ? KeyValue.fromJson(json["quarantine_room"])
            : null,
        phoneNumber: json["phone_number"],
        createdAt: json["created_at"],
        quarantinedAt: json["quarantined_at"],
        quarantinedFinishExpectedAt: json["quarantined_finish_expected_at"],
        quarantinedFinishAt: json["quarantined_finished_at"],
        quarantineFloor: json["quarantine_floor"] != null
            ? KeyValue.fromJson(json["quarantine_floor"])
            : null,
        quarantineBuilding: json["quarantine_building"] != null
            ? KeyValue.fromJson(json["quarantine_building"])
            : null,
        quarantineWard: KeyValue.fromJson(json["quarantine_ward"]),
        healthStatus: json["health_status"],
        positiveTestNow: json["positive_test_now"],
        lastTested: json["last_tested"],
        lastTestedHadResult: json["last_tested_had_result"],
        label: json["label"],
        numberOfVaccineDoses: json["number_of_vaccine_doses"],
        quarantineLocation: (json['quarantine_room'] != null
                ? "${json['quarantine_room']['name']}, "
                : "") +
            (json['quarantine_floor'] != null
                ? "${json['quarantine_floor']['name']}, "
                : "") +
            (json['quarantine_building'] != null
                ? "${json['quarantine_building']['name']}"
                : ""),
        quarantineLocationWithWard: (json['quarantine_room'] != null
                ? "${json['quarantine_room']['name']}, "
                : "") +
            (json['quarantine_floor'] != null
                ? "${json['quarantine_floor']['name']}, "
                : "") +
            (json['quarantine_building'] != null
                ? "${json['quarantine_building']['name']}, "
                : "") +
            (json['quarantine_ward'] != null
                ? "${json['quarantine_ward']['full_name']}"
                : ""),
        quarantinedStatus: json["quarantined_status"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "status": status,
        "full_name": fullName,
        "gender": gender,
        "birthday": birthday,
        "quarantine_room": quarantineRoom?.toJson(),
        "phone_number": phoneNumber,
        "created_at": createdAt,
        "quarantined_at": quarantinedAt,
        "quarantined_finish_expected_at": quarantinedFinishExpectedAt,
        "quarantined_finished_at": quarantinedFinishAt,
        "quarantine_floor": quarantineFloor?.toJson(),
        "quarantine_building": quarantineBuilding?.toJson(),
        "quarantine_ward": quarantineWard?.toJson(),
        "health_status": healthStatus,
        "positive_test_now": positiveTestNow,
        "last_tested": lastTested,
        "last_tested_had_result": lastTestedHadResult,
        "label": label,
        "number_of_vaccine_doses": numberOfVaccineDoses,
        "quarantined_status": quarantinedStatus,
      };

  @override
  String toString() {
    return code;
  }
}
