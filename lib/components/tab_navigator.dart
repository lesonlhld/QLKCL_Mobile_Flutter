import 'package:flutter/material.dart';
import 'package:qlkcl/routes.dart';
import 'package:qlkcl/components/tab_item.dart';
import 'package:qlkcl/screens/account/account_page.dart';
import 'package:qlkcl/screens/home/home_page.dart';
import 'package:qlkcl/screens/qr_code/qr_scan.dart';

class TabNavigator extends StatelessWidget {
  TabNavigator({required this.navigatorKey, required this.tabItem});
  final GlobalKey<NavigatorState>? navigatorKey;
  final TabItem tabItem;
  final String role = "admin";

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      Routes.homepage: (context) =>
          role == "admin" ? ManagerHomePage() : MemberHomePage(),
      Routes.qr_code_scan: (context) => QrCodeScan(),
      Routes.account: (context) => AccountPage(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routeBuilders = _routeBuilders(context);
    return Navigator(
      key: navigatorKey,
      initialRoute: Routes.homepage,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          // settings: routeSettings,
          builder: (context) => routeBuilders[routeSettings.name!]!(context),
        );
      },
    );
  }
}
