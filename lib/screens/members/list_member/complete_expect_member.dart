import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:qlkcl/components/cards.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/members/component/buttons.dart';
import 'package:qlkcl/screens/members/component/menus.dart';
import 'package:qlkcl/screens/members/component/table.dart';
import 'package:qlkcl/screens/members/detail_member_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/member.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:intl/intl.dart';

DataPagerController _dataPagerController = DataPagerController();
TextEditingController keySearch = TextEditingController();

class ExpectCompleteMember extends StatefulWidget {
  const ExpectCompleteMember({
    Key? key,
    required this.longPressFlag,
    required this.indexList,
    required this.longPress,
    this.onDone = false,
    required this.onDoneCallback,
  }) : super(key: key);
  final bool longPressFlag;
  final List<String> indexList;
  final VoidCallback longPress;
  final bool onDone;
  final VoidCallback onDoneCallback;

  @override
  _ExpectCompleteMemberState createState() => _ExpectCompleteMemberState();
}

class _ExpectCompleteMemberState extends State<ExpectCompleteMember>
    with AutomaticKeepAliveClientMixin<ExpectCompleteMember> {
  final PagingController<int, FilterMember> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 10);
  final DataGridController _dataGridController = DataGridController();

  final GlobalKey<SfDataGridState> key = GlobalKey<SfDataGridState>();
  late DataSource dataSource;
  double pageCount = 0;
  List<FilterMember> paginatedDataSource = [];
  late Future<FilterResponse<FilterMember>> fetch;

  bool showLoadingIndicator = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _pagingController.addPageRequestListener(_fetchPage);
    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.subsequentPageError) {
        showNotification("C?? l???i x???y ra!", status: Status.error);
      }
    });
    super.initState();
    fetchMemberList(data: {
      "search": keySearch.text,
      'page': 1,
      'can_finish_quarantine': true
    }).then((data) {
      showLoadingIndicator = false;
      paginatedDataSource = data.data;
      pageCount = data.totalPages.toDouble();
      dataSource = DataSource(
        key,
        (value) {
          setState(() {
            pageCount = value;
          });
        },
        memberData: paginatedDataSource,
      );
      dataSource.buildDataGridRows();
      dataSource.updateDataGridSource();
      setState(() {});
    });
  }

  @override
  void dispose() {
    // _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchMemberList(data: {
        "search": keySearch.text,
        'page': pageKey,
        'can_finish_quarantine': true
      });

      final isLastPage = newItems.data.length < pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems.data);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems.data, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (widget.onDone == true) {
      widget.indexList.clear();
      widget.onDoneCallback();
      if (Responsive.isDesktopLayout(context)) {
        // key.currentState!.refresh();
      } else {
        _pagingController.refresh();
      }
    }

    return Responsive.isDesktopLayout(context)
        ? showLoadingIndicator
            ? const Align(
                child: CircularProgressIndicator(),
              )
            : paginatedDataSource.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: Image.asset("assets/images/no_data.png"),
                        ),
                        const Text('Kh??ng c?? d??? li???u'),
                      ],
                    ),
                  )
                : listMemberTable()
        : listMemberCard();
  }

  Widget listMemberCard() {
    return RefreshIndicator(
      onRefresh: () => Future.sync(
        () => {
          _pagingController.refresh(),
          widget.indexList.clear(),
          widget.longPress(),
        },
      ),
      child: PagedListView<int, FilterMember>(
        padding: const EdgeInsets.only(bottom: 70),
        pagingController: _pagingController,
        builderDelegate: PagedChildBuilderDelegate<FilterMember>(
          animateTransitions: true,
          noItemsFoundIndicatorBuilder: (context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.15,
                  child: Image.asset("assets/images/no_data.png"),
                ),
                const Text('Kh??ng c?? d??? li???u'),
              ],
            ),
          ),
          firstPageErrorIndicatorBuilder: (context) => const Center(
            child: Text('C?? l???i x???y ra'),
          ),
          itemBuilder: (context, item, index) => MemberCard(
            member: item,
            onTap: () {
              Navigator.of(context,
                      rootNavigator: !Responsive.isDesktopLayout(context))
                  .push(MaterialPageRoute(
                      builder: (context) =>
                          DetailMemberScreen(code: item.code)));
            },
            longPressEnabled: widget.longPressFlag,
            onLongPress: () {
              if (widget.indexList.contains(item.code)) {
                widget.indexList.remove(item.code);
              } else {
                widget.indexList.add(item.code);
              }
              widget.longPress();
            },
            menus: menus(
              context,
              item,
              pagingController: _pagingController,
              showMenusItems: [
                menusOptions.updateInfo,
                menusOptions.medicalDeclareHistory,
                menusOptions.testHistory,
                menusOptions.vaccineDoseHistory,
                menusOptions.completeQuarantine,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget listMemberTable() {
    return Card(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        searchBox(key, keySearch),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        buildFinishsButton(
                          context,
                          key,
                          widget.longPressFlag,
                          widget.indexList,
                          widget.longPress,
                          widget.onDone,
                          widget.onDoneCallback,
                        ),
                        buildExportingButton(key),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: SizedBox(
                  height: constraints.maxHeight - 120,
                  width: constraints.maxWidth,
                  child: buildStack(
                    key,
                    dataSource,
                    constraints,
                    showLoadingIndicator,
                    showColumnItems: [
                      columns.fullName,
                      columns.birthday,
                      columns.gender,
                      columns.phoneNumber,
                      columns.quarantineWard,
                      columns.quarantineLocation,
                      columns.label,
                      columns.quarantinedAt,
                      columns.quarantinedFinishExpectedAt,
                      columns.healthStatus,
                      columns.positiveTestNow,
                      columns.code,
                    ],
                    dataGridController: _dataGridController,
                    onSelectionChange: (List<DataGridRow> addedRows,
                        List<DataGridRow> removedRows) {
                      if (addedRows.isEmpty && removedRows.isEmpty) {
                        widget.indexList.clear();
                      } else {
                        for (final element in addedRows) {
                          if (!widget.indexList
                              .contains(element.getCells()[11].value)) {
                            widget.indexList.add(element.getCells()[11].value);
                          }
                        }

                        for (final element in removedRows) {
                          if (widget.indexList
                              .contains(element.getCells()[11].value)) {
                            widget.indexList
                                .remove(element.getCells()[11].value);
                          }
                        }
                      }
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 60,
                width: constraints.maxWidth,
                child: SfDataPager(
                  controller: _dataPagerController,
                  pageCount: pageCount,
                  delegate: dataSource,
                  onPageNavigationStart: (pageIndex) {
                    showLoading();
                  },
                  onPageNavigationEnd: (pageIndex) {
                    BotToast.closeAllLoading();
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class DataSource extends DataGridSource {
  DataSource(
    this.key,
    this.updatePageCount, {
    required List<FilterMember> memberData,
  }) {
    _paginatedRows = memberData;
    buildDataGridRows();
  }

  Function updatePageCount;
  GlobalKey<SfDataGridState> key;

  List<DataGridRow> _memberData = [];
  List<FilterMember> _paginatedRows = [];

  @override
  List<DataGridRow> get rows => _memberData;

  @override
  Future<bool> handlePageChange(int oldPageIndex, int newPageIndex) async {
    if (oldPageIndex != newPageIndex) {
      final newItems = await fetchMemberList(data: {
        "search": keySearch.text,
        'page': newPageIndex + 1,
        'can_finish_quarantine': true
      });
      _paginatedRows = newItems.data;
      updatePageCount(newItems.totalPages.toDouble());
      buildDataGridRows();
      notifyListeners();
      return true;
    }
    return false;
  }

  @override
  Future<void> handleRefresh() async {
    final int currentPageIndex = _dataPagerController.selectedPageIndex;
    final newItems = await fetchMemberList(data: {
      "search": keySearch.text,
      'page': currentPageIndex + 1,
      'can_finish_quarantine': true
    });
    _paginatedRows = newItems.data;
    updatePageCount(newItems.totalPages.toDouble());
    buildDataGridRows();
    notifyListeners();
  }

  void buildDataGridRows() {
    _memberData = _paginatedRows
        .map<DataGridRow>(
          (e) => DataGridRow(
            cells: [
              DataGridCell<String>(columnName: 'fullName', value: e.fullName),
              DataGridCell<DateTime?>(
                  columnName: 'birthday',
                  value: e.birthday != null
                      ? DateFormat('dd/MM/yyyy').parse(e.birthday!)
                      : null),
              DataGridCell<String>(columnName: 'gender', value: e.gender),
              DataGridCell<String>(
                  columnName: 'phoneNumber', value: e.phoneNumber),
              DataGridCell<String>(
                  columnName: 'quarantineWard',
                  value: e.quarantineWard?.name ?? ""),
              DataGridCell<String>(
                  columnName: 'quarantineLocation',
                  value: e.quarantineLocation),
              DataGridCell<String>(columnName: 'label', value: e.label),
              DataGridCell<DateTime?>(
                  columnName: 'quarantinedAt',
                  value: e.quarantinedAt != null
                      ? DateTime.parse(e.quarantinedAt!).toLocal()
                      : null),
              DataGridCell<DateTime?>(
                  columnName: 'quarantinedFinishExpectedAt',
                  value: e.quarantinedFinishExpectedAt != null
                      ? DateTime.parse(e.quarantinedFinishExpectedAt!).toLocal()
                      : null),
              DataGridCell<String>(
                  columnName: 'healthStatus', value: e.healthStatus),
              DataGridCell<String>(
                  columnName: 'positiveTestNow',
                  value: e.positiveTestNow.toString()),
              DataGridCell<String>(columnName: 'code', value: e.code),
            ],
          ),
        )
        .toList();
  }

  void updateDataGridSource() {
    notifyListeners();
  }

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: <Widget>[
        FutureBuilder(
          future: Future.delayed(Duration.zero, () => true),
          builder: (context, snapshot) {
            return Container(
              padding: const EdgeInsets.all(8),
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context,
                          rootNavigator: !Responsive.isDesktopLayout(context))
                      .push(MaterialPageRoute(
                          builder: (context) => DetailMemberScreen(
                                code: row.getCells()[11].value.toString(),
                              )));
                },
                child: Text(
                  row.getCells()[0].value.toString().isNotEmpty
                      ? row.getCells()[0].value.toString()
                      : row.getCells()[11].value.toString(),
                  style: TextStyle(
                    color: primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[1].value != null
                ? DateFormat('dd/MM/yyyy').format(row.getCells()[1].value)
                : "",
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child:
              Text(row.getCells()[2].value.toString() == "MALE" ? "Nam" : "N???"),
        ),
        Container(
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: Text(
              row.getCells()[3].value.toString(),
            )),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(
            row.getCells()[4].value.toString(),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          child: Text(row.getCells()[5].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(row.getCells()[6].value.toString()),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[7].value != null
                ? DateFormat('dd/MM/yyyy').format(row.getCells()[7].value)
                : "",
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[8].value != null
                ? DateFormat('dd/MM/yyyy').format(row.getCells()[8].value)
                : "",
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: row.getCells()[9].value.toString() == "SERIOUS"
                    ? error.withOpacity(0.25)
                    : row.getCells()[9].value.toString() == "UNWELL"
                        ? warning.withOpacity(0.25)
                        : success.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: row.getCells()[9].value.toString() == "SERIOUS"
                  ? Text(
                      "Nguy hi???m",
                      style: TextStyle(color: error),
                    )
                  : row.getCells()[9].value.toString() == "UNWELL"
                      ? Text(
                          "Kh??ng t???t",
                          style: TextStyle(color: warning),
                        )
                      : Text(
                          "B??nh th?????ng",
                          style: TextStyle(color: success),
                        ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              decoration: BoxDecoration(
                color: row.getCells()[10].value == "null"
                    ? secondaryText.withOpacity(0.25)
                    : row.getCells()[10].value == "true"
                        ? error.withOpacity(0.25)
                        : success.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: row.getCells()[10].value == "null"
                  ? Text(
                      "Ch??a c??",
                      style: TextStyle(color: secondaryText),
                    )
                  : row.getCells()[10].value == "true"
                      ? Text(
                          "D????ng t??nh",
                          style: TextStyle(color: error),
                        )
                      : Text(
                          "??m t??nh",
                          style: TextStyle(color: success),
                        ),
            )
          ],
        ),
        FutureBuilder(
          future: Future.delayed(Duration.zero, () => true),
          builder: (context, snapshot) {
            return !snapshot.hasData
                ? const SizedBox()
                : menus(
                    context,
                    _paginatedRows.safeFirstWhere(
                        (e) => e.code == row.getCells()[11].value.toString())!,
                    tableKey: key,
                    showMenusItems: [
                      menusOptions.updateInfo,
                      menusOptions.medicalDeclareHistory,
                      menusOptions.testHistory,
                      menusOptions.vaccineDoseHistory,
                      menusOptions.completeQuarantine,
                    ],
                  );
          },
        ),
      ],
    );
  }
}
