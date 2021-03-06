import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/popup.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/custom_user.dart';
import 'package:qlkcl/models/member.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/destination_history/list_destination_history_screen.dart';
import 'package:qlkcl/screens/manager/update_manager_screen.dart';
import 'package:qlkcl/screens/medical_declaration/list_medical_declaration_screen.dart';
import 'package:qlkcl/screens/medical_declaration/medical_declaration_screen.dart';
import 'package:qlkcl/screens/members/change_quarantine_info.dart';
import 'package:qlkcl/screens/members/confirm_member_screen.dart';
import 'package:qlkcl/screens/members/hospitalize.dart';
import 'package:qlkcl/screens/members/requarantine_member_screen.dart';
import 'package:qlkcl/screens/members/update_member_screen.dart';
import 'package:qlkcl/screens/quarantine_history/list_quarantine_history_screen.dart';
import 'package:qlkcl/screens/test/add_test_screen.dart';
import 'package:qlkcl/screens/test/list_test_screen.dart';
import 'package:qlkcl/screens/vaccine/list_vaccine_dose_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

enum menusOptions {
  updateInfo,
  createMedicalDeclaration,
  medicalDeclareHistory,
  createTest,
  testHistory,
  vaccineDoseHistory,
  changeRoom,
  resetPassword,
  destinationHistory,
  quarantineHistory,
  completeQuarantine,
  requarantine,
  viewInfo,
  accept,
  deny,
  moveHospital,
  updateManagerInfo,
}

const Map<menusOptions, String> menusOptionsValue = {
  menusOptions.updateInfo: 'update_info',
  menusOptions.createMedicalDeclaration: 'create_medical_declaration',
  menusOptions.medicalDeclareHistory: 'medical_declare_history',
  menusOptions.createTest: 'create_test',
  menusOptions.testHistory: 'test_history',
  menusOptions.vaccineDoseHistory: 'vaccine_dose_history',
  menusOptions.changeRoom: 'change_room',
  menusOptions.resetPassword: 'reset_password',
  menusOptions.destinationHistory: 'destination_history',
  menusOptions.quarantineHistory: 'quarantine_history',
  menusOptions.completeQuarantine: 'complete_qauarantine',
  menusOptions.requarantine: 'requarantine',
  menusOptions.viewInfo: 'view_info',
  menusOptions.accept: 'accpet',
  menusOptions.deny: 'deny',
  menusOptions.moveHospital: 'move_hospital',
  menusOptions.updateManagerInfo: 'update_manager_info',
};

const Map<menusOptions, String> menusOptionsTitle = {
  menusOptions.updateInfo: 'C???p nh???t th??ng tin',
  menusOptions.createMedicalDeclaration: 'Khai b??o y t???',
  menusOptions.medicalDeclareHistory: 'L???ch s??? khai b??o y t???',
  menusOptions.createTest: 'T???o phi???u x??t nghi???m',
  menusOptions.testHistory: 'L???ch s??? x??t nghi???m',
  menusOptions.vaccineDoseHistory: 'Th??ng tin ti??m ch???ng',
  menusOptions.changeRoom: 'Chuy???n ph??ng',
  menusOptions.resetPassword: '?????t l???i m???t kh???u',
  menusOptions.destinationHistory: 'L???ch s??? di chuy???n',
  menusOptions.quarantineHistory: 'L???ch s??? c??ch ly',
  menusOptions.completeQuarantine: 'Ho??n th??nh c??ch ly',
  menusOptions.requarantine: 'T??i c??ch ly',
  menusOptions.viewInfo: 'Xem th??ng tin',
  menusOptions.accept: 'Ch???p nh???n',
  menusOptions.deny: 'T??? ch???i',
  menusOptions.moveHospital: 'Chuy???n vi???n',
  menusOptions.updateManagerInfo: 'C???p nh???t th??ng tin',
};

