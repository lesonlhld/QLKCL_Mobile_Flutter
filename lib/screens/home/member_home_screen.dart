import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/covid_data.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/medical_declaration.dart';
import 'package:qlkcl/networking/api_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/destination_history/destination_history_screen.dart';
import 'package:qlkcl/screens/home/component/app_bar.dart';
import 'package:qlkcl/screens/home/component/card.dart';
import 'package:qlkcl/screens/home/component/covid_info.dart';
import 'package:qlkcl/screens/home/component/requarantined.dart';
import 'package:qlkcl/screens/notification/create_request_screen.dart';
import 'package:qlkcl/screens/quarantine_ward/component/quarantine_maps.dart';
import 'package:qlkcl/utils/api.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/screens/medical_declaration/medical_declaration_screen.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher.dart';

class MemberHomePage extends StatefulWidget {
  static const String routeName = "/member_home";
  const MemberHomePage({Key? key}) : super(key: key);

  @override
  _MemberHomePageState createState() => _MemberHomePageState();
}

class _MemberHomePageState extends State<MemberHomePage> {
  late Future<CovidData> futureCovid;
  late Future<dynamic> futureData;
  late Future<HealthInfo> futureHealth;
  HealthInfo? healthData;

  List<KeyValue> quarantineWardList = [];

  @override
  void initState() {
    super.initState();
    futureCovid = fetchCovidList();
    futureData = fetch();
    futureHealth = getHeathInfo();
    fetchQuarantineWardNoToken({
      'is_full': "false",
    }).then((value) {
      if (mounted) {
        setState(() {
          quarantineWardList = value;
        });
      }
    });
  }

