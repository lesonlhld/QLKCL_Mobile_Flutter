import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:qlkcl/components/input.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/helper/validation.dart';
import 'package:qlkcl/utils/data_form.dart';

class CreatePassword extends StatefulWidget {
  static const String routeName = "/create_password";
  const CreatePassword({Key? key, required this.email, required this.otp})
      : super(key: key);
  final String email;
  final String otp;

  @override
  _CreatePasswordState createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  final _formKey = GlobalKey<FormState>();
  final passController = TextEditingController();
  final secondPassController = TextEditingController();
  final quarantineWardController = TextEditingController();
  String? error;

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
                child: Image.asset("assets/images/otp.png"),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 450
                      ? 450
                      : MediaQuery.of(context).size.width,
                  child: Card(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 16,
                          ),
                          Container(
                            alignment: Alignment.center,
                            child: Text(
                              "T???o m???t kh???u m???i",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          Input(
                            label: "M???t kh???u m???i",
                            hint: "Nh???p m???t kh???u m???i",
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
                            error: error,
                          ),
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
              ),
            ],
          ),
        ),
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
          error = "M???t kh???u kh??ng tr??ng kh???p";
        });
      } else {
        final CancelFunc cancel = showLoading();
        final response = await createPass(createPassDataForm(
            email: widget.email,
            otp: widget.otp,
            newPassword: passController.text,
            confirmPassword: secondPassController.text));
        cancel();
        showNotification(response);
        if (response.status == Status.success) {
          if (mounted) {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      }
    }
  }
}
