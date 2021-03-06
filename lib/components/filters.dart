import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qlkcl/components/date_input.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:responsive_framework/responsive_framework.dart';

//Widget for custom modal bottom sheet
class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({Key? key, required this.child, this.backgroundColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Center(
      child: Container(
        width: maxMobileSize,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: backgroundColor,
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
        ),
      ),
    ));
  }
}

Future memberFilter(
  BuildContext context, {
  required TextEditingController quarantineWardController,
  required TextEditingController quarantineBuildingController,
  required TextEditingController quarantineFloorController,
  required TextEditingController quarantineRoomController,
  required TextEditingController quarantineAtMinController,
  required TextEditingController quarantineAtMaxController,
  required TextEditingController quarantinedFinishExpectedAtMinController,
  required TextEditingController quarantinedFinishExpectedAtMaxController,
  required TextEditingController labelController,
  required TextEditingController healthStatusController,
  required TextEditingController testController,
  required TextEditingController careStaffController,
  required List<KeyValue> quarantineWardList,
  required List<KeyValue> quarantineBuildingList,
  required List<KeyValue> quarantineFloorList,
  required List<KeyValue> quarantineRoomList,
  required List<KeyValue> careStaffList,
  required void Function(
    List<KeyValue> quarantineWardList,
    List<KeyValue> quarantineBuildingList,
    List<KeyValue> quarantineFloorList,
    List<KeyValue> quarantineRoomList,
    List<KeyValue> careStaffList,
    bool search,
  )?
      onSubmit,
  bool useCustomBottomSheetMode = false,
}) {
  final buildingKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final floorKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final roomKey = GlobalKey<DropdownSearchState<KeyValue>>();
  // Using Wrap makes the bottom sheet height the height of the content.
  // Otherwise, the height will be half the height of the screen.
  final filterContent = StatefulBuilder(builder:
      (BuildContext context, StateSetter setState /*You can rename this!*/) {
    return Wrap(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              'L???c d??? li???u',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownInput<KeyValue>(
                  label: 'Khu c??ch ly',
                  hint: 'Ch???n khu c??ch ly',
                  itemAsString: (KeyValue? u) => u!.name,
                  itemValue: quarantineWardList,
                  selectedItem: quarantineWardList.safeFirstWhere((type) =>
                      type.id.toString() == quarantineWardController.text),
                  onFind: quarantineWardList.isEmpty
                      ? (String? filter) => fetchQuarantineWard({
                            'page_size': pageSizeMax,
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        quarantineWardController.text = "";
                      } else {
                        quarantineWardController.text = value.id.toString();
                      }
                      quarantineBuildingController.clear();
                      quarantineFloorController.clear();
                      quarantineRoomController.clear();
                      quarantineBuildingList = [];
                      quarantineFloorList = [];
                      quarantineRoomList = [];
                    });
                    if (quarantineWardController.text != "") {
                      fetchQuarantineBuilding({
                        'quarantine_ward': quarantineWardController.text,
                        'page_size': pageSizeMax,
                      }).then((data) => setState(() {
                            quarantineBuildingList = data;
                            buildingKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  widgetKey: buildingKey,
                  label: 'T??a',
                  hint: 'Ch???n t??a',
                  itemAsString: (KeyValue? u) => u!.name,
                  itemValue: quarantineBuildingList,
                  selectedItem: quarantineBuildingList.safeFirstWhere((type) =>
                      type.id.toString() == quarantineBuildingController.text),
                  onFind: quarantineBuildingList.isEmpty &&
                          quarantineWardController.text != ""
                      ? (String? filter) => fetchQuarantineBuilding({
                            'quarantine_ward': quarantineWardController.text,
                            'page_size': pageSizeMax,
                            'search': filter
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        quarantineBuildingController.text = "";
                      } else {
                        quarantineBuildingController.text = value.id.toString();
                      }
                      quarantineFloorController.clear();
                      quarantineRoomController.clear();
                      quarantineFloorList = [];
                      quarantineRoomList = [];
                    });
                    if (quarantineBuildingController.text != "") {
                      fetchQuarantineFloor({
                        'quarantine_building_id_list':
                            quarantineBuildingController.text,
                        'page_size': pageSizeMax,
                      }).then((data) => setState(() {
                            quarantineFloorList = data;
                            floorKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  widgetKey: floorKey,
                  label: 'T???ng',
                  hint: 'Ch???n t???ng',
                  itemAsString: (KeyValue? u) => u!.name,
                  itemValue: quarantineFloorList,
                  selectedItem: quarantineFloorList.safeFirstWhere((type) =>
                      type.id.toString() == quarantineFloorController.text),
                  onFind: quarantineFloorList.isEmpty &&
                          quarantineBuildingController.text != ""
                      ? (String? filter) => fetchQuarantineFloor({
                            'quarantine_building_id_list':
                                quarantineBuildingController.text,
                            'page_size': pageSizeMax,
                            'search': filter
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        quarantineFloorController.text = "";
                      } else {
                        quarantineFloorController.text = value.id.toString();
                      }
                      quarantineRoomController.clear();
                      quarantineRoomList = [];
                    });
                    if (quarantineFloorController.text != "") {
                      fetchQuarantineRoom({
                        'quarantine_floor': quarantineFloorController.text,
                        'page_size': pageSizeMax,
                      }).then((data) => setState(() {
                            quarantineRoomList = data;
                            roomKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  label: 'Ph??ng',
                  hint: 'Ch???n ph??ng',
                  itemAsString: (KeyValue? u) => u!.name,
                  itemValue: quarantineRoomList,
                  selectedItem: quarantineRoomList.safeFirstWhere((type) =>
                      type.id.toString() == quarantineRoomController.text),
                  onFind: quarantineRoomList.isEmpty &&
                          quarantineFloorController.text != ""
                      ? (String? filter) => fetchQuarantineRoom({
                            'quarantine_floor': quarantineFloorController.text,
                            'page_size': pageSizeMax,
                            'search': filter
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  onChanged: (value) {
                    if (value == null) {
                      quarantineRoomController.text = "";
                    } else {
                      quarantineRoomController.text = value.id.toString();
                    }
                  },
                  showClearButton: true,
                ),
                NewDateRangeInput(
                  label: 'Ng??y b???t ?????u c??ch ly',
                  controllerStart: quarantineAtMinController,
                  controllerEnd: quarantineAtMaxController,
                  maxDate: DateTime.now(),
                  showClearButton: true,
                ),
                NewDateRangeInput(
                  label: 'Ng??y d??? ki???n ho??n th??nh c??ch ly',
                  controllerStart: quarantinedFinishExpectedAtMinController,
                  controllerEnd: quarantinedFinishExpectedAtMaxController,
                  showClearButton: true,
                ),
                MultiDropdownInput<KeyValue>(
                  label: 'Di???n c??ch ly',
                  hint: 'Ch???n di???n c??ch ly',
                  itemValue: labelList,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems: labelController.text != ""
                      ? (labelController.text
                          .split(',')
                          .map((e) => labelList
                              .safeFirstWhere((result) => result.id == e)!)
                          .toList())
                      : null,
                  onChanged: (value) {
                    if (value == null) {
                      labelController.text = "";
                    } else {
                      labelController.text = value.map((e) => e.id).join(",");
                    }
                  },
                ),
                MultiDropdownInput<KeyValue>(
                  label: 'T??nh tr???ng s???c kh???e',
                  hint: 'Ch???n t??nh tr???ng s???c kh???e',
                  itemValue: medDeclValueList,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems: healthStatusController.text != ""
                      ? (healthStatusController.text
                          .split(',')
                          .map((e) => medDeclValueList
                              .safeFirstWhere((result) => result.id == e)!)
                          .toList())
                      : null,
                  onChanged: (value) {
                    if (value == null) {
                      healthStatusController.text = "";
                    } else {
                      healthStatusController.text =
                          value.map((e) => e.id).join(",");
                    }
                  },
                ),
                MultiDropdownInput<KeyValue>(
                  label: 'K???t qu??? x??t nghi???m',
                  hint: 'Ch???n k???t qu??? x??t nghi???m',
                  itemValue: testValueWithBoolList,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems: testController.text != ""
                      ? (testController.text
                          .split(',')
                          .map((e) => testValueWithBoolList
                              .safeFirstWhere((result) => result.id == e)!)
                          .toList())
                      : null,
                  onChanged: (value) {
                    if (value == null) {
                      testController.text = "";
                    } else {
                      testController.text = value.map((e) => e.id).join(",");
                    }
                  },
                ),
                DropdownInput<KeyValue>(
                  label: 'C??n b??? ch??m s??c',
                  hint: 'Ch???n c??n b??? ch??m s??c',
                  onFind: careStaffList.isEmpty
                      ? (String? filter) => fetchNotMemberList({
                            'role_name_list': 'STAFF',
                            'quarantine_ward_id':
                                quarantineWardController.text != ""
                                    ? quarantineWardController.text
                                    : null
                          })
                      : null,
                  searchOnline: false,
                  itemValue: careStaffList,
                  onChanged: (value) {
                    if (value == null) {
                      careStaffController.text = "";
                    } else {
                      careStaffController.text = value.id;
                    }
                  },
                  selectedItem: careStaffList.safeFirstWhere(
                      (type) => type.id.toString() == careStaffController.text),
                  itemAsString: (KeyValue? u) => u!.name,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  showClearButton: true,
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Respond to button press
                          quarantineWardController.clear();
                          quarantineBuildingController.clear();
                          quarantineFloorController.clear();
                          quarantineRoomController.clear();
                          quarantineAtMinController.clear();
                          quarantineAtMaxController.clear();
                          quarantinedFinishExpectedAtMinController.clear();
                          quarantinedFinishExpectedAtMaxController.clear();
                          labelController.clear();
                          onSubmit!(quarantineWardList, [], [], [], [], false);
                          Navigator.pop(context);
                        },
                        child: const Text("?????t l???i"),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                          onSubmit!(
                            quarantineWardList,
                            quarantineBuildingList,
                            quarantineFloorList,
                            quarantineRoomList,
                            careStaffList,
                            true,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("T??m ki???m"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  });

  return !useCustomBottomSheetMode
      ? showBarModalBottomSheet(
          barrierColor: Colors.black54,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          useRootNavigator: !Responsive.isDesktopLayout(context),
          context: context,
          builder: (context) => filterContent,
        )
      : showCustomModalBottomSheet(
          context: context,
          builder: (context) => filterContent,
          containerWidget: (_, animation, child) => FloatingModal(
                child: child,
              ),
          expand: false);
}

Future testFilter(
  BuildContext context, {
  required TextEditingController userCodeController,
  required TextEditingController stateController,
  required TextEditingController typeController,
  required TextEditingController resultController,
  required TextEditingController createAtMinController,
  required TextEditingController createAtMaxController,
  required void Function()? onSubmit,
  bool useCustomBottomSheetMode = false,
}) {
  final filterContent = StatefulBuilder(builder:
      (BuildContext context, StateSetter setState /*You can rename this!*/) {
    return Wrap(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              'L???c d??? li???u',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DropdownInput<KeyValue>(
                  label: 'K??? thu???t x??t nghi???m',
                  hint: 'Ch???n k??? thu???t x??t nghi???m',
                  itemValue: testTypeList,
                  itemAsString: (KeyValue? u) => u!.name,
                  maxHeight: 112,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  selectedItem: testTypeList
                      .safeFirstWhere((type) => type.id == typeController.text),
                  onChanged: (value) {
                    if (value == null) {
                      typeController.text = "";
                    } else {
                      typeController.text = value.id;
                    }
                  },
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  label: 'Tr???ng th??i',
                  hint: 'Ch???n tr???ng th??i',
                  itemValue: testStateList,
                  itemAsString: (KeyValue? u) => u!.name,
                  maxHeight: 112,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  selectedItem: testStateList.safeFirstWhere(
                      (state) => state.id == stateController.text),
                  onChanged: (value) {
                    if (value == null) {
                      stateController.text = "";
                    } else {
                      stateController.text = value.id;
                    }
                  },
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  label: 'K???t qu???',
                  hint: 'Ch???n k???t qu???',
                  itemValue: testValueList,
                  itemAsString: (KeyValue? u) => u!.name,
                  maxHeight: 168,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  selectedItem: testValueList.safeFirstWhere(
                      (result) => result.id == resultController.text),
                  onChanged: (value) {
                    if (value == null) {
                      resultController.text = "";
                    } else {
                      if (value.id == "NEGATIVE" || value.id == "POSITIVE") {
                        stateController.text = "DONE";
                      } else {
                        stateController.text = "WAITING";
                      }
                      resultController.text = value.id;
                    }
                  },
                  showClearButton: true,
                ),
                NewDateRangeInput(
                  label: 'Ng??y x??t nghi???m',
                  controllerStart: createAtMinController,
                  controllerEnd: createAtMaxController,
                  maxDate: DateTime.now(),
                  showClearButton: true,
                ),
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Respond to button press
                          userCodeController.clear();
                          stateController.clear();
                          typeController.clear();
                          resultController.clear();
                          createAtMinController.clear();
                          createAtMaxController.clear();
                          onSubmit!();
                          Navigator.pop(context);
                        },
                        child: const Text("?????t l???i"),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                          onSubmit!();
                          Navigator.pop(context);
                        },
                        child: const Text("T??m ki???m"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  });

  return !useCustomBottomSheetMode
      ? showBarModalBottomSheet(
          barrierColor: Colors.black54,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          useRootNavigator: !Responsive.isDesktopLayout(context),
          context: context,
          builder: (context) => filterContent,
        )
      : showCustomModalBottomSheet(
          context: context,
          builder: (context) => filterContent,
          containerWidget: (_, animation, child) => FloatingModal(
                child: child,
              ),
          expand: false);
}

Future quarantineFilter(
  BuildContext context, {
  required TextEditingController cityController,
  required TextEditingController districtController,
  required TextEditingController wardController,
  required TextEditingController mainManagerController,
  bool myQuarantine = false,
  required List<KeyValue> managerList,
  required List<KeyValue> cityList,
  required List<KeyValue> districtList,
  required List<KeyValue> wardList,
  required void Function(
    List<KeyValue> cityList,
    List<KeyValue> districtList,
    List<KeyValue> wardList,
    bool search,
  )?
      onSubmit,
  bool useCustomBottomSheetMode = false,
}) {
  final districtKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final wardKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final filterContent = StatefulBuilder(builder:
      (BuildContext context, StateSetter setState /*You can rename this!*/) {
    return Wrap(
      children: <Widget>[
        ListTile(
          title: Center(
            child: Text(
              'L???c d??? li???u',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                DropdownInput<KeyValue>(
                  label: 'T???nh/th??nh',
                  hint: 'T???nh/th??nh',
                  itemValue: cityList,
                  selectedItem: cityList.safeFirstWhere(
                      (type) => type.id.toString() == cityController.text),
                  onFind: cityList.isEmpty
                      ? (String? filter) => fetchCity({
                            'country_code': 'VNM',
                            'search': filter,
                          })
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        cityController.text = "";
                      } else {
                        cityController.text = value.id.toString();
                      }
                      districtController.clear();
                      wardController.clear();
                      districtList = [];
                      wardList = [];
                    });
                    if (cityController.text != "") {
                      fetchDistrict({'city_id': cityController.text})
                          .then((data) => setState(() {
                                districtList = data;
                                districtKey.currentState?.openDropDownSearch();
                              }));
                    }
                  },
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'T???nh/th??nh',
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  widgetKey: districtKey,
                  label: 'Qu???n/huy???n',
                  hint: 'Qu???n/huy???n',
                  itemValue: districtList,
                  selectedItem: districtList.safeFirstWhere(
                      (type) => type.id.toString() == districtController.text),
                  onFind: districtList.isEmpty && cityController.text != ""
                      ? (String? filter) => fetchDistrict({
                            'city_id': cityController.text,
                            'search': filter,
                          })
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        districtController.text = "";
                      } else {
                        districtController.text = value.id.toString();
                      }
                      wardController.clear();
                      wardList = [];
                    });
                    if (districtController.text != "") {
                      fetchWard({'district_id': districtController.text})
                          .then((data) => setState(() {
                                wardList = data;
                                wardKey.currentState?.openDropDownSearch();
                              }));
                    }
                  },
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Qu???n/huy???n',
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                  widgetKey: wardKey,
                  label: 'Ph?????ng/x??',
                  hint: 'Ph?????ng/x??',
                  itemValue: wardList,
                  selectedItem: wardList.safeFirstWhere(
                      (type) => type.id.toString() == wardController.text),
                  onFind: wardList.isEmpty && districtController.text != ""
                      ? (String? filter) => fetchWard({
                            'district_id': districtController.text,
                            'search': filter,
                          })
                      : null,
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        wardController.text = "";
                      } else {
                        wardController.text = value.id.toString();
                      }
                    });
                  },
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Ph?????ng/x??',
                  showClearButton: true,
                ),
                DropdownInput<KeyValue>(
                    label: 'Ng?????i qu???n l??',
                    hint: 'Ch???n ng?????i qu???n l??',
                    itemValue: managerList,
                    selectedItem: managerList.safeFirstWhere(
                        (type) => type.id == mainManagerController.text),
                    onFind: managerList.isEmpty
                        ? (String? filter) =>
                            fetchNotMemberList({'role_name_list': 'MANAGER'})
                        : null,
                    searchOnline: false,
                    onChanged: (value) {
                      if (value == null) {
                        mainManagerController.text = "";
                      } else {
                        mainManagerController.text = value.id.toString();
                      }
                    },
                    compareFn: (item, selectedItem) =>
                        item?.id == selectedItem?.id,
                    itemAsString: (KeyValue? u) => u!.name,
                    showSearchBox: true,
                    mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                        ? Mode.DIALOG
                        : Mode.BOTTOM_SHEET,
                    maxHeight: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        100,
                    popupTitle: 'Qu???n l??'),

                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.start,
                //   children: [
                //     ListTileTheme(
                //       contentPadding: const EdgeInsets.only(left: 8),
                //       child: CheckboxListTile(
                //         title: const Text("Qu???n l?? b???i t??i"),
                //         controlAffinity: ListTileControlAffinity.leading,
                //         value: myQuarantine,
                //         onChanged: (bool? value) {
                //           myQuarantine = value!;
                //         },
                //       ),
                //     ),
                //   ],
                // ),
                Container(
                  margin: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          // Respond to button press
                          cityController.clear();
                          districtController.clear();
                          wardController.clear();
                          mainManagerController.clear();
                          onSubmit!(cityList, [], [], false);
                          Navigator.pop(context);
                        },
                        child: const Text("?????t l???i"),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          // Respond to button press
                          onSubmit!(
                            cityList,
                            districtList,
                            wardList,
                            true,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("T??m ki???m"),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  });

  return !useCustomBottomSheetMode
      ? showBarModalBottomSheet(
          barrierColor: Colors.black54,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
          useRootNavigator: !Responsive.isDesktopLayout(context),
          context: context,
          builder: (context) => filterContent,
        )
      : showCustomModalBottomSheet(
          context: context,
          builder: (context) => filterContent,
          containerWidget: (_, animation, child) => FloatingModal(
                child: child,
              ),
          expand: false);
}