Widget menus<T>(
  BuildContext context,
  T data, {
  GlobalKey<SfDataGridState>? tableKey,
  PagingController<int, T>? pagingController,
  List<menusOptions> showMenusItems = const [],
  Color? customMenusColor,
}) {
  if (data.runtimeType == FilterMember ||
      data.runtimeType == FilterStaff ||
      data.runtimeType == CustomUser) {
    final code = data.runtimeType == FilterMember
        ? (data as FilterMember).code
        : data.runtimeType == FilterStaff
            ? (data as FilterStaff).code
            : (data as CustomUser).code;
    final phoneNumber = data.runtimeType == FilterMember
        ? (data as FilterMember).phoneNumber
        : data.runtimeType == FilterStaff
            ? (data as FilterStaff).phoneNumber
            : (data as CustomUser).phoneNumber;
    final fullName = data.runtimeType == FilterMember
        ? (data as FilterMember).fullName
        : data.runtimeType == FilterStaff
            ? (data as FilterStaff).fullName
            : (data as CustomUser).fullName;
    final quarantineWard = data.runtimeType == FilterMember
        ? (data as FilterMember).quarantineWard
        : data.runtimeType == FilterStaff
            ? (data as FilterStaff).quarantineWard
            : (data as CustomUser).quarantineWard;
    final quarantinedStatus = data.runtimeType == FilterMember
        ? (data as FilterMember).quarantinedStatus
        : "";

    return PopupMenuButton<menusOptions>(
        icon: Icon(
          Icons.more_vert,
          color: customMenusColor ?? disableText,
        ),
        onSelected: (result) async {
          if (result == menusOptions.updateInfo) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => UpdateMember(
                          code: code,
                        )));
          } else if (result == menusOptions.createMedicalDeclaration) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => MedicalDeclarationScreen(
                          phone: phoneNumber,
                          name: fullName,
                        )));
          } else if (result == menusOptions.medicalDeclareHistory) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ListMedicalDeclaration(
                          code: code,
                          phone: phoneNumber,
                          name: fullName,
                        )));
          } else if (result == menusOptions.createTest) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => AddTest(
                          phoneNumber: phoneNumber,
                          name: fullName,
                        )))
                .then((value) => {
                      if (value.status == Status.success)
                        {
                          if (Responsive.isDesktopLayout(context))
                            {tableKey?.currentState!.refresh()}
                          else
                            {pagingController!.refresh()}
                        }
                    });
          } else if (result == menusOptions.testHistory) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ListTest(
                          code: code,
                          name: fullName,
                          phoneNumber: phoneNumber,
                        )));
          } else if (result == menusOptions.quarantineHistory) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ListQuarantineHistory(
                          code: code,
                        )));
          } else if (result == menusOptions.destinationHistory) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ListDestinationHistory(
                          code: code,
                        )));
          } else if (result == menusOptions.vaccineDoseHistory) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ListVaccineDose(
                          code: code,
                        )));
          } else if (result == menusOptions.resetPassword) {
            final CancelFunc cancel = showLoading();
            final response = await resetPass({'code': code});
            cancel();
            showNotification(response, duration: 5);
          } else if (result == menusOptions.changeRoom) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ChangeQuanrantineInfo(
                          code: code,
                          quarantineWard: quarantineWard,
                        )));
          } else if (result == menusOptions.completeQuarantine) {
            await confirmAlertPopup(
              context,
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'X??c nh???n ho??n th??nh c??ch ly cho ',
                      style: TextStyle(color: primaryText),
                    ),
                    TextSpan(
                      text: fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              confirmAction: () async {
                final CancelFunc cancel = showLoading();
                final response = await finishMember({'member_codes': code});
                cancel();
                showNotification(response);
                if (response.status == Status.success) {
                  if (Responsive.isDesktopLayout(context)) {
                    tableKey?.currentState!.refresh();
                  } else {
                    pagingController!.refresh();
                  }
                }
              },
            );
          } else if (result == menusOptions.requarantine) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => RequarantienMember(
                          code: code,
                        )));
          } else if (result == menusOptions.viewInfo) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => ConfirmDetailMember(
                          code: code,
                        )));
          } else if (result == menusOptions.accept) {
            await confirmAlertPopup(
              context,
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'X??c nh???n ?????ng ?? c??ch ly cho ',
                      style: TextStyle(color: primaryText),
                    ),
                    TextSpan(
                      text: fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              confirmAction: () async {
                final CancelFunc cancel = showLoading();
                final response = await acceptOneMember({'code': code});
                cancel();
                showNotification(response);
                if (response.status == Status.success) {
                  if (Responsive.isDesktopLayout(context)) {
                    tableKey?.currentState!.refresh();
                  } else {
                    pagingController!.refresh();
                  }
                }
              },
            );
          } else if (result == menusOptions.deny) {
            await confirmAlertPopup(
              context,
              content: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'X??c nh???n t??? ch???i c??ch ly cho ',
                      style: TextStyle(color: primaryText),
                    ),
                    TextSpan(
                      text: fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              confirmAction: () async {
                final CancelFunc cancel = showLoading();
                final response = await denyMember({'member_codes': code});
                cancel();
                showNotification(response);
                if (response.status == Status.success) {
                  if (Responsive.isDesktopLayout(context)) {
                    tableKey?.currentState!.refresh();
                  } else {
                    pagingController!.refresh();
                  }
                }
              },
            );
          } else if (result == menusOptions.moveHospital) {
            if (quarantinedStatus != "HOSPITALIZE_WAITING") {
              Navigator.of(context,
                      rootNavigator: !Responsive.isDesktopLayout(context))
                  .push(MaterialPageRoute(
                      builder: (context) => Hospitalize(
                            code: code,
                          )))
                  .then((value) => {
                        if (value.status == Status.success)
                          {
                            if (Responsive.isDesktopLayout(context))
                              {tableKey?.currentState!.refresh()}
                            else
                              {pagingController!.refresh()}
                          }
                      });
            } else {
              showNotification(
                  "T??i kho???n n??y ???? th???c hi???n chuy???n vi???n. Vui l??ng ch??? x??c nh???n t??? ph??a b???nh vi???n!",
                  status: Status.error);
            }
          } else if (result == menusOptions.updateManagerInfo) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => UpdateManager(
                          code: code,
                        )));
          }
        },
        itemBuilder: (BuildContext context) => showMenusItems
            .map((e) => PopupMenuItem(
                  child: Text(menusOptionsTitle[e]!),
                  value: e,
                ))
            .cast<PopupMenuEntry<menusOptions>>()
            .toList());
  } else {
    return const SizedBox();
  }
}
