import 'package:bot_toast/bot_toast.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/popup.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/member.dart';
import 'package:qlkcl/models/test.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:syncfusion_flutter_datagrid_export/export.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as excel
    hide Alignment, Column, Row, Border;
import 'package:url_launcher/url_launcher.dart';

// Platform specific import
import '../../../helper/save_mobile.dart'
    if (dart.library.html) '../../../helper/save_web.dart' as helper;

Widget buildExportingButton(GlobalKey<SfDataGridState> key) {
  Future<void> exportDataGridToExcel() async {
    final excel.Workbook workbook = key.currentState!.exportToExcelWorkbook(
      cellExport: (DataGridCellExcelExportDetails details) {},
      excludeColumns: ['code'],
    );
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();
    await helper.FileSaveHelper.saveAndLaunchFile(bytes, 'ExportFile.xlsx');
  }

  return Container(
    margin: const EdgeInsets.all(8),
    height: 36,
    child: TextButton(
      onPressed: exportDataGridToExcel,
      child: RichText(
        text: TextSpan(
          children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Icon(
                Icons.output,
                size: 22,
                color: primaryText,
              ),
            ),
            const TextSpan(
              text: " Export",
            )
          ],
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(disable),
      ),
    ),
  );
}

Widget buildImportingButton() {
  void importDataFromExcel() async {
    final files = (await FilePicker.platform.pickFiles(
      type: FileType.custom,
      onFileLoading: print,
      allowedExtensions: ['csv', 'xls', 'xlsx'],
    ))
        ?.files;

    if (files?.first != null) {
      importMember(files!.first);
    }
  }

  return Container(
    margin: const EdgeInsets.all(8),
    height: 36,
    decoration:
        BoxDecoration(color: disable, borderRadius: BorderRadius.circular(4)),
    child: TooltipVisibility(
      visible: false,
      child: PopupMenuButton(
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(8),
          child: RichText(
            text: TextSpan(
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.input,
                    size: 22,
                    color: primaryText,
                  ),
                ),
                const TextSpan(
                  text: " Import",
                )
              ],
            ),
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry>[
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.file_download_outlined,
                  color: primaryText,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text(
                  'T???i xu???ng file m???u',
                ),
              ],
            ),
            onTap: () async {
              launch(
                  "https://docs.google.com/spreadsheets/d/1ItVphe7GZRb-Bafiw_OFEAtSSDUgD71i/edit?usp=sharing&ouid=101792372176143715365&rtpof=true&sd=true");
            },
          ),
          PopupMenuItem(
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.file_upload_outlined,
                  color: primaryText,
                ),
                const SizedBox(
                  width: 4,
                ),
                const Text('T???i l??n'),
              ],
            ),
            onTap: importDataFromExcel,
          ),
        ],
      ),
    ),
  );
}

Widget searchBox(
    GlobalKey<SfDataGridState> key, TextEditingController keySearch) {
  return Container(
    margin: const EdgeInsets.all(8),
    alignment: Alignment.centerLeft,
    width: 400,
    height: 36,
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(30)),
    child: TextField(
      style: const TextStyle(fontSize: 17),
      textAlignVertical: TextAlignVertical.center,
      controller: keySearch,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        prefixIcon: Icon(
          Icons.search,
          color: secondaryText,
        ),
        suffixIcon: keySearch.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  /* Clear the search field */
                  keySearch.clear();
                  key.currentState!.refresh();
                },
              )
            : null,
        hintText: 'T??m ki???m...',
        filled: false,
      ),
      onSubmitted: (v) {
        key.currentState!.refresh();
      },
    ),
  );
}

Widget buildAcceptsButton(
  GlobalKey<SfDataGridState> key,
  bool longPressFlag,
  List<String> indexList,
  VoidCallback longPress,
  bool onDone,
  VoidCallback onDoneCallback,
) {
  return indexList.isNotEmpty
      ? Container(
          margin: const EdgeInsets.all(8),
          height: 36,
          decoration: BoxDecoration(
              color: disable, borderRadius: BorderRadius.circular(4)),
          child: TooltipVisibility(
            visible: false,
            child: PopupMenuButton(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(8),
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.done,
                          size: 22,
                          color: primaryText,
                        ),
                      ),
                      const TextSpan(
                        text: " X??t duy???t",
                      )
                    ],
                  ),
                ),
              ),
              itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                PopupMenuItem(
                  child: const Text('Ch???p nh???n'),
                  onTap: () async {
                    if (indexList.isEmpty) {
                      showNotification("Vui l??ng ch???n t??i kho???n c???n x??t duy???t!",
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
                            indexList.clear();
                            key.currentState!.refresh();
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
                      showNotification("Vui l??ng ch???n t??i kho???n c???n x??t duy???t!",
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
                            indexList.clear();
                            key.currentState!.refresh();
                            longPress();
                          }
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        )
      : const SizedBox();
}

Widget buildTestsButton(
  BuildContext context,
  GlobalKey<SfDataGridState> key,
  bool longPressFlag,
  List<String> indexList,
  VoidCallback longPress,
  bool onDone,
  VoidCallback onDoneCallback,
) {
  final formKey = GlobalKey<FormState>();
  final typeController = TextEditingController(text: "QUICK");
  return indexList.isNotEmpty
      ? Container(
          margin: const EdgeInsets.all(8),
          height: 36,
          child: TextButton(
            onPressed: () async {
              if (indexList.isEmpty) {
                showNotification("Vui l??ng ch???n t??i kho???n c???n t???o x??t nghi???m!",
                    status: Status.error);
              } else {
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
                                style: TextStyle(color: primaryText),
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
                          selectedItem: testTypeList.safeFirstWhere(
                              (type) => type.id == typeController.text),
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
                    if (formKey.currentState!.validate()) {
                      final CancelFunc cancel = showLoading();
                      final response = await createManyTests({
                        'user_codes': indexList.join(","),
                        'type': typeController.text
                      });
                      cancel();
                      if (response.status == Status.success) {
                        indexList.clear();
                        key.currentState!.refresh();
                        longPress();
                      }
                    }
                  },
                );
              }
            },
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.post_add_outlined,
                      size: 22,
                      color: primaryText,
                    ),
                  ),
                  const TextSpan(
                    text: " T???o x??t nghi???m",
                  )
                ],
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(disable),
            ),
          ),
        )
      : const SizedBox();
}

Widget buildFinishsButton(
  BuildContext context,
  GlobalKey<SfDataGridState> key,
  bool longPressFlag,
  List<String> indexList,
  VoidCallback longPress,
  bool onDone,
  VoidCallback onDoneCallback,
) {
  return indexList.isNotEmpty
      ? Container(
          margin: const EdgeInsets.all(8),
          height: 36,
          child: TextButton(
            onPressed: () async {
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
                      indexList.clear();
                      key.currentState!.refresh();
                      longPress();
                    }
                  },
                );
              }
            },
            child: RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.done_all,
                      size: 22,
                      color: primaryText,
                    ),
                  ),
                  const TextSpan(
                    text: " Ho??n th??nh c??ch ly",
                  )
                ],
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(disable),
            ),
          ),
        )
      : const SizedBox();
}
