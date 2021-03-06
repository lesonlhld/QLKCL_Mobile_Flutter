import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/date_input.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/custom_user.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/models/vaccine_dose.dart';
import 'package:qlkcl/networking/request_helper.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/vaccine/vaccination_certificate_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/constant.dart';
import 'package:intl/intl.dart';
import 'package:qlkcl/utils/data_form.dart';

class SyncVaccinePortal extends StatefulWidget {
  const SyncVaccinePortal({
    Key? key,
    this.code,
  }) : super(key: key);
  final String? code;

  @override
  _SyncVaccinePortalState createState() => _SyncVaccinePortalState();
}

class _SyncVaccinePortalState extends State<SyncVaccinePortal> {
  final _formKey = GlobalKey<FormState>();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final birthdayController = TextEditingController();
  final genderController = TextEditingController();
  final identityNumberController = TextEditingController();
  final healthInsuranceNumberController = TextEditingController();
  final passportNumberController = TextEditingController();
  final otpController = TextEditingController();
  bool enableNext = false;

  @override
  void initState() {
    super.initState();
    final CancelFunc cancel = showLoading();
    if (widget.code != null) {
      fetchUser(data: {'code': widget.code}).then((value) {
        cancel();
        fullNameController.text = value.data["custom_user"]["full_name"];
        phoneNumberController.text = value.data["custom_user"]["phone_number"];
        birthdayController.text = DateFormat('dd/MM/yyyy')
            .parse(value.data["custom_user"]["birthday"])
            .toIso8601String();
        genderController.text = value.data["custom_user"]["gender"];
        setState(() {});
      });
    } else {
      getName().then((value) {
        fullNameController.text = value;
        setState(() {});
      });
      getPhoneNumber().then((value) {
        phoneNumberController.text = value;
        setState(() {});
      });
      getBirthday().then((value) {
        birthdayController.text =
            DateFormat('dd/MM/yyyy').parse(value).toIso8601String();
        setState(() {});
      });
      getGender().then((value) {
        genderController.text = value;
        setState(() {});
      });
      cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tra c???u ch???ng nh???n ti??m'),
          centerTitle: true,
        ),
        body: fullNameController.text.isNotEmpty
            ? SingleChildScrollView(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    constraints:
                        const BoxConstraints(minWidth: 100, maxWidth: 800),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Input(
                            label: 'H??? v?? t??n',
                            required: true,
                            textCapitalization: TextCapitalization.words,
                            controller: fullNameController,
                            // enabled: false,
                          ),
                          Input(
                            label: 'S??? ??i???n tho???i',
                            required: true,
                            type: TextInputType.phone,
                            controller: phoneNumberController,
                            validatorFunction: phoneValidator,
                            enabled: false,
                          ),
                          DropdownInput<KeyValue>(
                            label: 'Gi???i t??nh',
                            hint: 'Ch???n gi???i t??nh',
                            required: true,
                            itemValue: genderList,
                            itemAsString: (KeyValue? u) => u!.name,
                            maxHeight: 112,
                            compareFn: (item, selectedItem) =>
                                item?.id == selectedItem?.id,
                            selectedItem: genderList.safeFirstWhere(
                                (gender) => gender.id == genderController.text),
                            onChanged: (value) {
                              if (value == null) {
                                genderController.text = "";
                              } else {
                                genderController.text = value.id;
                              }
                            },
                            // enabled: false,
                          ),
                          NewDateInput(
                            label: 'Ng??y sinh',
                            required: true,
                            controller: birthdayController,
                            maxDate: DateTime.now(),
                            //enabled: false,
                            helper: "Ch???n ng??y 1/1 khi ch??? bi???t n??m sinh",
                          ),
                          // Input(
                          //   label: 'S??? CMND/CCCD',
                          //   type: TextInputType.number,
                          //   controller: identityNumberController,
                          // ),
                          // Input(
                          //   label: 'M?? s??? BHXH/Th??? BHYT',
                          //   controller: healthInsuranceNumberController,
                          // ),
                          // Input(
                          //   label: 'S??? h??? chi???u',
                          //   controller: passportNumberController,
                          //   textCapitalization: TextCapitalization.characters,
                          //   validatorFunction: passportValidator,
                          // ),
                          Input(
                            label: 'OTP',
                            controller: otpController,
                            type: TextInputType.number,
                            enabled: enableNext,
                            required: enableNext,
                            helper: "Nh???p OTP tr?????c khi th???c hi???n tra c???u",
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            margin: const EdgeInsets.fromLTRB(16, 16, 0, 0),
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: primaryText,
                                  fontSize: 15,
                                ),
                                children: [
                                  TextSpan(
                                    text: '(*)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: error,
                                    ),
                                  ),
                                  const TextSpan(
                                    text:
                                        ' Vui l??ng ki???m tra ch??nh x??c th??ng tin c?? nh??n tr?????c khi nh???n ch???n "Nh???n OTP".',
                                    style: TextStyle(
                                      height: 1.5,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                const Spacer(),
                                OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      enableNext = false;
                                    });
                                    _otp();
                                  },
                                  child: const Text("Nh???n OTP"),
                                ),
                                const Spacer(),
                                ElevatedButton(
                                  onPressed: enableNext ? _submit : null,
                                  child: const Text("Tra c???u"),
                                ),
                                const Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  void _otp() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      final CancelFunc cancel = showLoading();

      final RequestHelper provider =
          RequestHelper(baseUrl: "https://tiemchungcovid19.gov.vn");

      final response = await provider.get(
        "/api/vaccination/public/otp-search",
        params: syncVaccinePortalDataForm(
          birthday: DateTime.parse(birthdayController.text)
              .copyWith(hour: 7)
              .toUtc()
              .millisecondsSinceEpoch
              .toString(),
          fullName: fullNameController.text,
          gender: genderController.text == "MALE" ? "1" : "2",
          phoneNumber: phoneNumberController.text,
        ),
      );
      cancel();
      if (response.status == Status.success) {
        if (response.data['code'] == 1) {
          showNotification(response.data['message']);
          setState(() {
            enableNext = true;
          });
        }
      } else {
        showNotification(response.data['message'], status: Status.error);
      }
    }
  }

  void _submit() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      final CancelFunc cancel = showLoading();

      final RequestHelper provider =
          RequestHelper(baseUrl: "https://tiemchungcovid19.gov.vn");

      final response = await provider.get(
        "/api/vaccination/public/patient-vaccinated",
        params: syncVaccinePortalDataForm(
          birthday: DateTime.parse(birthdayController.text)
              .copyWith(
                  hour: 7, minute: 0, second: 0, microsecond: 0, millisecond: 0)
              .toUtc()
              .millisecondsSinceEpoch
              .toString(),
          fullName: fullNameController.text,
          gender: genderController.text == "MALE" ? "1" : "2",
          phoneNumber: phoneNumberController.text,
          otpNumber: otpController.text,
        ),
      );
      print(response.data);
      cancel();
      if (response.status == Status.success) {
        if (response.data['errorResponse']['code'] == 1) {
          final VaccinationCertification vaccineCertification =
              VaccinationCertification.fromJson(response.data);
          if (mounted) {
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(MaterialPageRoute(
                    builder: (context) => VaccinationCertificationScreen(
                        vaccineCertification: vaccineCertification)));
          }
        }
      } else {
        showNotification(response.data['title'], status: Status.error);
      }
    }
  }
}
