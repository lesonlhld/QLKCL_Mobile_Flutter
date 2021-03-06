import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/destination_history.dart';
import 'package:qlkcl/screens/home/component/app_bar.dart';
import 'package:qlkcl/screens/home/component/maps.dart';
import 'package:qlkcl/screens/manager/add_manager_screen.dart';
import 'package:qlkcl/utils/api.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/screens/home/component/manager_info.dart';
import 'package:qlkcl/screens/medical_declaration/medical_declaration_screen.dart';
import 'package:qlkcl/screens/members/add_member_screen.dart';
import 'package:qlkcl/screens/quarantine_ward/add_quarantine_screen.dart';
import 'package:qlkcl/screens/test/add_test_screen.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';

// cre: https://pub.dev/packages/flutter_speed_dial/example
// cre: https://pub.dev/packages/badges
// cre: https://stackoverflow.com/questions/45631350/flutter-hiding-floatingactionbutton

class ManagerHomePage extends StatefulWidget {
  static const String routeName = "/manager_home";
  final int role;
  const ManagerHomePage({
    Key? key,
    this.role = 4, // Staff
  }) : super(key: key);

  @override
  _ManagerHomePageState createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  bool _showFab = true;

  late Future<dynamic> futureData;
  late Future<List<KeyValue>> futurePassBy;

  var renderOverlay = false;
  var useRAnimation = true;
  var isDialOpen = ValueNotifier<bool>(false);

  final quarantineWardController = TextEditingController();
  List<KeyValue> quarantineWardList = [];

  final startTimeMinController = TextEditingController(
      text: DateTime.now().subtract(const Duration(days: 14)).toString());
  final startTimeMaxController =
      TextEditingController(text: DateTime.now().toString());

  late String mapData;

  @override
  void initState() {
    rootBundle
        .loadString('assets/maps/vietnam.json')
        .then((value) => mapData = value);
    super.initState();
    futureData = fetch();
    futurePassBy =
        getAddressWithMembersPassBy(getAddressWithMembersPassByDataForm(
      addressType: "city",
      startTimeMin:
          parseDateTimeWithTimeZone(startTimeMinController.text, time: "00:00"),
      startTimeMax: parseDateTimeWithTimeZone(startTimeMaxController.text),
    ));
    fetchQuarantineWard({
      'page_size': pageSizeMax,
    }).then((value) {
      if (mounted) {
        setState(() {
          quarantineWardList = value;
        });
      }
    });
  }

