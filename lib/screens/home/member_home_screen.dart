import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:qlkcl/components/cards.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/cloudinary.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/covid_data.dart';
import 'package:qlkcl/models/notification.dart' as notifications;
import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/screens/home/component/covid_info.dart';
import 'package:qlkcl/screens/notification/create_notification_screen.dart';
import 'package:qlkcl/utils/api.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:qlkcl/screens/medical_declaration/medical_declaration_screen.dart';
import 'package:qlkcl/screens/notification/list_notification_screen.dart';
import 'package:qlkcl/utils/constant.dart';

class MemberHomePage extends StatefulWidget {
  static const String routeName = "/member_home";
  MemberHomePage({Key? key}) : super(key: key);

  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  late int unreadNotifications = 0;
  late dynamic listNotification = [];

  late Future<CovidData> futureCovid;
  late Future<dynamic> futureData;

  var renderOverlay = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    futureCovid = fetchCovidList();
    futureData = fetch();
    notifications.fetchUserNotificationList(data: {
      'page_size': PAGE_SIZE_MAX
    }).then((value) => setState(() {
          listNotification = value;
          unreadNotifications = listNotification
              .where((element) =>
                  notifications.Notification.fromJson(element).isRead == false)
              .toList()
              .length;
        }));
  }

  Future<dynamic> fetch() async {
    ApiHelper api = ApiHelper();
    final response = await api.postHTTP(Api.homeMember, null);
    return response != null && response['data'] != null
        ? response['data']
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isDialOpen.value) {
          isDialOpen.value = false;
          return false;
        }
        return true;
      },
      child: Scaffold(
        floatingActionButton: SpeedDial(
          icon: Icons.send,
          activeIcon: Icons.close,
          spacing: 3,
          openCloseDial: isDialOpen,
          childPadding: const EdgeInsets.all(5),
          spaceBetweenChildren: 4,
          backgroundColor: Colors.red,

          /// If false, backgroundOverlay will not be rendered.
          renderOverlay: renderOverlay,
          overlayColor: Colors.black,
          overlayOpacity: 0.3,
          useRotationAnimation: useRAnimation,
          tooltip: 'Tạo mới',

          animationSpeed: 200,
          shape: const StadiumBorder(),
          childMargin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          children: [
            SpeedDialChild(
              child: const Icon(Icons.phone),
              label: 'Gọi cấp cứu',
              onTap: () => {},
            ),
            SpeedDialChild(
              child: const Icon(Icons.comment),
              label: 'Phản ánh/yêu cầu',
              onTap: () => Navigator.of(context,
                      rootNavigator: !Responsive.isDesktopLayout(context))
                  .pushNamed(CreateRequest.routeName),
            ),
          ],
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(72.0), // here the desired height
          child: AppBar(
            toolbarHeight: 64, // Set this height
            automaticallyImplyLeading: false,
            title: Padding(
              padding: EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    width: 56.0,
                    height: 56.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(cloudinary
                            .getImage('Default/no_avatar')
                            .toString()),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                      border: Border.all(
                        color: CustomColors.secondary,
                        width: 2.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào,",
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        FutureBuilder(
                          future: getName(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                snapshot.data,
                                style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: CustomColors.primaryText),
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            titleTextStyle:
                TextStyle(fontSize: 16.0, color: CustomColors.primaryText),
            backgroundColor: CustomColors.background,
            centerTitle: false,
            actions: [
              Badge(
                showBadge: unreadNotifications != 0,
                position: BadgePosition.topEnd(top: 10, end: 16),
                animationDuration: Duration(milliseconds: 300),
                animationType: BadgeAnimationType.scale,
                shape: BadgeShape.square,
                borderRadius: BorderRadius.circular(8),
                padding: EdgeInsets.fromLTRB(4, 2, 4, 2),
                badgeContent: Text(
                  unreadNotifications.toString(),
                  style: TextStyle(fontSize: 11.0, color: CustomColors.white),
                ),
                child: IconButton(
                  padding: EdgeInsets.only(right: 24),
                  icon: Icon(
                    Icons.notifications_none_outlined,
                    color: CustomColors.primaryText,
                  ),
                  onPressed: () {
                    Navigator.of(context,
                            rootNavigator: !Responsive.isDesktopLayout(context))
                        .pushNamed(ListNotification.routeName)
                        .then((value) => {
                              notifications.fetchUserNotificationList(data: {
                                'page_size': PAGE_SIZE_MAX
                              }).then((value) => setState(() {
                                    listNotification = value;
                                    unreadNotifications = listNotification
                                        .where((element) =>
                                            notifications.Notification.fromJson(
                                                    element)
                                                .isRead ==
                                            false)
                                        .toList()
                                        .length;
                                  }))
                            });
                  },
                  tooltip: "Thông báo",
                ),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () => Future.sync(() {
            setState(() {
              futureCovid = fetchCovidList();
              futureData = fetch();
            });
          }),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                if (!isWebPlatform())
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Thông tin dịch bệnh (Việt Nam)",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          FutureBuilder<CovidData>(
                            future: futureCovid,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return InfoCovidHomePage(
                                    increaseConfirmed:
                                        snapshot.data!.increaseConfirmed,
                                    confirmed: snapshot.data!.confirmed,
                                    increaseDeaths:
                                        snapshot.data!.increaseDeaths,
                                    deaths: snapshot.data!.deaths,
                                    increaseRecovered:
                                        snapshot.data!.increaseRecovered,
                                    recovered: snapshot.data!.recovered,
                                    increaseActived:
                                        snapshot.data!.increaseActived,
                                    actived: snapshot.data!.actived,
                                    lastUpdate: snapshot.data!.lastUpdate);
                              } else if (snapshot.hasError) {
                                return Text('${snapshot.error}');
                              }

                              // By default, show a loading spinner.
                              // return const CircularProgressIndicator();
                              return InfoCovidHomePage();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                FutureBuilder<dynamic>(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var msg = "";
                      if (snapshot.data['custom_user']['status'] == "WAITING") {
                        msg =
                            "Tài khoản của bạn chưa được xét duyệt. Vui lòng liên hệ với quản lý khu cách ly!";
                      } else if (snapshot.data['custom_user']['status'] ==
                          "REFUSED") {
                        msg =
                            "Tài khoản của bạn đã bị từ chối. Vui lòng liên hệ với quản lý khu cách ly!";
                      } else if (snapshot.data['custom_user']['status'] ==
                          "LOCKED") {
                        msg =
                            "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ với quản lý khu cách ly!";
                      } else if (snapshot.data['custom_user']['status'] ==
                          "LEAVE") {
                        msg =
                            "Tài khoản của bạn không còn hoạt động trong hệ thống. Vui lòng liên hệ với quản lý hoặc đăng ký tái cách ly!";
                      }
                      return Column(
                        children: [
                          if (msg != "")
                            Card(
                              child: ListTile(
                                contentPadding: EdgeInsets.all(8),
                                title: Text(
                                  msg,
                                  style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.normal,
                                      color: CustomColors.primaryText),
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: CustomColors.error,
                                  child: Icon(
                                    Icons.notification_important_outlined,
                                    color: CustomColors.white,
                                  ),
                                ),
                              ),
                            ),
                          Card(
                            child: Container(
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Thông tin sức khỏe",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline6,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      CustomColors.primaryText,
                                                ),
                                                children: [
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                      Icons.history,
                                                      size: 16,
                                                      color: CustomColors
                                                          .disableText,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: " Sức khỏe: " +
                                                        (snapshot.data[
                                                                    'health_status'] ==
                                                                "SERIOUS"
                                                            ? "Nguy hiểm"
                                                            : (snapshot.data[
                                                                        'health_status'] ==
                                                                    "UNWELL"
                                                                ? "Nghi nhiễm"
                                                                : "Bình thường")),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Text.rich(
                                              TextSpan(
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      CustomColors.primaryText,
                                                ),
                                                children: [
                                                  WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                      Icons
                                                          .description_outlined,
                                                      size: 16,
                                                      color: CustomColors
                                                          .disableText,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: " Xét nghiệm: " +
                                                        (snapshot.data[
                                                                    'positive_test_now'] !=
                                                                null
                                                            ? ((snapshot.data[
                                                                            'positive_test_now'] ==
                                                                        false
                                                                    ? "Âm tính"
                                                                    : "Dương tính") +
                                                                (snapshot.data[
                                                                            'last_tested_had_result'] !=
                                                                        null
                                                                    ? " (" +
                                                                        DateFormat("dd/MM/yyyy HH:mm:ss")
                                                                            .format(DateTime.parse(snapshot.data['last_tested_had_result']).toLocal()) +
                                                                        ")"
                                                                    : "") +
                                                                "")
                                                            : "Chưa có kết quả xét nghiệm"),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (snapshot.data['quarantine_ward'] != null)
                            QuarantineHome(
                              name: snapshot.data['quarantine_ward'] != null
                                  ? snapshot.data['quarantine_ward']
                                      ['full_name']
                                  : "",
                              manager: snapshot.data['quarantine_ward'] != null
                                  ? snapshot.data['quarantine_ward']
                                      ['main_manager']['full_name']
                                  : "",
                              address: snapshot.data['quarantine_ward'] != null
                                  ? (snapshot.data['quarantine_ward']
                                                  ['address'] !=
                                              null
                                          ? "${snapshot.data['quarantine_ward']['address']}, "
                                          : "") +
                                      (snapshot.data['quarantine_ward']
                                                  ['ward'] !=
                                              null
                                          ? "${snapshot.data['quarantine_ward']['ward']['name']}, "
                                          : "") +
                                      (snapshot.data['quarantine_ward']
                                                  ['district'] !=
                                              null
                                          ? "${snapshot.data['quarantine_ward']['district']['name']}, "
                                          : "") +
                                      (snapshot.data['quarantine_ward']
                                                  ['city'] !=
                                              null
                                          ? "${snapshot.data['quarantine_ward']['city']['name']}"
                                          : "")
                                  : "",
                              room: (snapshot.data['quarantine_room'] != null
                                      ? "${snapshot.data['quarantine_room']['name']} - "
                                      : "") +
                                  (snapshot.data['quarantine_floor'] != null
                                      ? "${snapshot.data['quarantine_floor']['name']} - "
                                      : "") +
                                  (snapshot.data['quarantine_building'] != null
                                      ? "${snapshot.data['quarantine_building']['name']} - "
                                      : "") +
                                  (snapshot.data['quarantine_ward'] != null
                                      ? "${snapshot.data['quarantine_ward']['full_name']}"
                                      : ""),
                              phone: snapshot.data['quarantine_ward'] != null &&
                                      snapshot.data['quarantine_ward']
                                              ['phone_number'] !=
                                          null
                                  ? snapshot.data['quarantine_ward']
                                      ['phone_number']
                                  : "Chưa có",
                              quarantineAt:
                                  snapshot.data['quarantined_at'] != null
                                      ? snapshot.data['quarantined_at']
                                      : "",
                              quarantineFinishExpect: snapshot.data[
                                          'quarantined_finish_expected_at'] !=
                                      null
                                  ? snapshot
                                      .data['quarantined_finish_expected_at']
                                  : "",
                            ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    // return const CircularProgressIndicator();
                    return Container();
                  },
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 48),
                      primary: CustomColors.secondary,
                    ),
                    onPressed: () {
                      Navigator.of(context,
                              rootNavigator:
                                  !Responsive.isDesktopLayout(context))
                          .push(MaterialPageRoute(
                              builder: (context) =>
                                  MedicalDeclarationScreen()));
                    },
                    child: Text(
                      'Khai báo y tế',
                      style: TextStyle(
                        color: CustomColors.white,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
