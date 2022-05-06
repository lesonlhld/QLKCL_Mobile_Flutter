import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/member.dart';
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
              tooltip: "Thêm người cách ly",
            )
          : null,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                title: longPressFlag
                    ? Text('${indexList.length} đã chọn')
                    : const Text("Danh sách người cách ly"),
                centerTitle: true,
                actions: [
                  if (longPressFlag)
                    PopupMenuButton(
                      icon: const Icon(
                        Icons.more_vert,
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                        PopupMenuItem(
                          child: const Text('Chấp nhận'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui lòng chọn tài khoản cần xét duyệt!",
                                  status: Status.error);
                            } else {
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
                            }
                          },
                        ),
                        PopupMenuItem(
                          child: const Text('Từ chối'),
                          onTap: () async {
                            if (indexList.isEmpty) {
                              showNotification(
                                  "Vui lòng chọn tài khoản cần xét duyệt!",
                                  status: Status.error);
                            } else {
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
                      tooltip: "Tìm kiếm",
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
                    Tab(text: "Đang cách ly"),
                    Tab(text: "Chờ xét duyệt"),
                    Tab(text: "Nghi nhiễm"),
                    Tab(text: "Tới hạn xét nghiệm"),
                    Tab(text: "Cần chuyển phòng"),
                    Tab(text: "Dương tính"),
                    Tab(text: "Có thể hoàn thành cách ly"),
                    Tab(text: "Đã từ chối"),
                    Tab(text: "Đã hoàn thành cách ly"),
                    Tab(text: "Đã chuyển viện"),
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
            const NeedTestMember(),
            const NeedChangeRoomMember(),
            const PositiveMember(),
            const ExpectCompleteMember(),
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
                            ? constraints.maxHeight - 140
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
