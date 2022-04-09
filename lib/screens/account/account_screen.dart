import 'package:flutter/material.dart';
import 'package:qlkcl/screens/account/component/qr_code.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/helper/onesignal.dart';
import 'package:qlkcl/screens/account/change_password_screen.dart';
import 'package:qlkcl/screens/destination_history/list_destination_history_screen.dart';
import 'package:qlkcl/screens/medical_declaration/list_medical_declaration_screen.dart';
import 'package:qlkcl/screens/login/login_screen.dart';
import 'package:qlkcl/screens/members/update_member_screen.dart';
import 'package:qlkcl/screens/quarantine_history/list_quarantine_history_screen.dart';
import 'package:qlkcl/screens/test/list_test_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/screens/vaccine/list_vaccine_dose_screen.dart';

// cre: https://stackoverflow.com/questions/55192347/in-flutter-bottom-navigation-bar-should-disappear-when-we-navigate-to-new-screen

class Account extends StatefulWidget {
  static const String routeName = "/account";

  Account({Key? key}) : super(key: key);

  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  int _role = 5;

  @override
  void initState() {
    getRole().then((value) {
      if (this.mounted)
        setState((() {
          _role = value;
        }));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý tài khoản"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Column(
        children: <Widget>[
          FutureBuilder(
            future: getCode(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return GenerateQrCode(qrData: snapshot.data);
              }
              return Container();
            },
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              "Hồ sơ sức khỏe",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListMedicalDeclaration.routeName);
                  },
                  title: const Text('Lịch sử khai báo y tế'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
                Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListTest.routeName);
                  },
                  title: const Text('Kết quả xét nghiệm'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
                Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListVaccineDose.routeName);
                  },
                  title: const Text('Thông tin tiêm chủng'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
                Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListDestinationHistory.routeName);
                  },
                  title: const Text('Lịch sử di chuyển'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
                Divider(
                  indent: 16,
                  endIndent: 16,
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListQuarantineHistory.routeName);
                  },
                  title: const Text('Lịch sử cách ly'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.only(left: 16),
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              "Tài khoản và bảo mật",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Card(
            child: Column(
              children: <Widget>[
                if (_role == 5)
                  ListTile(
                    onTap: () {
                      Navigator.of(context,
                              rootNavigator:
                                  !Responsive.isDesktopLayout(context))
                          .pushNamed(UpdateMember.routeName);
                    },
                    title: const Text('Thông tin cá nhân'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                  ),
                if (_role == 5)
                  Divider(
                    indent: 16,
                    endIndent: 16,
                  ),
                ListTile(
                  onTap: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ChangePassword.routeName);
                  },
                  title: const Text('Đổi mật khẩu'),
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
              ],
            ),
          ),
          Card(
            child: ListTile(
              onTap: () async {
                if (isAndroidPlatform() || isIOSPlatform()) {
                  handleDeleteTag("role");
                  handleDeleteTag("quarantine_ward_id");
                  handleRemoveExternalUserId();
                }
                await logout();
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(Login.routeName, (route) => false);
              },
              title: Text('Đăng xuất',
                  style: TextStyle(color: CustomColors.error)),
              trailing: Icon(
                Icons.logout_outlined,
                color: CustomColors.error,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          )
        ],
      )),
    );
  }
}
