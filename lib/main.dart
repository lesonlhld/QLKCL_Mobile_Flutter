import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/utils/routes.dart';
import 'package:qlkcl/screens/app.dart';
import 'package:qlkcl/screens/login/login_screen.dart';
// import 'package:qlkcl/screens/splash/splash_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:responsive_framework/responsive_framework.dart';
// import 'package:url_strategy/url_strategy.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  // Here we set the URL strategy for our web app.
  // It is safe to call this function when running on mobile or desktop as well.
  // setPathUrlStrategy();

  // Automatically show the notification bar when the app loads in IOS.
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);

  await Hive.initFlutter();

  final bool isLoggedIn = await getLoginState();
  final int role = await getRole();

  HttpOverrides.global = MyHttpOverrides();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp(
      isLoggedIn: isLoggedIn,
      role: role,
    ));
  });
}

class MyApp extends StatelessWidget {
  static const String routeName = "/init";
  final bool isLoggedIn;
  final int role;
  const MyApp({Key? key, this.isLoggedIn = false, this.role = 5})
      : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: Init.instance.initialize(),
    //   builder: (context, AsyncSnapshot snapshot) {
    //     // Show splash screen while waiting for app resources to load:
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return MaterialApp(
    //         debugShowCheckedModeBanner: false,
    //         theme: AppTheme.lightTheme,
    //         home: Splash(),
    //       );
    //     } else {
    //       // Loading is done, return the app:
    final botToastBuilder = BotToastInit();
    return MaterialApp(
      title: 'Qu???n l?? khu c??ch ly',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: isLoggedIn ? App(role: role) : const Login(),
      routes: routes,
      // initialRoute: isLoggedIn ? App.routeName : Login.routeName,
      builder: (context, child) {
        child = ResponsiveWrapper.builder(
            BouncingScrollWrapper.builder(context, child!),
            maxWidth: 2460,
            defaultScale: true,
            breakpoints: [
              const ResponsiveBreakpoint.resize(maxMobileSize, name: MOBILE),
              const ResponsiveBreakpoint.resize(maxTabletSize, name: TABLET),
              const ResponsiveBreakpoint.resize(minDesktopSize,
                  name:
                      DESKTOP), // > 1200, only stretches to fill the available width
              const ResponsiveBreakpoint.autoScale(2460, name: "4K"),
            ],
            background: Container(color: const Color(0xFFF5F5F5)));
        child = botToastBuilder(context, child);
        return child;
      },
      navigatorObservers: [BotToastNavigatorObserver()],
    );
  }
  // },
  // );
  // }
}

class Init {
  Init._();
  static final instance = Init._();

  Future initialize() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // await Future.delayed(const Duration(milliseconds: 100));
  }
}