  Future<dynamic> fetch() async {
    await Future.delayed(const Duration(seconds: 1));
    final ApiHelper api = ApiHelper();
    final response = await api.postHTTP(
        Api.homeManager,
        prepareDataForm({
          "number_of_days_in_out": 12,
          "quarantine_ward_id": quarantineWardController.text
        }));
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
        appBar: HomeAppBar(
          role: widget.role,
        ),
        body: NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direction = notification.direction;
            setState(() {
              if (direction == ScrollDirection.reverse) {
                _showFab = false;
              } else if (direction == ScrollDirection.forward) {
                _showFab = true;
              }
            });
            return true;
          },
          child: RefreshIndicator(
            onRefresh: () => Future.sync(() {
              setState(() {
                futureData = fetch();
                futurePassBy = getAddressWithMembersPassBy(
                    getAddressWithMembersPassByDataForm(
                  addressType: "city",
                  startTimeMin: parseDateTimeWithTimeZone(
                      startTimeMinController.text,
                      time: "00:00"),
                  startTimeMax:
                      parseDateTimeWithTimeZone(startTimeMaxController.text),
                ));
              });
            }),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  FutureBuilder<dynamic>(
                    future: futureData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final int numberDays = ResponsiveWrapper.of(context)
                                .isSmallerThan(MOBILE)
                            ? 4
                            : ResponsiveWrapper.of(context).isLargerThan(TABLET)
                                ? 12
                                : 6;
                        return InfoManagerHomePage(
                          totalUsers: snapshot
                              .data['number_of_all_members_past_and_now'],
                          availableSlots:
                              snapshot.data['number_of_available_slots'],
                          activeUsers:
                              snapshot.data['number_of_quarantining_members'],
                          waitingUsers:
                              snapshot.data['number_of_waiting_members'],
                          suspectedUsers:
                              snapshot.data['number_of_suspected_members'],
                          needTestUsers:
                              snapshot.data['number_of_need_test_members'],
                          canFinishUsers:
                              snapshot.data['number_of_can_finish_members'],
                          waitingTests:
                              snapshot.data['number_of_waiting_tests'],
                          positiveUsers:
                              snapshot.data['number_of_positive_members'],
                          hospitalizedUsers:
                              snapshot.data['number_of_hospitalized_members'],
                          numberIn: snapshot.data['in'].entries
                              .map((entry) => KeyValue(
                                  id: DateFormat("dd/MM/yyyy").format(
                                      DateTime.parse(entry.key).toLocal()),
                                  name: entry.value))
                              .toList()
                              .cast<KeyValue>()
                              .reversed
                              .take(numberDays)
                              .toList()
                              .reversed
                              .toList(),
                          numberOut: snapshot.data['complete'].entries
                              .map((entry) => KeyValue(
                                  id: DateFormat("dd/MM/yyyy").format(
                                      DateTime.parse(entry.key).toLocal()),
                                  name: entry.value))
                              .toList()
                              .cast<KeyValue>()
                              .reversed
                              .take(numberDays)
                              .toList()
                              .reversed
                              .toList(),
                          hospitalize: snapshot.data['hospitalize'].entries
                              .map((entry) => KeyValue(
                                  id: DateFormat("dd/MM/yyyy").format(
                                      DateTime.parse(entry.key).toLocal()),
                                  name: entry.value))
                              .toList()
                              .cast<KeyValue>()
                              .reversed
                              .take(numberDays)
                              .toList()
                              .reversed
                              .toList(),
                          quarantineWardList: quarantineWardList,
                          quarantineWardController: quarantineWardController,
                          refresh: () {
                            setState(() {
                              futureData = fetch();
                            });
                          },
                          role: widget.role,
                        );
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      }

                      // By default, show a loading spinner.
                      // return const CircularProgressIndicator();
                      return InfoManagerHomePage(
                        quarantineWardList: quarantineWardList,
                        quarantineWardController: quarantineWardController,
                        refresh: () {
                          setState(() {
                            futureData = fetch();
                          });
                        },
                        role: widget.role,
                      );
                    },
                  ),
                  ResponsiveRowColumn(
                    layout: MediaQuery.of(context).size.width < 960
                        ? ResponsiveRowColumnType.COLUMN
                        : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                    rowCrossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ResponsiveRowColumnItem(
                        rowFlex: 1,
                        child: Container(
                          width: double.infinity,
                          height: 800,
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  const Text(
                                    "Th???ng k?? ng?????i di chuy???n",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(
                                    height: 8,
                                  ),
                                  Expanded(
                                    child: FutureBuilder<List<KeyValue>>(
                                      future: futurePassBy,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Maps(
                                            mapData: mapData,
                                            data: snapshot.data!,
                                            height: 800,
                                            startTimeMaxController:
                                                startTimeMaxController,
                                            startTimeMinController:
                                                startTimeMinController,
                                          );
                                        } else if (snapshot.hasError) {
                                          return Text('${snapshot.error}');
                                        }

                                        return const SizedBox();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const ResponsiveRowColumnItem(
                          rowFlex: 1, child: SizedBox()),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: _showFab ? Offset.zero : const Offset(0, 2),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showFab ? 1 : 0,
            child: SpeedDial(
              icon: Icons.add,
              activeIcon: Icons.close,
              spacing: 3,
              openCloseDial: isDialOpen,
              childPadding: const EdgeInsets.all(5),
              spaceBetweenChildren: 4,

              /// If false, backgroundOverlay will not be rendered.
              renderOverlay: renderOverlay,
              overlayColor: Colors.black,
              overlayOpacity: 0.3,
              useRotationAnimation: useRAnimation,
              tooltip: 'T???o m???i',

              animationSpeed: 200,
              childMargin:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              children: [
                SpeedDialChild(
                  child: const Icon(Icons.edit_outlined),
                  label: 'Khai b??o y t???',
                  onTap: () => Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .pushNamed(MedicalDeclarationScreen.routeName),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.description_outlined),
                  label: 'Phi???u x??t nghi???m',
                  onTap: () => Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .pushNamed(AddTest.routeName),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.person_add_alt),
                  label: 'Ng?????i c??ch ly',
                  onTap: () => Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .pushNamed(AddMember.routeName),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.manage_accounts_outlined),
                  label: 'Qu???n l??/C??n b???',
                  onTap: () => Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .pushNamed(AddManager.routeName),
                ),
                SpeedDialChild(
                  child: const Icon(Icons.business_outlined),
                  label: 'Khu c??ch ly',
                  onTap: () => Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .pushNamed(NewQuarantine.routeName),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
