import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:qlkcl/components/bot_toast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qlkcl/helper/authentication.dart';
import 'package:qlkcl/helper/dismiss_keyboard.dart';
import 'package:qlkcl/networking/response.dart';
import 'package:qlkcl/screens/login/create_password_screen.dart';
import 'package:qlkcl/utils/app_theme.dart';
import 'package:qlkcl/utils/data_form.dart';

// cre: https://pub.dev/packages/pin_code_fields

class Otp extends StatefulWidget {
  static const String routeName = "/otp";
  const Otp({Key? key, required this.email}) : super(key: key);
  final String email;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _formKey = GlobalKey<FormState>();
  late String otp;
  bool hasError = false;
  TextEditingController textEditingController = TextEditingController();

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
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
                child: Image.asset("assets/images/otp.png"),
              ),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width > 450
                      ? 450
                      : MediaQuery.of(context).size.width,
                  child: Card(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Text(
                            "Nh???p m?? x??c th???c",
                            style: Theme.of(context).textTheme.headline6,
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            "M?? x??c nh???n ???? ???????c g???i qua email",
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ),
                        Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 70),
                            child: PinCodeTextField(
                              appContext: context,
                              length: 4,
                              animationType: AnimationType.fade,
                              pinTheme: PinTheme(
                                shape: PinCodeFieldShape.box,
                                borderRadius: BorderRadius.circular(5),
                                fieldHeight: 62,
                                fieldWidth: 48,
                                activeFillColor: Colors.white,
                              ),
                              cursorColor: Colors.black,
                              animationDuration:
                                  const Duration(milliseconds: 300),
                              errorAnimationController: errorController,
                              controller: textEditingController,
                              keyboardType: TextInputType.number,
                              onCompleted: (value) {
                                setState(() {
                                  otp = value;
                                });
                              },
                              onChanged: (value) {
                                setState(() {
                                  otp = value;
                                });
                              },
                              validator: (value) {
                                if (value!.length < 4) {
                                  return "Vui l??ng nh???p m?? OTP";
                                } else {
                                  return null;
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(16),
                          child: ElevatedButton(
                            onPressed: _submit,
                            child: Text(
                              'X??c nh???n OTP',
                              style: TextStyle(color: white),
                            ),
                          ),
                        ),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Ch??a nh???n ???????c m??? ",
                              ),
                              TextSpan(
                                text: 'G???i l???i m??',
                                style: TextStyle(
                                    color: primary,
                                    decoration: TextDecoration.underline),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _reSend,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
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
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      setState(
        () {
          hasError = false;
        },
      );
      final CancelFunc cancel = showLoading();
      final response =
          await sendOtp(sendOtpDataForm(email: widget.email, otp: otp));
      cancel();
      if (response.status == Status.success) {
        if (mounted) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreatePassword(
                        email: widget.email,
                        otp: response.data,
                      )));
        }
      } else {
        showNotification(response.message, status: Status.error);
      }
    } else {
      errorController!
          .add(ErrorAnimationType.shake); // Triggering error shake animation
      setState(() => hasError = true);
    }
  }

  void _reSend() async {
    // Validate returns true if the form is valid, or false otherwise.
    if (_formKey.currentState!.validate()) {
      final CancelFunc cancel = showLoading();
      final response =
          await requestOtp(requestOtpDataForm(email: widget.email));
      cancel();
      showNotification(response);
    }
  }
}
