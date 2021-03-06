import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/custom_user.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/test.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:qlkcl/utils/data_form.dart';

class TestForm extends StatefulWidget {
  final KeyValue? user;
  final Test? testData;
  final Permission mode;
  const TestForm(
      {Key? key, this.testData, this.mode = Permission.view, this.user})
      : super(key: key);

  @override
  _TestFormState createState() => _TestFormState();
}

class _TestFormState extends State<TestForm> {
  final _formKey = GlobalKey<FormState>();
  final testCodeController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final userNameController = TextEditingController();
  final stateController = TextEditingController();
  final typeController = TextEditingController();
  final resultController = TextEditingController();
  final createAtController = TextEditingController();
  final updateAtController = TextEditingController();
  final createByController = TextEditingController();
  final updateByController = TextEditingController();

  String? phoneError;

  @override
  void initState() {
    if (widget.testData != null) {
      testCodeController.text =
          widget.testData?.code != null ? widget.testData!.code : "";
      phoneNumberController.text =
          widget.testData?.user.id != null ? widget.testData!.user.id : "";
      userNameController.text =
          widget.testData?.user.name != null ? widget.testData!.user.name : "";
      stateController.text =
          widget.testData?.status != null ? widget.testData!.status : "";
      typeController.text =
          widget.testData?.type != null ? widget.testData!.type : "";
      resultController.text =
          widget.testData?.result != null ? widget.testData!.result : "";
      createAtController.text = widget.testData?.createdAt != null
          ? DateFormat("dd/MM/yyyy HH:mm:ss")
              .format(widget.testData!.createdAt.toLocal())
          : "";
      createByController.text = widget.testData?.createdBy != null
          ? widget.testData!.createdBy.name
          : "";
      updateAtController.text = widget.testData?.updatedAt != null
          ? DateFormat("dd/MM/yyyy HH:mm:ss")
              .format(widget.testData!.updatedAt.toLocal())
          : "";
      updateByController.text = widget.testData?.updatedBy != null
          ? widget.testData!.updatedBy?.name
          : "";
    } else {
      phoneNumberController.text = widget.user != null ? widget.user!.id : "";
      userNameController.text = widget.user != null ? widget.user!.name : "";
      stateController.text = "WAITING";
      typeController.text = "QUICK";
      resultController.text = "NONE";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          constraints: const BoxConstraints(minWidth: 100, maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (widget.mode != Permission.add)
                  Input(
                    label: 'M?? phi???u',
                    enabled: false,
                    controller: testCodeController,
                  ),

                Input(
                  label: 'S??? ??i???n tho???i',
                  hint: 'S??T ng?????i ???????c x??t nghi???m',
                  required: widget.mode != Permission.view,
                  type: TextInputType.phone,
                  controller: phoneNumberController,
                  validatorFunction:
                      (widget.user == null && widget.mode == Permission.add)
                          ? phoneValidator
                          : null,
                  enabled: widget.user == null && widget.mode == Permission.add,
                  onChangedFunction: (_) async {
                    if (phoneNumberController.text.isEmpty) {
                      userNameController.text = "";
                      setState(() {});
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    }
                  },
                  onSavedFunction: (value) async {
                    final data =
                        await getUserByPhone(data: {"phone_number": value});
                    if (data.status == Status.success) {
                      phoneError = null;
                      userNameController.text = data.data['full_name'];
                    } else {
                      phoneError = data.message;
                      userNameController.text = "";
                    }
                    setState(() {});
                  },
                  autoValidate: false,
                  error: phoneError,
                ),
                Input(
                  label: 'H??? v?? t??n',
                  controller: userNameController,
                  enabled: false,
                ),
                // DropdownInput<KeyValue>(
                //   label: 'Tr???ng th??i',
                //   hint: 'Ch???n tr???ng th??i',
                //   required: widget.mode != Permission.view,
                //   itemValue: testStateList,
                //   itemAsString: (KeyValue? u) => u!.name,
                //   maxHeight: 112,
                //   compareFn: (item, selectedItem) =>
                //       item?.id == selectedItem?.id,
                //   selectedItem: testStateList.safeFirstWhere(
                //       (state) => state.id == stateController.text),
                //   onChanged: (value) {
                //     if (value == null) {
                //       stateController.text = "";
                //     } else {
                //       stateController.text = value.id;
                //     }
                //   },
                //   enabled: widget.mode == Permission.edit ||
                //       widget.mode == Permission.add,
                // ),
                DropdownInput<KeyValue>(
                  label: 'K??? thu???t x??t nghi???m',
                  hint: 'Ch???n k??? thu???t x??t nghi???m',
                  required: widget.mode != Permission.view,
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
                  enabled: widget.mode == Permission.add,
                ),
                DropdownInput<KeyValue>(
                  label: 'K???t qu???',
                  hint: 'Ch???n k???t qu???',
                  required: widget.mode != Permission.view,
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
                  enabled: widget.mode == Permission.edit ||
                      widget.mode == Permission.add,
                ),
                if (widget.mode == Permission.view ||
                    widget.mode == Permission.edit)
                  Input(
                    label: 'Th???i gian t???o',
                    controller: createAtController,
                    enabled: false,
                  ),
                if (widget.mode == Permission.view ||
                    widget.mode == Permission.edit)
                  Input(
                    label: 'Ng?????i t???o',
                    controller: createByController,
                    enabled: false,
                  ),
                if (widget.mode == Permission.view)
                  Input(
                    label: 'C???p nh???t l???n cu???i',
                    controller: updateAtController,
                    enabled: false,
                  ),
                if (widget.mode == Permission.view)
                  Input(
                    label: 'Ng?????i c???p nh???t',
                    controller: updateByController,
                    enabled: false,
                  ),
                if (widget.mode == Permission.edit ||
                    widget.mode == Permission.add)
                  Container(
                    margin: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        'X??c nh???n',
                        style: TextStyle(color: white),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate() &&
        (phoneError == null || phoneError == "")) {
      final CancelFunc cancel = showLoading();
      if (widget.mode == Permission.add) {
        final response = await createTest(createTestDataForm(
            phoneNumber: phoneNumberController.text,
            status: stateController.text,
            type: typeController.text,
            result: resultController.text));
        cancel();
        showNotification(response);
        if (response.status == Status.success) {
          Navigator.pop(context);
        }
      } else if (widget.mode == Permission.edit) {
        final response = await updateTest(updateTestDataForm(
            code: widget.testData!.code,
            status: stateController.text,
            type: typeController.text,
            result: resultController.text));
        cancel();
        showNotification(response);
        if (response.status == Status.success) {
          Navigator.pop(context, response);
        }
      }
    }
  }
}
