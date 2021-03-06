import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/cards.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/quarantine.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/manager/list_all_manager_screen.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:websafe_svg/websafe_svg.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'carousel.dart';
import 'carousel_building.dart';
import 'package:url_launcher/url_launcher.dart';

class QuarantineInfo extends StatefulWidget {
  final Quarantine quarantineInfo;
  const QuarantineInfo({
    Key? key,
    required this.quarantineInfo,
  }) : super(key: key);

  @override
  _QuarantineInfoState createState() => _QuarantineInfoState();
}

class _QuarantineInfoState extends State<QuarantineInfo> {
  late Future<dynamic> futureBuildingList;

  @override
  void initState() {
    super.initState();
    futureBuildingList = fetchBuildingList({
      'quarantine_ward': widget.quarantineInfo.id,
      'page_size': pageSizeMax,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Carousel(image: widget.quarantineInfo.image),
          const SizedBox(
            height: 10,
          ),
          //Name and icon
          Container(
            margin: const EdgeInsets.only(
              left: 23,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.quarantineInfo.fullName,
                        //quarantineName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(
                        height: 6,
                      ),
                      Text(
                        (widget.quarantineInfo.address != null
                                ? "${widget.quarantineInfo.address}, "
                                : "") +
                            (widget.quarantineInfo.ward != null
                                ? "${widget.quarantineInfo.ward['name']}, "
                                : "") +
                            (widget.quarantineInfo.district != null
                                ? "${widget.quarantineInfo.district['name']}, "
                                : "") +
                            (widget.quarantineInfo.city != null
                                ? "${widget.quarantineInfo.city['name']}"
                                : ""),
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 15,
                          color: Color.fromRGBO(138, 149, 158, 1),
                        ),
                      ),
                    ],
                  ),
                ),

                //Button
                Row(
                  children: [
                    IconButton(
                      iconSize: 38,
                      onPressed: widget.quarantineInfo.phoneNumber != null
                          ? () async {
                              launch(
                                  "tel://${widget.quarantineInfo.phoneNumber}");
                            }
                          : () {
                              showNotification('S??? ??i???n tho???i kh??ng t???n t???i.',
                                  status: Status.error);
                            },
                      icon: WebsafeSvg.asset("assets/svg/Phone.svg"),
                    ),
                    IconButton(
                        iconSize: 38,
                        onPressed: (widget.quarantineInfo.latitude != null &&
                                widget.quarantineInfo.longitude != null)
                            ? () async {
                                final String googleUrl =
                                    'https://www.google.com/maps/search/?api=1&query=${widget.quarantineInfo.latitude},${widget.quarantineInfo.longitude}';
                                if (await canLaunch(googleUrl)) {
                                  await launch(googleUrl);
                                } else {
                                  showNotification('Kh??ng th??? m??? b???n ?????.',
                                      status: Status.error);
                                }
                              }
                            : () {
                                showNotification('Kh??ng th??? x??c ?????nh v??? tr??.',
                                    status: Status.error);
                              },
                        icon: WebsafeSvg.asset("assets/svg/Location.svg"))
                  ],
                ),
              ],
            ),
          ),

          FutureBuilder<dynamic>(
            future: futureBuildingList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return CarouselBuilding(
                    data: snapshot.data,
                    currentQuarantine: widget.quarantineInfo,
                  );
                } else if (snapshot.hasError) {
                  return const Text('Snapshot has error');
                } else {
                  return const Text(
                    'Kh??ng c?? d??? li???u',
                    textAlign: TextAlign.center,
                  );
                }
              }
              return const SizedBox();
            },
          ),

          //Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: const Text(
                          'Th??ng tin',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ListAllManager(
                                currentQuarrantine: KeyValue(
                                    name: widget.quarantineInfo.fullName,
                                    id: widget.quarantineInfo.id),
                              ),
                            ),
                          );
                        },
                        child: const Text('Danh s??ch qu???n l??, c??n b???'),
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(primary),
                        ),
                      )
                    ],
                  ),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.medical_services_outlined,
                      title: "D???ch b???nh c??ch ly",
                      content: widget.quarantineInfo.pandemic?.name ??
                          "Ch??a c?? th??ng tin"),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.history,
                      title: "Th???i gian c??ch ly",
                      content:
                          '${widget.quarantineInfo.pandemic?.quarantineTimeNotVac} ng??y'),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.hotel_outlined,
                      title: "T???ng s??? gi?????ng",
                      content: '${widget.quarantineInfo.capacity} gi?????ng'),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.groups_outlined,
                      title: "??ang c??ch ly",
                      content: '${widget.quarantineInfo.currentMem} ng?????i'),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.account_box_outlined,
                      title: "Qu???n l??",
                      content:
                          '${widget.quarantineInfo.mainManager["full_name"]}'),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.place_outlined,
                      title: "?????a ch???",
                      content:
                          '${widget.quarantineInfo.address != null ? "${widget.quarantineInfo.address}, " : ""}${widget.quarantineInfo.ward != null ? "${widget.quarantineInfo.ward['name']}, " : ""}${widget.quarantineInfo.district != null ? "${widget.quarantineInfo.district['name']}, " : ""}${widget.quarantineInfo.city != null ? "${widget.quarantineInfo.city['name']}" : ""}'),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.phone,
                      title: "S??? ??i???n tho???i",
                      content: widget.quarantineInfo.phoneNumber ?? "Ch??a c??"),
                  cardLine(
                      topPadding: 8,
                      textColor: secondaryText,
                      icon: Icons.email_outlined,
                      title: "Email",
                      content: widget.quarantineInfo.email),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      ),
    );
  }
}
