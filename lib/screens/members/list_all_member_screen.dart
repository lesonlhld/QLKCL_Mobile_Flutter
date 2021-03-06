import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/popup.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/member.dart';
import 'package:qlkcl/models/test.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/members/list_member/completed_member.dart';
import 'package:qlkcl/screens/members/list_member/hospitalized_member.dart';
import 'package:qlkcl/screens/members/list_member/need_change_room_member.dart';
import 'package:qlkcl/screens/members/list_member/positive_member.dart';
import 'package:qlkcl/screens/members/search_member.dart';
import 'package:qlkcl/screens/members/add_member_screen.dart';
import 'package:qlkcl/screens/members/list_member/active_member.dart';
import 'package:qlkcl/screens/members/list_member/complete_expect_member.dart';
import 'package:qlkcl/screens/members/list_member/confirm_member.dart';
import 'package:qlkcl/screens/members/list_member/denied_member.dart';
import 'package:qlkcl/screens/members/list_member/suspect_member.dart';
import 'package:qlkcl/screens/members/list_member/need_test_member.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/constant.dart';

// cre: https://stackoverflow.com/questions/50462281/flutter-i-want-to-select-the-card-by-onlongpress

class ListAllMember extends StatefulWidget {
  static const String routeName = "/list_all_member";
  final int tab;
  const ListAllMember({Key? key, this.tab = 0}) : super(key: key);

  @override
  _ListAllMemberState createState() => _ListAllMemberState();
}

