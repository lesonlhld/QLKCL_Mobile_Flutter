import 'package:dropdown_search/dropdown_search.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/date_input.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/members/component/member_shared_data.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/member.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

class MemberQuarantineInfo extends StatefulWidget {
  final Member? quarantineData;
  final KeyValue? quarantineWard;
  final KeyValue? quarantineBuilding;
  final KeyValue? quarantineFloor;
  final KeyValue? quarantineRoom;

  final Permission mode;
  const MemberQuarantineInfo({
    Key? key,
    this.quarantineData,
    this.mode = Permission.edit,
    this.quarantineWard,
    this.quarantineBuilding,
    this.quarantineFloor,
    this.quarantineRoom,
  }) : super(key: key);

  @override
  _MemberQuarantineInfoState createState() => _MemberQuarantineInfoState();
}

class _MemberQuarantineInfoState extends State<MemberQuarantineInfo>
    with AutomaticKeepAliveClientMixin<MemberQuarantineInfo> {
  final _formKey = GlobalKey<FormState>();

  final buildingKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final floorKey = GlobalKey<DropdownSearchState<KeyValue>>();
  final roomKey = GlobalKey<DropdownSearchState<KeyValue>>();

  late MemberSharedDataState state;

  bool _isPositiveTestedBefore = false;

  List<KeyValue> quarantineWardList = [];
  List<KeyValue> quarantineBuildingList = [];
  List<KeyValue> quarantineFloorList = [];
  List<KeyValue> quarantineRoomList = [];

  KeyValue? initQuarantineWard;
  KeyValue? initQuarantineBuilding;
  KeyValue? initQuarantineFloor;
  KeyValue? initQuarantineRoom;

  int _role = 5;

  bool isDataLoaded = false;

  String? getRoomError;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    getRole().then((value) => setState(() {
          _role = value;
        }));
    fetchQuarantineWard({
      'page_size': pageSizeMax,
      'is_full': false,
    }).then((value) {
      if (mounted) {
        setState(() {
          quarantineWardList = value;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!isDataLoaded) {
      isDataLoaded = true;
      state = MemberSharedData.of(context);
      if (widget.mode == Permission.add) {
        state.quarantineRoomController.text = widget.quarantineRoom != null
            ? widget.quarantineRoom!.id.toString()
            : "";
        state.quarantineFloorController.text = widget.quarantineFloor != null
            ? widget.quarantineFloor!.id.toString()
            : "";
        state.quarantineBuildingController.text =
            widget.quarantineBuilding != null
                ? widget.quarantineBuilding!.id.toString()
                : "";
        state.numberOfVaccineDosesController.text = "0";

        if (widget.quarantineWard != null) {
          state.quarantineWardController.text =
              widget.quarantineWard!.id.toString();
        } else {
          getQuarantineWard().then((val) {
            setState(() {
              state.quarantineWardController.text = "$val";
            });
          });
        }
        state.backgroundDiseaseController.text = "";
      } else if (widget.mode == Permission.renew) {
        state.quarantineWardController.text =
            widget.quarantineData?.quarantineWard != null
                ? widget.quarantineData!.quarantineWard!.id.toString()
                : "";
        state.labelController.text = widget.quarantineData?.label ?? "";
        state.quarantinedAtController.clear();
        state.quarantinedFinishExpectedAtController.clear();
        state.backgroundDiseaseController.text =
            widget.quarantineData?.backgroundDisease ?? "";
        state.otherBackgroundDiseaseController.text =
            widget.quarantineData?.otherBackgroundDisease ?? "";
        state.quarantineReasonController.text =
            widget.quarantineData?.quarantineReason ?? "";

        _isPositiveTestedBefore = widget.quarantineData?.positiveTestedBefore ??
            _isPositiveTestedBefore;

        initQuarantineWard = widget.quarantineData?.quarantineWard;
        state.numberOfVaccineDosesController.text =
            widget.quarantineData?.numberOfVaccineDoses ?? "0";

        state.positiveTestNowController.text =
            state.labelController.text == "F0" ? "True" : "Null";
        state.firstPositiveTestDateController.text =
            widget.quarantineData?.firstPositiveTestDate ?? "";
      } else {
        state.quarantineRoomController.text =
            widget.quarantineData?.quarantineRoom != null
                ? widget.quarantineData!.quarantineRoom['id'].toString()
                : "";
        state.quarantineFloorController.text =
            widget.quarantineData?.quarantineFloor != null
                ? widget.quarantineData!.quarantineFloor['id'].toString()
                : "";
        state.quarantineBuildingController.text =
            widget.quarantineData?.quarantineBuilding != null
                ? widget.quarantineData!.quarantineBuilding['id'].toString()
                : "";
        state.quarantineWardController.text =
            widget.quarantineData?.quarantineWard != null
                ? widget.quarantineData!.quarantineWard!.id.toString()
                : "";
        state.labelController.text = widget.quarantineData?.label ?? "";

        state.quarantinedAtController.text =
            widget.quarantineData?.quarantinedAt ?? "";
        state.quarantinedFinishExpectedAtController.text =
            widget.quarantineData?.quarantinedFinishExpectedAt ?? "";
        state.quarantinedFinishAtController.text =
            widget.quarantineData?.quarantinedFinishAt ?? "";
        state.backgroundDiseaseController.text =
            widget.quarantineData?.backgroundDisease ?? "";
        state.otherBackgroundDiseaseController.text =
            widget.quarantineData?.otherBackgroundDisease ?? "";
        state.positiveTestNowController.text =
            widget.quarantineData?.positiveTestNow.toString() ?? "Null";
        state.quarantineReasonController.text =
            widget.quarantineData?.quarantineReason ?? "";
        _isPositiveTestedBefore = widget.quarantineData?.positiveTestedBefore ??
            _isPositiveTestedBefore;
        state.firstPositiveTestDateController.text =
            widget.quarantineData?.firstPositiveTestDate ?? "";

        initQuarantineWard = widget.quarantineData?.quarantineWard;
        initQuarantineBuilding =
            (widget.quarantineData?.quarantineBuilding != null)
                ? KeyValue.fromJson(widget.quarantineData?.quarantineBuilding)
                : null;
        initQuarantineFloor = (widget.quarantineData?.quarantineFloor != null)
            ? KeyValue.fromJson(widget.quarantineData?.quarantineFloor)
            : null;
        initQuarantineRoom = (widget.quarantineData?.quarantineRoom != null)
            ? KeyValue.fromJson(widget.quarantineData?.quarantineRoom)
            : null;
        state.numberOfVaccineDosesController.text =
            widget.quarantineData?.numberOfVaccineDoses ?? "0";
        state.careStaffController.text =
            widget.quarantineData?.careStaff?.id ?? "";
      }
      if (state.quarantineWardController.text != "") {
        fetchQuarantineBuilding({
          'quarantine_ward': state.quarantineWardController.text,
          'page_size': pageSizeMax,
          'is_full': false,
        }).then((value) {
          if (mounted) {
            setState(() {
              quarantineBuildingList = value;
            });
          }
        });
      }
      if (state.quarantineBuildingController.text != "") {
        fetchQuarantineFloor({
          'quarantine_building_id_list':
              state.quarantineBuildingController.text,
          'page_size': pageSizeMax,
          'is_full': false,
        }).then((value) {
          if (mounted) {
            setState(() {
              quarantineFloorList = value;
            });
          }
        });
      }
      if (state.quarantineFloorController.text != "") {
        fetchQuarantineRoom({
          'quarantine_floor': state.quarantineFloorController.text,
          'page_size': pageSizeMax,
          'is_full': false,
        }).then((value) {
          if (mounted) {
            setState(() {
              quarantineRoomList = value;
            });
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      controller: ScrollController(),
      primary: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                DropdownInput<KeyValue>(
                  label: 'Khu c??ch ly',
                  hint: 'Ch???n khu c??ch ly',
                  required: widget.mode != Permission.view && _role != 5,
                  itemAsString: (KeyValue? u) => u!.name,
                  onFind: quarantineWardList.isEmpty
                      ? (String? filter) => fetchQuarantineWard({
                            'page_size': pageSizeMax,
                            'is_full': false,
                            'search': filter,
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemValue: quarantineWardList,
                  selectedItem: widget.quarantineWard ??
                      (initQuarantineWard ??
                          quarantineWardList.safeFirstWhere((type) =>
                              type.id.toString() ==
                              state.quarantineWardController.text)),
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        state.quarantineWardController.text = "";
                      } else {
                        state.quarantineWardController.text =
                            value.id.toString();
                      }
                      state.quarantineBuildingController.clear();
                      state.quarantineFloorController.clear();
                      state.quarantineRoomController.clear();
                      quarantineBuildingList = [];
                      quarantineFloorList = [];
                      quarantineRoomList = [];
                      initQuarantineWard = null;
                      initQuarantineBuilding = null;
                      initQuarantineFloor = null;
                      initQuarantineRoom = null;
                    });
                    if (state.quarantineWardController.text != "" &&
                        _role != 5) {
                      fetchQuarantineBuilding({
                        'quarantine_ward': state.quarantineWardController.text,
                        'page_size': pageSizeMax,
                        'is_full': false,
                      }).then((data) => setState(() {
                            quarantineBuildingList = data;
                            buildingKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  enabled: widget.mode == Permission.add ||
                      widget.mode == Permission.renew ||
                      (widget.mode == Permission.edit &&
                          state.statusController.text != "AVAILABLE"),
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Khu c??ch ly',
                ),
                DropdownInput<KeyValue>(
                  widgetKey: buildingKey,
                  label: 'T??a',
                  hint: 'Ch???n t??a',
                  required: widget.mode != Permission.view &&
                      widget.mode != Permission.approval &&
                      _role != 5 &&
                      state.statusController.text == "AVAILABLE",
                  itemAsString: (KeyValue? u) => u!.name,
                  onFind: quarantineBuildingList.isEmpty &&
                          state.quarantineWardController.text != ""
                      ? (String? filter) => fetchQuarantineBuilding({
                            'quarantine_ward':
                                state.quarantineWardController.text,
                            'page_size': pageSizeMax,
                            'search': filter,
                            'is_full': false,
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemValue: quarantineBuildingList,
                  selectedItem: widget.quarantineBuilding ??
                      (initQuarantineBuilding ??
                          quarantineBuildingList.safeFirstWhere((type) =>
                              type.id.toString() ==
                              state.quarantineBuildingController.text)),
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        state.quarantineBuildingController.text = "";
                      } else {
                        state.quarantineBuildingController.text =
                            value.id.toString();
                      }
                      state.quarantineFloorController.clear();
                      state.quarantineRoomController.clear();
                      quarantineFloorList = [];
                      quarantineRoomList = [];
                      initQuarantineBuilding = null;
                      initQuarantineFloor = null;
                      initQuarantineRoom = null;
                    });
                    if (state.quarantineBuildingController.text != "") {
                      fetchQuarantineFloor({
                        'quarantine_building_id_list':
                            state.quarantineBuildingController.text,
                        'page_size': pageSizeMax,
                        'is_full': false,
                      }).then((data) => setState(() {
                            quarantineFloorList = data;
                            floorKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  enabled: widget.mode != Permission.view && _role != 5,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'T??a',
                ),
                DropdownInput<KeyValue>(
                  widgetKey: floorKey,
                  label: 'T???ng',
                  hint: 'Ch???n t???ng',
                  required: widget.mode != Permission.view &&
                      widget.mode != Permission.approval &&
                      _role != 5 &&
                      state.statusController.text == "AVAILABLE",
                  itemAsString: (KeyValue? u) => u!.name,
                  onFind: quarantineFloorList.isEmpty &&
                          state.quarantineBuildingController.text != ""
                      ? (String? filter) => fetchQuarantineFloor({
                            'quarantine_building_id_list':
                                state.quarantineBuildingController.text,
                            'page_size': pageSizeMax,
                            'search': filter,
                            'is_full': false,
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemValue: quarantineFloorList,
                  selectedItem: widget.quarantineFloor ??
                      (initQuarantineFloor ??
                          quarantineFloorList.safeFirstWhere((type) =>
                              type.id.toString() ==
                              state.quarantineFloorController.text)),
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        state.quarantineFloorController.text = "";
                      } else {
                        state.quarantineFloorController.text =
                            value.id.toString();
                      }
                      state.quarantineRoomController.clear();
                      quarantineRoomList = [];
                      initQuarantineFloor = null;
                      initQuarantineRoom = null;
                    });
                    if (state.quarantineFloorController.text != "") {
                      fetchQuarantineRoom({
                        'quarantine_floor':
                            state.quarantineFloorController.text,
                        'page_size': pageSizeMax,
                        'is_full': false,
                      }).then((data) => setState(() {
                            quarantineRoomList = data;
                            roomKey.currentState?.openDropDownSearch();
                          }));
                    }
                  },
                  enabled: widget.mode != Permission.view && _role != 5,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'T???ng',
                ),
                DropdownInput<KeyValue>(
                  widgetKey: roomKey,
                  label: 'Ph??ng',
                  hint: 'Ch???n ph??ng',
                  required: widget.mode != Permission.view &&
                      widget.mode != Permission.approval &&
                      _role != 5 &&
                      state.statusController.text == "AVAILABLE",
                  itemAsString: (KeyValue? u) => u!.name,
                  onFind: quarantineRoomList.isEmpty &&
                          state.quarantineFloorController.text != ""
                      ? (String? filter) => fetchQuarantineRoom({
                            'quarantine_floor':
                                state.quarantineFloorController.text,
                            'page_size': pageSizeMax,
                            'search': filter,
                            'is_full': false,
                          })
                      : null,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemValue: quarantineRoomList,
                  selectedItem: widget.quarantineRoom ??
                      (initQuarantineRoom ??
                          quarantineRoomList.safeFirstWhere((type) =>
                              type.id.toString() ==
                              state.quarantineRoomController.text)),
                  onChanged: (value) {
                    setState(() {
                      if (value == null) {
                        state.quarantineRoomController.text = "";
                      } else {
                        state.quarantineRoomController.text =
                            value.id.toString();
                      }
                      initQuarantineRoom = null;
                    });
                  },
                  enabled: widget.mode != Permission.view && _role != 5,
                  showSearchBox: true,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Ph??ng',
                ),
                if (state.quarantineRoomController.text == "" && _role != 5)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 0, 0),
                    alignment: Alignment.centerLeft,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          if (!labelList
                              .map((element) => element.id.toString())
                              .toList()
                              .cast<String>()
                              .contains(state.labelController.text)) {
                            setState(() {
                              getRoomError = "Vui l??ng ch???n di???n c??ch ly!";
                            });
                          } else {
                            setState(() {
                              getRoomError = null;
                            });
                            final CancelFunc cancel = showLoading();
                            final response = await getSuitableRoom(
                              getSuitableRoomDataForm(
                                gender: state.genderController.text,
                                label: state.labelController.text,
                                numberOfVaccineDoses:
                                    state.numberOfVaccineDosesController.text,
                                quarantineWard:
                                    state.quarantineWardController.text,
                                positiveTestNow: state
                                    .positiveTestNowController.text
                                    .capitalize(),
                              ),
                            );
                            cancel();
                            if (response.status == Status.success) {
                              state.quarantineBuildingController.text = response
                                  .data['quarantine_building']['id']
                                  .toString();
                              state.quarantineFloorController.text = response
                                  .data['quarantine_floor']['id']
                                  .toString();
                              state.quarantineRoomController.text = response
                                  .data['quarantine_room']['id']
                                  .toString();
                              initQuarantineBuilding = KeyValue.fromJson(
                                  response.data['quarantine_building']);
                              initQuarantineFloor = KeyValue.fromJson(
                                  response.data['quarantine_floor']);
                              initQuarantineRoom = KeyValue.fromJson(
                                  response.data['quarantine_room']);
                              state.updateField();
                              setState(() {});
                            } else {
                              showNotification(response);
                            }
                          }
                        },
                        child: Text(
                          "G???i ?? ch???n ph??ng",
                          style: TextStyle(
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                DropdownInput<KeyValue>(
                  label: 'Di???n c??ch ly',
                  hint: 'Ch???n di???n c??ch ly',
                  helper: "Ng?????i c??ch ly s??? d????ng t??nh khi ch???n F0",
                  itemValue: labelList,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItem: labelList.safeFirstWhere(
                      (label) => label.id == state.labelController.text),
                  onChanged: (value) {
                    if (value == null) {
                      state.labelController.text = "";
                      setState(() {
                        getRoomError = "Vui l??ng ch???n di???n c??ch ly!";
                      });
                    } else {
                      state.labelController.text = value.id.toString();
                      state.positiveTestNowController.text =
                          state.labelController.text == "F0"
                              ? "True"
                              : widget.quarantineData?.positiveTestNow
                                      .toString() ??
                                  "Null";
                      setState(() {
                        getRoomError = null;
                      });
                    }
                  },
                  enabled: widget.mode == Permission.add ||
                      widget.mode == Permission.renew ||
                      (widget.mode == Permission.edit && _role < 5) ||
                      (_role == 5 &&
                          state.statusController.text != "AVAILABLE"),
                  required: widget.mode != Permission.view,
                  error: getRoomError,
                ),
                if (state.labelController.text == "F0" ||
                    _isPositiveTestedBefore)
                  NewDateInput(
                    label: 'Ng??y nhi???m b???nh',
                    controller: state.firstPositiveTestDateController,
                    enabled: widget.mode == Permission.add ||
                        widget.mode == Permission.edit ||
                        widget.mode == Permission.renew,
                    defaultTime: "07:00",
                  ),
                Input(
                  label: 'L?? do c??ch ly',
                  controller: state.quarantineReasonController,
                  maxLines: 3,
                ),
                NewDateInput(
                  label: 'Th???i gian b???t ?????u c??ch ly',
                  controller: state.quarantinedAtController,
                  enabled: widget.mode != Permission.view && _role != 5,
                  defaultTime: "07:00",
                ),
                if (state.statusController.text == "AVAILABLE" &&
                    widget.quarantineData?.quarantinedStatus ==
                        "QUARANTINING" &&
                    _role != 5)
                  NewDateInput(
                    label: 'Th???i gian d??? ki???n ho??n th??nh c??ch ly',
                    controller: state.quarantinedFinishExpectedAtController,
                    enabled: widget.mode == Permission.edit && _role != 5,
                    defaultTime: "07:00",
                  ),
                // if (state.statusController.text == "LEAVE" &&
                //     widget.quarantineData?.quarantinedStatus == "COMPLETED")
                //   NewDateInput(
                //     label: 'Th???i gian ho??n th??nh c??ch ly',
                //     controller: state.quarantinedFinishAtController,
                //     enabled: false,
                //   ),
                if (widget.mode == Permission.add ||
                    widget.mode == Permission.approval)
                  Input(
                    label: "S??? m??i vaccine ???? ti??m",
                    controller: state.numberOfVaccineDosesController,
                    required: widget.mode == Permission.add,
                    enabled: widget.mode == Permission.add ||
                        widget.mode == Permission.approval,
                  ),
                // DropdownInput<KeyValue>(
                //   label: "T??nh tr???ng b???nh",
                //   itemValue: testValueWithBoolList,
                //   selectedItem: testValueWithBoolList.safeFirstWhere((result) =>
                //       result.id ==
                //       state.positiveTestNowController.text.capitalize()),
                //   itemAsString: (KeyValue? u) => u!.name,
                //   compareFn: (item, selectedItem) =>
                //       item?.id == selectedItem?.id,
                //   enabled: false,
                // ),
                if (_role != 5)
                  DropdownInput<KeyValue>(
                    label: 'C??n b??? ch??m s??c',
                    hint: 'Ch???n c??n b??? ch??m s??c',
                    onFind: (String? filter) => fetchNotMemberList({
                      'role_name_list': 'STAFF',
                      'quarantine_ward_id': state.quarantineWardController.text
                    }),
                    searchOnline: false,
                    selectedItem: widget.quarantineData?.careStaff,
                    onChanged: (value) {
                      if (value == null) {
                        state.careStaffController.text = "";
                      } else {
                        state.careStaffController.text = value.id;
                      }
                    },
                    enabled: widget.mode != Permission.view && _role != 5,
                    itemAsString: (KeyValue? u) => u!.name,
                    compareFn: (item, selectedItem) =>
                        item?.id == selectedItem?.id,
                    showSearchBox: true,
                    mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                        ? Mode.DIALOG
                        : Mode.BOTTOM_SHEET,
                    maxHeight: MediaQuery.of(context).size.height -
                        AppBar().preferredSize.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        100,
                    popupTitle: 'C??n b???',
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTileTheme(
                      contentPadding: const EdgeInsets.only(left: 8),
                      child: CheckboxListTile(
                        title: const Text("???? t???ng nhi???m COVID-19"),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _isPositiveTestedBefore,
                        onChanged: (bool? value) {
                          setState(() {
                            _isPositiveTestedBefore = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                MultiDropdownInput<KeyValue>(
                  label: 'B???nh n???n',
                  hint: 'Ch???n b???nh n???n',
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                  itemValue: backgroundDiseaseList,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems:
                      (widget.quarantineData?.backgroundDisease != null)
                          ? (widget.quarantineData!.backgroundDisease
                              .toString()
                              .split(',')
                              .map((e) => backgroundDiseaseList.safeFirstWhere(
                                  (result) => result.id == int.parse(e))!)
                              .toList())
                          : null,
                  onChanged: (value) {
                    if (value == null) {
                      state.backgroundDiseaseController.text = "";
                    } else {
                      state.backgroundDiseaseController.text =
                          value.map((e) => e.id).join(",");
                    }
                  },
                  enabled: widget.mode != Permission.view,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'B???nh n???n',
                ),
                Input(
                  label: 'B???nh n???n kh??c',
                  controller: state.otherBackgroundDiseaseController,
                  enabled: widget.mode != Permission.view,
                ),
                if (widget.mode != Permission.view)
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                    child: Row(
                      children: [
                        Text(
                          '(*)',
                          style: TextStyle(
                            fontSize: 14,
                            color: error,
                          ),
                        ),
                        const Text(
                          ' Th??ng tin b???t bu???c',
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (widget.mode != Permission.view)
                  Container(
                      margin: const EdgeInsets.all(16),
                      child: Row(children: [
                        if (widget.mode == Permission.approval &&
                            widget.quarantineData?.customUserCode != null)
                          const Spacer(),
                        if (widget.mode == Permission.approval &&
                            widget.quarantineData?.customUserCode != null)
                          OutlinedButton(
                            onPressed: () async {
                              final CancelFunc cancel = showLoading();
                              final response = await denyMember({
                                'member_codes': widget
                                    .quarantineData!.customUserCode
                                    .toString()
                              });
                              cancel();
                              showNotification(response);
                            },
                            child: const Text("T??? ch???i"),
                          ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: _submit,
                          child: widget.mode == Permission.add
                              ? const Text("T???o")
                              : widget.mode == Permission.approval
                                  ? const Text("X??t duy???t")
                                  : const Text('X??c nh???n'),
                        ),
                        const Spacer(),
                      ])),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    setState(() {
      getRoomError = null;
    });
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      if (widget.mode == Permission.approval) {
        final CancelFunc cancel = showLoading();
        final response = await acceptOneMember(acceptOneMemberDataForm(
          code: widget.quarantineData!.customUserCode.toString(),
          quarantineRoom: state.quarantineRoomController.text,
          quarantinedAt:
              parseDateTimeWithTimeZone(state.quarantinedAtController.text),
        ));
        cancel();
        showNotification(response);
      } else if (widget.mode == Permission.renew) {
        final CancelFunc cancel = showLoading();
        final response =
            await managerCallRequarantine(requarantineMemberDataForm(
          code: widget.quarantineData!.customUserCode.toString(),
          quarantineRoom: state.quarantineRoomController.text,
          quarantinedAt:
              parseDateTimeWithTimeZone(state.quarantinedAtController.text),
          label: state.labelController.text,
          quarantineWard: state.quarantineWardController.text,
          careStaff: state.careStaffController.text,
          positiveTestedBefore: _isPositiveTestedBefore,
          quarantineReason: state.quarantineReasonController.text,
          firstPositiveTestDate: parseDateTimeWithTimeZone(
              state.firstPositiveTestDateController.text),
        ));
        cancel();
        showNotification(response);
      } else if (widget.mode == Permission.add) {
        final CancelFunc cancel = showLoading();
        final response = await createMember(createMemberDataForm(
          phoneNumber: state.phoneNumberController.text,
          fullName: state.fullNameController.text,
          email: state.emailController.text,
          birthday: state.birthdayController.text != ""
              ? DateFormat("dd/MM/yyyy")
                  .format(DateTime.parse(state.birthdayController.text))
              : "",
          gender: state.genderController.text,
          nationality: "VNM",
          country: state.countryController.text,
          city: state.cityController.text,
          district: state.districtController.text,
          ward: state.wardController.text,
          address: state.detailAddressController.text,
          healthInsurance: state.healthInsuranceNumberController.text,
          identity: state.identityNumberController.text,
          passport: state.passportNumberController.text,
          quarantineWard: state.quarantineWardController.text,
          quarantineRoom: state.quarantineRoomController.text,
          label: state.labelController.text,
          quarantinedAt:
              parseDateTimeWithTimeZone(state.quarantinedAtController.text),
          positiveBefore: _isPositiveTestedBefore,
          backgroundDisease: state.backgroundDiseaseController.text,
          otherBackgroundDisease: state.otherBackgroundDiseaseController.text,
          numberOfVaccineDoses: state.numberOfVaccineDosesController.text,
          careStaff: state.careStaffController.text,
          quarantineReason: state.quarantineReasonController.text,
          professional: state.professionalController.text,
          firstPositiveTestDate: parseDateTimeWithTimeZone(
              state.firstPositiveTestDateController.text),
        ));
        cancel();
        showNotification(response);
        if (response.status == Status.success) {
          state.codeController.text = response.data['custom_user']['code'];
        }
      } else {
        final CancelFunc cancel = showLoading();
        final updateResponse = await updateMember(updateMemberDataForm(
          code:
              (widget.mode == Permission.add && state.codeController.text != "")
                  ? state.codeController.text
                  : ((widget.quarantineData != null &&
                          widget.quarantineData?.customUserCode != null)
                      ? widget.quarantineData!.customUserCode.toString()
                      : ""),
          quarantineWard: state.quarantineWardController.text,
          quarantineRoom: state.quarantineRoomController.text,
          label: state.labelController.text,
          quarantinedAt:
              parseDateTimeWithTimeZone(state.quarantinedAtController.text),
          quarantinedFinishExpectedAt: parseDateTimeWithTimeZone(
              state.quarantinedFinishExpectedAtController.text),
          positiveBefore: _isPositiveTestedBefore,
          backgroundDisease: state.backgroundDiseaseController.text,
          otherBackgroundDisease: state.otherBackgroundDiseaseController.text,
          careStaff: state.careStaffController.text,
          quarantineReason: state.quarantineReasonController.text,
          professional: state.professionalController.text,
          firstPositiveTestDate: parseDateTimeWithTimeZone(
              state.firstPositiveTestDateController.text),
        ));
        cancel();
        showNotification(updateResponse);
      }
    }
  }
}
