import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/login/otp_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/data_form.dart';

class ForgetPassword extends StatefulWidget {
  static const String routeName = "/forget_password";
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
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
                child: Image.asset("assets/images/forget_password.png"),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 450
                      ? 450
                      : MediaQuery.of(context).size.width,
                  child: Card(
                    child: ForgetForm(),
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

class ForgetForm extends StatefulWidget {
  @override
  _ForgetFormState createState() => _ForgetFormState();
}

class _ForgetFormState extends State<ForgetForm> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

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
            alignment: Alignment.center,
            child: Text(
              "Qu??n m???t kh???u",
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Text(
              "Nh???p email kh??i ph???c ????? ?????t l???i m???t kh???u ho???c li??n h??? ng?????i qu???n l?? ????? h??? tr??? th??m.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          Input(
            label: "Email",
            hint: "Nh???p email",
            required: true,
            type: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            controller: emailController,
            validatorFunction: emailValidator,
          ),
          Container(
            margin: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _submit,
              child: Text(
                'Ti???p theo',
                style: TextStyle(color: white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      final CancelFunc cancel = showLoading();
      final response =
          await requestOtp(requestOtpDataForm(email: emailController.text));
      cancel();
      showNotification(response);
      if (response.status == Status.success) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Otp(email: emailController.text)));
        }
      }
    }
  }
}