class _ListAllMemberState extends State<ListAllMember>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 10, vsync: this, initialIndex: widget.tab);
    _tabController.addListener(_handleTabChange);
  }

  _handleTabChange() {
    setState(() {
      indexList.clear();
      longPress();
    });
  }

  bool longPressFlag = false;
  List<String> indexList = [];

  void longPress() {
    setState(() {
      if (indexList.isEmpty) {
        longPressFlag = false;
      } else {
        longPressFlag = true;
      }
    });
  }

  bool onDone = false;
  void onDoneCallback() {
    onDone = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              heroTag: "member_fab",
              onPressed: () {
                Navigator.of(context,
                        rootNavigator: !Responsive.isDesktopLayout(context))
                    .pushNamed(
                  AddMember.routeName,
                );
              },
              child: const Icon(Icons.add),
              tooltip: "Th??m ng?????i c??ch ly",
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: longPressFlag
                    ? Text('${indexList.length} ???? ch???n')
                    : const Text("Danh s??ch ng?????i c??ch ly"),
                centerTitle: true,
                actions: [
                  if (longPressFlag && _tabController.index == 1)
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert,
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: const Text('Ch???p nh???n'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui l??ng ch???n t??i kho???n c???n x??t duy???t!",
                                  status: Status.error);
                            } else {
                              await confirmAlertPopup(
                                context,
                                content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'X??c nh???n ?????ng ?? c??ch ly cho nh???ng ng?????i ???? ch???n',
                                        style: TextStyle(color: primaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                confirmAction: () async {
                                  final CancelFunc cancel = showLoading();
                                  final response = await acceptManyMember(
                                      {'member_codes': indexList.join(",")});
                                  cancel();
                                  if (response.status == Status.success) {
                                    setState(() {
                                      onDone = true;
                                    });
                                    indexList.clear();
                                    longPress();
                                  }
                                },
                              );
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('T??? ch???i'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui l??ng ch???n t??i kho???n c???n x??t duy???t!",
                                  status: Status.error);
                            } else {
                              await confirmAlertPopup(
                                context,
                                content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'X??c nh???n t??? ch???i c??ch ly cho nh???ng ng?????i ???? ch???n',
                                        style: TextStyle(color: primaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                confirmAction: () async {
                                  final CancelFunc cancel = showLoading();
                                  final response = await denyMember(
                                      {'member_codes': indexList.join(",")});
                                  cancel();
                                  showNotification(response);
                                  if (response.status == Status.success) {
                                    setState(() {
                                      onDone = true;
                                    });
                                    indexList.clear();
                                    longPress();
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    )
                  else if (longPressFlag && _tabController.index == 3)
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert,
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: const Text('T???o x??t nghi???m'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui l??ng ch???n t??i kho???n c???n t???o x??t nghi???m!",
                                  status: Status.error);
                            } else {
                              final formKey = GlobalKey<FormState>();
                              final typeController =
                                  TextEditingController(text: "QUICK");
                              await confirmAlertPopup(
                                context,
                                content: Form(
                                  key: formKey,
                                  child: Column(
                                    children: <Widget>[
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text:
                                                  'X??c nh???n t???o x??t nghi???m cho nh???ng ng?????i ???? ch???n',
                                              style:
                                                  TextStyle(color: primaryText),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DropdownInput<KeyValue>(
                                        label: 'K??? thu???t x??t nghi???m',
                                        hint: 'Ch???n k??? thu???t x??t nghi???m',
                                        itemValue: testTypeList,
                                        itemAsString: (KeyValue? u) => u!.name,
                                        maxHeight: 112,
                                        compareFn: (item, selectedItem) =>
                                            item?.id == selectedItem?.id,
                                        selectedItem: testTypeList
                                            .safeFirstWhere((type) =>
                                                type.id == typeController.text),
                                        onChanged: (value) {
                                          if (value == null) {
                                            typeController.text = "";
                                          } else {
                                            typeController.text = value.id;
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                confirmAction: () async {
                                  final CancelFunc cancel = showLoading();
                                  final response = await createManyTests({
                                    'user_codes': indexList.join(","),
                                    'type': typeController.text
                                  });
                                  cancel();
                                  if (response.status == Status.success) {
                                    setState(() {
                                      onDone = true;
                                    });
                                    indexList.clear();
                                    longPress();
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    )
                  else if (longPressFlag && _tabController.index == 6)
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert,
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: const Text('Ho??n th??nh c??ch ly'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui l??ng ch???n t??i kho???n c???n ho??n th??nh c??ch ly!",
                                  status: Status.error);
                            } else {
                              await confirmAlertPopup(
                                context,
                                content: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            'X??c nh???n ho??n th??nh c??ch ly cho nh???ng ng?????i ???? ch???n',
                                        style: TextStyle(color: primaryText),
                                      ),
                                    ],
                                  ),
                                ),
                                confirmAction: () async {
                                  final CancelFunc cancel = showLoading();
                                  final response = await finishMember(
                                      {'member_codes': indexList.join(",")});
                                  cancel();
                                  if (response.status == Status.success) {
                                    setState(() {
                                      onDone = true;
                                    });
                                    indexList.clear();
                                    longPress();
                                  }
                                },
                              );
                            }
                          },
                        ),
                      ],
                    )
                  else
                    IconButton(
                      onPressed: () {
                        Navigator.of(context,
                                rootNavigator:
                                    !Responsive.isDesktopLayout(context))
                            .push(MaterialPageRoute(
                                builder: (context) => const SearchMember()));
                      },
                      icon: const Icon(Icons.search),
                      tooltip: "T??m ki???m",
                    ),
                ],
                pinned: true,
                floating: !Responsive.isDesktopLayout(context),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: white,
                  tabs: const [
                    Tab(text: "??ang c??ch ly"),
                    Tab(text: "Ch??? x??t duy???t"),
                    Tab(text: "Nghi nhi???m"),
                    Tab(text: "T???i h???n x??t nghi???m"),
                    Tab(text: "C???n chuy???n ph??ng"),
                    Tab(text: "D????ng t??nh"),
                    Tab(text: "C?? th??? ho??n th??nh c??ch ly"),
                    Tab(text: "???? t??? ch???i"),
                    Tab(text: "???? ho??n th??nh c??ch ly"),
                    Tab(text: "???? chuy???n vi???n"),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            const ActiveMember(),
            ConfirmMember(
              longPressFlag: longPressFlag,
              indexList: indexList,
              longPress: longPress,
              onDone: onDone,
              onDoneCallback: onDoneCallback,
            ),
            const SuspectMember(),
            NeedTestMember(
              longPressFlag: longPressFlag,
              indexList: indexList,
              longPress: longPress,
              onDone: onDone,
              onDoneCallback: onDoneCallback,
            ),
            const NeedChangeRoomMember(),
            const PositiveMember(),
            ExpectCompleteMember(
              longPressFlag: longPressFlag,
              indexList: indexList,
              longPress: longPress,
              onDone: onDone,
              onDoneCallback: onDoneCallback,
            ),
            const DeniedMember(),
            const CompletedMember(),
            const HospitalizedMember(),
          ].map((e) {
            return LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverOverlapInjector(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                    ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                        child: e,
                        width: constraints.maxWidth,
                        height: Responsive.isDesktopLayout(context)
                            ? constraints.maxHeight - 120
                            : constraints.maxHeight - 20,
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
