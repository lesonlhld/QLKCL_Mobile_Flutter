import 'package:dropdown_search/dropdown_search.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/dropdown_field.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/helper/function.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/models/key_value.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/app.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/screens/members/update_member_screen.dart';
import 'package:qlkcl/utils/data_form.dart';
import 'package:responsive_framework/responsive_framework.dart';

class Register extends StatefulWidget {
  static const String routeName = "/register";
  Register({Key? key}) : super(key: key);

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
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return DismissKeyboard(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: CustomColors.background,
          iconTheme: IconThemeData(
            color: CustomColors.primaryText,
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
  RegisterForm({
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
              "Đăng ký cách ly",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Input(
            label: "Số điện thoại",
            hint: "Nhập số điện thoại",
            type: TextInputType.phone,
            required: true,
            validatorFunction: phoneValidator,
            controller: phoneController,
          ),
          Input(
            label: "Mật khẩu",
            hint: "Nhập mật khẩu",
            obscure: true,
            required: true,
            controller: passController,
            validatorFunction: passValidator,
          ),
          Input(
            label: "Xác nhận mật khẩu",
            hint: "Xác nhận mật khẩu",
            obscure: true,
            required: true,
            controller: secondPassController,
            validatorFunction: passValidator,
            error: dupplicateError,
          ),
          DropdownInput<KeyValue>(
            label: 'Khu cách ly',
            hint: 'Chọn khu cách ly',
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
            popupTitle: 'Khu cách ly',
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(
                'Đăng ký',
                style: TextStyle(color: CustomColors.white),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Text(
              "Đăng nhập",
              style: TextStyle(
                color: CustomColors.primary,
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
          dupplicateError = "Mật khẩu không trùng khớp";
        });
      } else {
        CancelFunc cancel = showLoading();
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
            Navigator.pushNamedAndRemoveUntil(
                context, App.routeName, (Route<dynamic> route) => false);
            Navigator.of(context,
                    rootNavigator: !Responsive.isDesktopLayout(context))
                .push(
              MaterialPageRoute(builder: (context) => UpdateMember()),
            );
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
