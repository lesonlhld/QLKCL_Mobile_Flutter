import 'package:dropdown_search/dropdown_search.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/models/custom_user.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/medical_declaration.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:intl/intl.dart';

class MedDeclForm extends StatefulWidget {
  const MedDeclForm({
    Key? key,
    this.mode = Permission.view,
    this.medicalDeclData,
    this.phone,
    this.name,
  }) : super(key: key);
  final Permission mode;
  final MedicalDecl? medicalDeclData;
  final String? phone;
  final String? name;

  @override
  _MedDeclFormState createState() => _MedDeclFormState();
}

class _MedDeclFormState extends State<MedDeclForm> {
  //Add medical declaration
  bool isChecked = false;
  bool agree = false;

  //Input Controller
  final _formKey = GlobalKey<FormState>();
  final phoneNumberController = TextEditingController();
  final userNameController = TextEditingController();
  final heartBeatController = TextEditingController();
  final temperatureController = TextEditingController();
  final breathingController = TextEditingController();
  final bloodPressureMinController = TextEditingController();
  final bloodPressureMaxController = TextEditingController();
  final otherController = TextEditingController();
  final extraSymptomController = TextEditingController();
  final mainSymptomController = TextEditingController();
  final spo2Controller = TextEditingController();

  String? phoneError;

  @override
  void initState() {
    super.initState();
    //Data contained
    if (widget.medicalDeclData != null) {
      userNameController.text = widget.medicalDeclData?.user.fullName != null
          ? widget.medicalDeclData!.user.fullName
          : widget.name ?? "";

      heartBeatController.text = widget.medicalDeclData?.heartbeat != null
          ? widget.medicalDeclData!.heartbeat.toString()
          : "";

      temperatureController.text = widget.medicalDeclData?.temperature != null
          ? widget.medicalDeclData!.temperature.toString()
          : "";

      breathingController.text = widget.medicalDeclData?.breathing != null
          ? widget.medicalDeclData!.breathing.toString()
          : "";

      bloodPressureMinController.text =
          widget.medicalDeclData?.bloodPressureMin != null
              ? widget.medicalDeclData!.bloodPressureMin.toString()
              : "";

      bloodPressureMaxController.text =
          widget.medicalDeclData?.bloodPressureMax != null
              ? widget.medicalDeclData!.bloodPressureMax.toString()
              : "";

      otherController.text = widget.medicalDeclData?.otherSymptoms != null
          ? widget.medicalDeclData!.otherSymptoms.toString()
          : "";

      spo2Controller.text = widget.medicalDeclData?.spo2 != null
          ? widget.medicalDeclData!.spo2.toString()
          : "";
    } else {
      isChecked = widget.phone != null;
      phoneNumberController.text = widget.phone ?? "";
      userNameController.text = widget.name ?? "";
    }
  }