  Future<dynamic> fetch() async {
    final ApiHelper api = ApiHelper();
    final response = await api.postHTTP(Api.homeMember, null);
    return response != null && response['data'] != null
        ? response['data']
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: RefreshIndicator(
        onRefresh: () => Future.sync(() {
          setState(() {
            futureCovid = fetchCovidList();
            futureData = fetch();
            futureHealth = getHeathInfo();
          });
        }),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              FutureBuilder<dynamic>(
                future: futureData,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var msg = "";
                    if (snapshot.data['custom_user']['status'] == "WAITING") {
                      msg =
                          "T??i kho???n c???a b???n ch??a ???????c x??t duy???t. Vui l??ng ch??? ho???c li??n h??? v???i qu???n l?? khu c??ch ly!";
                    } else if (snapshot.data['custom_user']['status'] ==
                        "REFUSED") {
                      msg =
                          "T??i kho???n c???a b???n ???? b??? t??? ch???i. Vui l??ng li??n h??? v???i qu???n l?? khu c??ch ly!";
                    } else if (snapshot.data['custom_user']['status'] ==
                        "LOCKED") {
                      msg =
                          "T??i kho???n c???a b???n ???? b??? kh??a. Vui l??ng li??n h??? v???i qu???n l?? khu c??ch ly!";
                    } else if (snapshot.data['custom_user']['status'] ==
                        "LEAVE") {
                      msg =
                          "T??i kho???n c???a b???n kh??ng c??n ho???t ?????ng trong h??? th???ng. Vui l??ng li??n h??? v???i qu???n l?? ho???c ????ng k?? t??i c??ch ly!";
                    }
                    return Column(
                      children: [
                        ResponsiveRowColumn(
                          layout:
                              MediaQuery.of(context).size.width < minDesktopSize
                                  ? ResponsiveRowColumnType.COLUMN
                                  : ResponsiveRowColumnType.ROW,
                          rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                          rowCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (msg != "")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: Card(
                                  margin: MediaQuery.of(context).size.width >
                                          minDesktopSize
                                      ? const EdgeInsets.fromLTRB(16, 8, 8, 0)
                                      : null,
                                  child: ListTile(
                                    isThreeLine: true,
                                    contentPadding: const EdgeInsets.all(8),
                                    title: Text(
                                      msg,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.normal,
                                          color: primaryText),
                                    ),
                                    minVerticalPadding: 10,
                                    subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Khu c??ch ly: ${(snapshot.data['quarantine_ward'] != null && snapshot.data['quarantine_ward']['full_name'] != "") ? snapshot.data['quarantine_ward']['full_name'] : "Kh??ng r??"}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: primaryText),
                                            ),
                                            const SizedBox(
                                              height: 8,
                                            ),
                                            Text(
                                              "S??? ??i???n tho???i: ${(snapshot.data['quarantine_ward'] != null && snapshot.data['quarantine_ward']['phone_number'] != "") ? snapshot.data['quarantine_ward']['phone_number'] : "Ch??a c??"}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.normal,
                                                  color: primaryText),
                                            ),
                                          ],
                                        )),
                                    leading: CircleAvatar(
                                      backgroundColor: error,
                                      child: Icon(
                                        Icons.notification_important_outlined,
                                        color: white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            if (snapshot.data['quarantine_ward'] != null &&
                                msg == "")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: QuarantineHome(
                                  room: getRoom(snapshot.data),
                                  quarantineAt: snapshot.data['quarantined_at'],
                                  quarantineFinishExpect: snapshot
                                      .data['quarantined_finish_expected_at'],
                                  status: snapshot.data['quarantined_status'] ==
                                          "HOSPITALIZE"
                                      ? "???? chuy???n vi???n"
                                      : snapshot.data['quarantined_status'] ==
                                              "QUARANTINING"
                                          ? "??ang c??ch ly"
                                          : "??ang c??ch ly & Ch??? chuy???n vi???n",
                                ),
                              ),
                            if (snapshot.data['custom_user']['status'] ==
                                    "LEAVE" &&
                                snapshot.data['quarantined_status'] ==
                                    "COMPLETED")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: QuarantineFinishCertification(
                                  name: snapshot.data['quarantine_ward'] != null
                                      ? snapshot.data['quarantine_ward']
                                          ['full_name']
                                      : "",
                                  quarantineAt: snapshot.data['quarantined_at'],
                                  quarantineFinishAt:
                                      snapshot.data['quarantined_finished_at'],
                                ),
                              ),
                            if (snapshot.data['custom_user']['status'] ==
                                    "LEAVE" &&
                                snapshot.data['quarantined_status'] ==
                                    "HOSPITALIZE")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: Hospitalization(
                                  quarantineAt: snapshot.data['quarantined_at'],
                                  hospitalName:
                                      snapshot.data['hospitalize_info']
                                          ['hospital_name'],
                                  hospitalizeAt:
                                      snapshot.data['hospitalize_info']['time'],
                                ),
                              ),
                            ResponsiveRowColumnItem(
                              rowFlex: 5,
                              rowFit: FlexFit.tight,
                              child: FutureBuilder<HealthInfo>(
                                future: futureHealth,
                                builder: (context, snapshot2) {
                                  if (snapshot2.hasData) {
                                    healthData = snapshot2.data;
                                    return HealthStatus(
                                      healthStatus:
                                          snapshot.data['health_status'],
                                      lastHealthStatusTime: snapshot
                                          .data['last_health_status_time'],
                                      positiveTestNow:
                                          snapshot.data['positive_test_now'],
                                      lastTestedHadResult: snapshot
                                          .data['last_tested_had_result'],
                                      numberOfVaccineDoses: snapshot
                                          .data['number_of_vaccine_doses'],
                                      healthData: healthData,
                                    );
                                  } else if (snapshot2.hasError) {
                                    return Text('${snapshot2.error}');
                                  }

                                  return HealthStatus(
                                      healthStatus:
                                          snapshot.data['health_status'],
                                      lastHealthStatusTime: snapshot
                                          .data['last_health_status_time'],
                                      positiveTestNow:
                                          snapshot.data['positive_test_now'],
                                      lastTestedHadResult: snapshot
                                          .data['last_tested_had_result'],
                                      numberOfVaccineDoses: snapshot
                                          .data['number_of_vaccine_doses']);
                                },
                              ),
                            ),
                          ],
                        ),
                        FutureBuilder<HealthInfo>(
                          future: futureHealth,
                          builder: (context, snapshot2) {
                            if (snapshot2.hasData) {
                              healthData = snapshot2.data;
                              return HealthStatusData(
                                healthStatus: snapshot.data['health_status'],
                                lastHealthStatusTime:
                                    snapshot.data['last_health_status_time'],
                                positiveTestNow:
                                    snapshot.data['positive_test_now'],
                                lastTestedHadResult:
                                    snapshot.data['last_tested_had_result'],
                                numberOfVaccineDoses:
                                    snapshot.data['number_of_vaccine_doses'],
                                healthData: healthData,
                              );
                            } else if (snapshot2.hasError) {
                              return Text('${snapshot2.error}');
                            }

                            return HealthStatusData(
                                healthStatus: snapshot.data['health_status'],
                                lastHealthStatusTime:
                                    snapshot.data['last_health_status_time'],
                                positiveTestNow:
                                    snapshot.data['positive_test_now'],
                                lastTestedHadResult:
                                    snapshot.data['last_tested_had_result'],
                                numberOfVaccineDoses:
                                    snapshot.data['number_of_vaccine_doses']);
                          },
                        ),
                        ResponsiveRowColumn(
                          layout:
                              MediaQuery.of(context).size.width < minDesktopSize
                                  ? ResponsiveRowColumnType.COLUMN
                                  : ResponsiveRowColumnType.ROW,
                          rowSpacing: 16,
                          columnSpacing: 16,
                          rowPadding: const EdgeInsets.all(16),
                          columnPadding: const EdgeInsets.all(16),
                          rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                          rowCrossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (snapshot.data['custom_user']['status'] ==
                                "LEAVE")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                  ),
                                  onPressed: () {
                                    memberRequarantined(
                                      context,
                                      quarantineWardList: quarantineWardList,
                                      useCustomBottomSheetMode:
                                          ResponsiveWrapper.of(context)
                                              .isLargerThan(MOBILE),
                                    ).then((value) {
                                      if (value != null &&
                                          value.status == Status.success) {
                                        setState(() {
                                          futureData = fetch();
                                        });
                                      }
                                    });
                                  },
                                  child: Text(
                                    '????ng k?? t??i c??ch ly',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            if (snapshot.data['custom_user']['status'] ==
                                    "AVAILABLE" &&
                                snapshot.data['quarantine_ward'] != null &&
                                snapshot.data['quarantine_ward']
                                        ['phone_number'] !=
                                    "")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                    primary: error,
                                  ),
                                  onPressed:
                                      (snapshot.data['quarantine_ward'] !=
                                                  null &&
                                              snapshot.data['quarantine_ward']
                                                      ['phone_number'] !=
                                                  "")
                                          ? () async {
                                              launch(
                                                  "tel://${snapshot.data['quarantine_ward']['phone_number']}");
                                            }
                                          : () {
                                              showNotification(
                                                  'S??? ??i???n tho???i kh??ng t???n t???i.',
                                                  status: Status.error);
                                            },
                                  child: Text(
                                    'G???i c???p c???u',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            if (snapshot.data['custom_user']['status'] ==
                                "AVAILABLE")
                              ResponsiveRowColumnItem(
                                rowFlex: 5,
                                rowFit: FlexFit.tight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize:
                                        const Size(double.infinity, 48),
                                    primary: warning,
                                  ),
                                  onPressed: () => Navigator.of(context,
                                          rootNavigator:
                                              !Responsive.isDesktopLayout(
                                                  context))
                                      .push(MaterialPageRoute(
                                          builder: (context) => CreateRequest(
                                                quarantineLocation:
                                                    getRoom(snapshot.data),
                                                userName:
                                                    snapshot.data['custom_user']
                                                        ['full_name'],
                                              ))),
                                  child: Text(
                                    'Ph???n ??nh/y??u c???u',
                                    style: TextStyle(
                                      color: white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ResponsiveRowColumnItem(
                              rowFlex: 5,
                              rowFit: FlexFit.tight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  primary: secondary,
                                ),
                                onPressed: () {
                                  Navigator.of(context,
                                          rootNavigator:
                                              !Responsive.isDesktopLayout(
                                                  context))
                                      .pushNamed(
                                          MedicalDeclarationScreen.routeName);
                                },
                                child: Text(
                                  'Khai b??o y t???',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            ResponsiveRowColumnItem(
                              rowFlex: 5,
                              rowFit: FlexFit.tight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 48),
                                  primary: success,
                                ),
                                onPressed: () {
                                  Navigator.of(context,
                                          rootNavigator:
                                              !Responsive.isDesktopLayout(
                                                  context))
                                      .pushNamed(
                                          DestinationHistoryScreen.routeName);
                                },
                                child: Text(
                                  'Khai b??o di chuy???n',
                                  style: TextStyle(
                                    color: white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }

                  // By default, show a loading spinner.
                  // return const CircularProgressIndicator();
                  return const SizedBox();
                },
              ),
              ResponsiveRowColumn(
                layout: MediaQuery.of(context).size.width < minDesktopSize
                    ? ResponsiveRowColumnType.COLUMN
                    : ResponsiveRowColumnType.ROW,
                rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                rowCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: Card(
                      margin: MediaQuery.of(context).size.width > minDesktopSize
                          ? const EdgeInsets.fromLTRB(16, 8, 8, 0)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Th??ng tin d???ch b???nh Covid-19 (Vi???t Nam)",
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
                                return const InfoCovidHomePage();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    rowFlex: 1,
                    child: Container(
                      width: double.infinity,
                      height: 800,
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        margin:
                            MediaQuery.of(context).size.width > minDesktopSize
                                ? const EdgeInsets.fromLTRB(8, 8, 16, 0)
                                : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: const [
                              Text(
                                "C??c khu c??ch ly",
                                style: TextStyle(fontSize: 18),
                              ),
                              SizedBox(
                                height: 8,
                              ),
                              Expanded(
                                child: QuanrantineMaps(
                                  canZoom: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
