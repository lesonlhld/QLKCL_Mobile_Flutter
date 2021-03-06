import 'package:dropdown_search/dropdown_search.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/app.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Register extends StatefulWidget {
  static const String routeName = "/register";
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  List<KeyValue> quarantineWardList = [];

  @override
  void initState() {
    getLoginState().then((value) {
      if (value) {
        Future(() {
          Navigator.pushNamedAndRemoveUntil(
              context, App.routeName, (Route<dynamic> route) => false);
        });
      }
    });
    super.initState();
    fetchQuarantineWardNoToken({
      'is_full': "false",
    }).then((value) {
      if (mounted) {
        setState(() {
          quarantineWardList = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: background,
          iconTheme: IconThemeData(
            color: primaryText,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                margin: const EdgeInsets.all(16),
                child: Image.asset("assets/images/sign_up.png"),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 450
                      ? 450
                      : MediaQuery.of(context).size.width,
                  child: Card(
                    child: RegisterForm(quarantineWardList: quarantineWardList),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final List<KeyValue> quarantineWardList;
  const RegisterForm({
    Key? key,
    this.quarantineWardList = const [],
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();
  final passController = TextEditingController();
  final secondPassController = TextEditingController();
  final quarantineWardController = TextEditingController();
  String? dupplicateError;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(
            height: 16,
          ),
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              "????ng k?? c??ch ly",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Input(
            label: "S??? ??i???n tho???i",
            hint: "Nh???p s??? ??i???n tho???i",
            type: TextInputType.phone,
            required: true,
            validatorFunction: phoneValidator,
            controller: phoneController,
          ),
          Input(
            label: "M???t kh???u",
            hint: "Nh???p m???t kh???u",
            obscure: true,
            required: true,
            controller: passController,
            validatorFunction: passValidator,
          ),
          Input(
            label: "X??c nh???n m???t kh???u",
            hint: "X??c nh???n m???t kh???u",
            obscure: true,
            required: true,
            controller: secondPassController,
            validatorFunction: passValidator,
            error: dupplicateError,
          ),
          DropdownInput<KeyValue>(
            label: 'Khu c??ch ly',
            hint: 'Ch???n khu c??ch ly',
            itemAsString: (KeyValue? u) => u!.name,
            onFind: widget.quarantineWardList.isEmpty
                ? (String? filter) => fetchQuarantineWardNoToken({
                      'is_full': "false",
                    })
                : null,
            compareFn: (item, selectedItem) => item?.id == selectedItem?.id,
            itemValue: widget.quarantineWardList,
            onChanged: (value) {
              if (value == null) {
                quarantineWardController.text = "";
              } else {
                quarantineWardController.text = value.id.toString();
              }
            },
            mode: ResponsiveWrapper.of(context).isLargerThan(MOBILE)
                ? Mode.DIALOG
                : Mode.BOTTOM_SHEET,
            maxHeight: MediaQuery.of(context).size.height -
                AppBar().preferredSize.height -
                MediaQuery.of(context).padding.top -
                MediaQuery.of(context).padding.bottom -
                100,
            showSearchBox: true,
            required: true,
            popupTitle: 'Khu c??ch ly',
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(
                '????ng k??',
                style: TextStyle(color: white),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "????ng nh???p",
              style: TextStyle(
                color: primary,
                // decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
        ],
      ),
    );
  }

  void _submit() async {
    setState(() {
      dupplicateError = null;
    });
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      if (passController.text != secondPassController.text) {
        setState(() {
          dupplicateError = "M???t kh???u kh??ng tr??ng kh???p";
        });
      } else {
        final CancelFunc cancel = showLoading();
        final registerResponse = await register(registerDataForm(
            phoneNumber: phoneController.text,
            password: passController.text,
            quarantineWard: quarantineWardController.text));
        if (registerResponse.status == Status.success) {
          final loginResponse = await login(loginDataForm(
              phoneNumber: phoneController.text,
              password: passController.text));
          cancel();
          if (loginResponse.status == Status.success) {
            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                  context, App.routeName, (Route<dynamic> route) => false);
            }
          } else {
            showNotification(loginResponse.message, status: Status.error);
          }
        } else {
          cancel();
          showNotification(registerResponse.message, status: Status.error);
        }
      }
    }
  }
}