  //submit
  void _submit() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate() &&
        ((isChecked == false) ||
            (isChecked == true && (phoneError == null || phoneError == "")))) {
      if (agree) {
        final CancelFunc cancel = showLoading();
        final response = await createMedDecl(createMedDeclDataForm(
          phoneNumber: isChecked ? phoneNumberController.text : null,
          heartBeat: int.tryParse(heartBeatController.text),
          temperature: double.tryParse(temperatureController.text),
          breathing: int.tryParse(breathingController.text),
          bloodPressureMin: int.tryParse(bloodPressureMinController.text),
          bloodPressureMax: int.tryParse(bloodPressureMaxController.text),
          mainSymtoms: mainSymptomController.text,
          extraSymtoms: extraSymptomController.text,
          otherSymtoms: otherController.text,
          spo2: double.tryParse(spo2Controller.text),
        ));

        cancel();
        showNotification(response);
      } else {
        showNotification('Vui l??ng ch???n cam k???t tr?????c khi khai b??o.',
            status: Status.error);
      }
    }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.mode == Permission.add)
                  ListTileTheme(
                    contentPadding: const EdgeInsets.only(left: 8),
                    child: CheckboxListTile(
                      title: const Text("Khai h???"),
                      controlAffinity: ListTileControlAffinity.leading,
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                        if (isChecked == false) {
                          phoneNumberController.clear();
                          userNameController.clear();
                          phoneError = "";
                          setState(() {});
                        } else {
                          phoneNumberController.text = widget.phone ?? "";
                          userNameController.text = widget.name ?? "";
                        }
                      },
                    ),
                  ),
                if (widget.mode == Permission.add && isChecked)
                  // S??T ng?????i khai h???
                  Input(
                    key: const Key("phone"),
                    label: 'S??? ??i???n tho???i',
                    hint: 'S??T ng?????i ???????c khai b??o',
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    required: isChecked,
                    type: TextInputType.phone,
                    controller: phoneNumberController,
                    validatorFunction: isChecked ? phoneValidator : null,
                    enabled: isChecked,
                    onChangedFunction: (_) async {
                      userNameController.text = "";
                      setState(() {});
                      if (phoneNumberController.text.isNotEmpty) {
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
                if ((widget.mode != Permission.add) ||
                    (widget.mode == Permission.add && isChecked))
                  Input(
                    key: const Key("name"),
                    label: 'H??? v?? t??n',
                    controller: userNameController,
                    enabled: false,
                    showClearButton: false,
                  ),

                if (widget.mode == Permission.view)
                  Input(
                    label: 'Th???i gian khai b??o',
                    initValue: widget.medicalDeclData?.createdAt != null
                        ? DateFormat("dd/MM/yyyy HH:mm:ss")
                            .format(widget.medicalDeclData!.createdAt.toLocal())
                        : "",
                    enabled: false,
                  ),
                if (widget.mode == Permission.view &&
                    widget.medicalDeclData?.createdBy != null &&
                    widget.medicalDeclData?.createdBy.id !=
                        widget.medicalDeclData?.user.code)
                  Input(
                    label: 'Ng?????i khai b??o',
                    initValue: widget.medicalDeclData!.createdBy.name,
                    enabled: false,
                  ),

                //Medical Declaration Info
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: const Text(
                    'A/ Ch??? s??? s???c kh???e:',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Input(
                  label: 'Nh???p tim (l???n/ph??t)',
                  hint: 'Nh???p tim (l???n/ph??t)',
                  type: TextInputType.number,
                  controller: heartBeatController,
                  validatorFunction: (String? num) =>
                      intRangeValidator(num, 1, 220),
                  enabled: widget.mode == Permission.add,
                ),
                Input(
                  label: 'Nhi???t ????? c?? th??? (\u00B0C)',
                  hint: 'Nhi???t ????? c?? th??? (\u00B0C)',
                  type: TextInputType.number,
                  controller: temperatureController,
                  validatorFunction: (String? num) =>
                      doubleRangeValidator(num, 30, 45),
                  enabled: widget.mode == Permission.add,
                ),
                Input(
                  label: 'N???ng ????? Oxi trong m??u (%)',
                  hint: 'N???ng ????? Oxi trong m??u (%)',
                  type: TextInputType.number,
                  controller: spo2Controller,
                  validatorFunction: (String? num) =>
                      intRangeValidator(num, 1, 100),
                  enabled: widget.mode == Permission.add,
                ),
                Input(
                  label: 'Nh???p th??? (l???n/ph??t)',
                  hint: 'Nh???p th??? (l???n/ph??t)',
                  type: TextInputType.number,
                  controller: breathingController,
                  validatorFunction: (String? num) =>
                      intRangeValidator(num, 1, 150),
                  enabled: widget.mode == Permission.add,
                ),
                Input(
                  label: 'Huy???t ??p t??m thu (mmHg)',
                  hint: 'Huy???t ??p t??m thu (mmHg)',
                  type: TextInputType.number,
                  controller: bloodPressureMaxController,
                  validatorFunction: (String? num) =>
                      intRangeValidator(num, 50, 250),
                  enabled: widget.mode == Permission.add,
                  onChangedFunction: (_) async {
                    if (bloodPressureMaxController.text.isEmpty) {
                      setState(() {});
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    }
                  },
                  required: bloodPressureMinController.text.isNotEmpty &&
                      widget.mode == Permission.add,
                ),
                Input(
                  label: 'Huy???t ??p t??m tr????ng (mmHg)',
                  hint: 'Huy???t ??p t??m tr????ng (mmHg)',
                  type: TextInputType.number,
                  controller: bloodPressureMinController,
                  validatorFunction: (String? num) =>
                      intRangeValidator(num, 10, 150),
                  enabled: widget.mode == Permission.add,
                  onChangedFunction: (_) async {
                    if (bloodPressureMinController.text.isEmpty) {
                      setState(() {});
                    } else {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                      }
                    }
                  },
                  required: bloodPressureMaxController.text.isNotEmpty &&
                      widget.mode == Permission.add,
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: const Text('B/ Tri???u ch???ng nghi nhi???m:',
                      style: TextStyle(fontSize: 16)),
                ),

                MultiDropdownInput<KeyValue>(
                  label: 'Tri???u ch???ng nghi nhi???m',
                  hint: 'Ch???n tri???u ch???ng',
                  itemValue: symptomMainList,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems: (widget.medicalDeclData?.mainSymptoms != null)
                      ? (widget.medicalDeclData!.mainSymptoms
                          .toString()
                          .split(',')
                          .map((e) => symptomMainList.safeFirstWhere(
                              (result) => result.id == int.parse(e))!)
                          .toList())
                      : null,
                  onChanged: (value) {
                    if (value == null) {
                      mainSymptomController.text = "";
                    } else {
                      mainSymptomController.text =
                          value.map((e) => e.id).join(",");
                    }
                  },
                  enabled: widget.mode != Permission.view,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Tri???u ch???ng nghi nhi???m',
                ),

                MultiDropdownInput<KeyValue>(
                  label: 'Tri???u ch???ng kh??c',
                  hint: 'Ch???n tri???u ch???ng',
                  itemValue: symptomExtraList,
                  mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                      ? Mode.DIALOG
                      : Mode.BOTTOM_SHEET,
                  dropdownBuilder: customDropDown,
                  compareFn: (item, selectedItem) =>
                      item?.id == selectedItem?.id,
                  itemAsString: (KeyValue? u) => u!.name,
                  selectedItems: (widget.medicalDeclData?.extraSymptoms != null)
                      ? (widget.medicalDeclData!.extraSymptoms
                          .toString()
                          .split(',')
                          .map((e) => symptomExtraList.safeFirstWhere(
                              (result) => result.id == int.parse(e))!)
                          .toList())
                      : null,
                  onChanged: (value) {
                    if (value == null) {
                      extraSymptomController.text = "";
                    } else {
                      extraSymptomController.text =
                          value.map((e) => e.id).join(",");
                    }
                  },
                  enabled: widget.mode != Permission.view,
                  maxHeight: MediaQuery.of(context).size.height -
                      AppBar().preferredSize.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom -
                      100,
                  popupTitle: 'Tri???u ch???ng kh??c',
                ),

                Input(
                  label: 'Kh??c',
                  hint: 'Kh??c',
                  controller: otherController,
                  enabled: widget.mode == Permission.add,
                ),
                const SizedBox(height: 8),

                //Button add medical declaration
                if (widget.mode == Permission.add)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTileTheme(
                        contentPadding: const EdgeInsets.only(left: 8),
                        child: CheckboxListTile(
                          title: Container(
                              padding: const EdgeInsets.only(right: 16),
                              child: const Text(
                                "T??i cam k???t ho??n to??n ch???u tr??ch nhi???m v??? t??nh ch??nh x??c v?? trung th???c c???a th??ng tin ???? cung c???p",
                              )),
                          value: agree,
                          onChanged: (bool? value) {
                            setState(() {
                              agree = value!;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                        child: Row(
                          children: [
                            Text(
                              '(*)',
                              style: TextStyle(
                                fontSize: 16,
                                color: error,
                              ),
                            ),
                            const Text(
                              ' Th??ng tin b???t bu???c',
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(16),
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(
                            "Khai b??o",
                            style: TextStyle(color: white),
                          ),
                        ),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
