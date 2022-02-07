import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/config/app_theme.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/utils/data_form.dart';

class ChangePassword extends StatefulWidget {
  static const String routeName = "/change_password";
  ChangePassword({Key? key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
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
                width: MediaQuery.of(context).size.width * 0.5,
                margin: const EdgeInsets.all(16),
                child: Image.asset("assets/images/otp.png"),
              ),
              ChangePasswordForm(),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangePasswordForm extends StatefulWidget {
  @override
  _ChangePasswordFormState createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  final _formKey = GlobalKey<FormState>();
  final oldPassController = TextEditingController();
  final passController = TextEditingController();
  final secondPassController = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(16),
            child: Text(
              "Đổi mật khẩu",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Input(
            label: "Mật khẩu cũ",
            hint: "Mật khẩu cũ",
            obscure: true,
            required: true,
            controller: oldPassController,
            validatorFunction: passValidator,
          ),
          Input(
            label: "Mật khẩu mới",
            hint: "Nhập mật khẩu mới",
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
            error: error,
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                _submit();
              },
              child: Text(
                'Xác nhận',
                style: TextStyle(color: CustomColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    setState(() {
      error = null;
    });
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      if (passController.text != secondPassController.text) {
        setState(() {
          error = "Mật khẩu không trùng khớp";
        });
      } else {
        CancelFunc cancel = showLoading();
        final response = await changePass(changePassDataForm(
            oldPassword: oldPassController.text,
            newPassword: passController.text,
            confirmPassword: secondPassController.text));
        cancel();
        showNotification(response);
        if (response.success) {
          Navigator.pop(context);
        }
      }
    }
  }
}
