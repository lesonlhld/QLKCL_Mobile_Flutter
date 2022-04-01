import 'package:flutter/material.dart';
import 'package:qlkcl/components/cards.dart';
import 'package:qlkcl/components/filters.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/quarantine.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';

class SearchQuarantine extends StatefulWidget {
  const SearchQuarantine({Key? key}) : super(key: key);

  @override
  _SearchQuarantineState createState() => _SearchQuarantineState();
}

class _SearchQuarantineState extends State<SearchQuarantine> {
  TextEditingController keySearch = TextEditingController();
  TextEditingController createAtMinController = TextEditingController();
  TextEditingController createAtMaxController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController wardController = TextEditingController();
  TextEditingController mainManagerController = TextEditingController();

  List<KeyValue> _cityList = [];
  List<KeyValue> _districtList = [];
  List<KeyValue> _wardList = [];
  List<KeyValue> managerList = [];

  bool _searched = false;

  late Future<dynamic> futureQuarantineList;
  final PagingController<int, dynamic> _pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 10);

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    _pagingController.addStatusListener((status) {
      if (status == PagingStatus.subsequentPageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Có lỗi xảy ra!',
            ),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: () => _pagingController.retryLastFailedRequest(),
            ),
          ),
        );
      }
    });

    super.initState();
    fetchCity({'country_code': 'VNM'}).then((value) {
      if (this.mounted)
        setState(() {
          _cityList = value;
        });
    });
    fetchDistrict({'city_id': cityController.text}).then((value) {
      if (this.mounted)
        setState(() {
          _districtList = value;
        });
    });
    fetchWard({'district_id': districtController.text}).then((value) {
      if (this.mounted)
        setState(() {
          _wardList = value;
        });
    });
    fetchNotMemberList({'role_name_list': 'MANAGER'}).then((value) {
      if (this.mounted)
        setState(() {
          managerList = value;
        });
    });
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final newItems = await fetchQuarantineList(
        data: filterQuarantineDataForm(
          keySearch: keySearch.text,
          page: pageKey,
          createAtMin:
              parseDateToDateTimeWithTimeZone(createAtMinController.text),
          createAtMax:
              parseDateToDateTimeWithTimeZone(createAtMaxController.text),
          city: cityController.text,
          district: districtController.text,
          ward: wardController.text,
          mainManager: mainManagerController.text,
        ),
      );

      final isLastPage = newItems.length < PAGE_SIZE;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: 0.0,
          title: Container(
            width: double.infinity,
            height: 36,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(30)),
            child: Center(
              child: TextField(
                maxLines: 1,
                autofocus: true,
                style: TextStyle(fontSize: 17),
                textAlignVertical: TextAlignVertical.center,
                controller: keySearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search,
                    color: CustomColors.secondaryText,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      /* Clear the search field */
                      keySearch.clear();
                      setState(() {
                        _searched = false;
                      });
                    },
                  ),
                  hintText: 'Tìm kiếm...',
                  border: InputBorder.none,
                  filled: false,
                ),
                onSubmitted: (v) {
                  setState(() {
                    _searched = true;
                  });
                  _pagingController.refresh();
                },
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                quarantineFilter(
                  context,
                  cityController: cityController,
                  districtController: districtController,
                  wardController: wardController,
                  mainManagerController: mainManagerController,
                  cityList: _cityList,
                  districtList: _districtList,
                  wardList: _wardList,
                  managerList: managerList,
                  onSubmit: (
                    cityList,
                    districtList,
                    wardList,
                    search,
                  ) {
                    setState(() {
                      _searched = search;
                      _cityList = cityList;
                      _districtList = districtList;
                      _wardList = wardList;
                    });
                    _pagingController.refresh();
                  },
                  useCustomBottomSheetMode:
                      ResponsiveWrapper.of(context).isLargerThan(MOBILE),
                );
              },
              icon: Icon(Icons.filter_list_outlined),
              tooltip: "Lọc",
            )
          ],
        ),
        body: _searched
            ? MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: PagedListView<int, dynamic>(
                  padding: EdgeInsets.only(bottom: 16),
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<dynamic>(
                    animateTransitions: true,
                    noItemsFoundIndicatorBuilder: (context) => Center(
                      child: Text('Không có kết quả tìm kiếm'),
                    ),
                    firstPageErrorIndicatorBuilder: (context) => Center(
                      child: Text('Có lỗi xảy ra'),
                    ),
                    itemBuilder: (context, item, index) => QuarantineItem(
                      id: item['id'].toString(),
                      name: item['full_name'] ?? "",
                      currentMem: item['num_current_member'],
                      manager: item['main_manager']['full_name'] ?? "",
                      address: getAddress(item),
                    ),
                  ),
                ),
              )
            : Center(
                child: Text('Tìm kiếm khu cách ly'),
              ),
      ),
    );
  }
}
