import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:s_camera/pages/home_page.dart';
import 'package:s_camera/pages/registration_page.dart';

import '../common/theme_helper.dart';
import '../widgets/header_widget.dart';

enum Status { Waiting, Error }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final double _headerHeight = 250;
  final Key _formKey = GlobalKey<FormState>();
  var _status = Status.Waiting;
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;

  String verificationIDReceived = "";

  bool otpCodeVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _headerHeight,
              child: HeaderWidget(_headerHeight, true, Icons.login_rounded),
            ),
            SafeArea(
              child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  margin: const EdgeInsets.fromLTRB(
                      20, 10, 20, 10), // This will be the login form
                  child: Column(
                    children: [
                      const Text(
                        'Sign in',
                        style: TextStyle(
                            fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'Signin into your account',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 30.0),
                      Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                child: TextField(
                                  controller: phoneController,
                                  decoration: ThemeHelper().textInputDecoration(
                                      'Phone Number',
                                      'Enter your phone number'),
                                  keyboardType: TextInputType.phone,
                                ),
                                decoration:
                                    ThemeHelper().inputBoxDecorationShaddow(),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              Column(
                                children: [
                                  Container(
                                    child: Visibility(
                                      visible: otpCodeVisible,
                                      child: TextField(
                                        controller: otpController,
                                        decoration: ThemeHelper()
                                            .textInputDecoration(
                                                'Code', 'Enter your code'),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                    decoration: ThemeHelper()
                                        .inputBoxDecorationShaddow(),
                                  ),
                                  const SizedBox(
                                    height: 30.0,
                                  ),
                                  Visibility(
                                    visible: otpCodeVisible,
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 0, 0, 10),
                                      child: Text.rich(TextSpan(children: [
                                        const TextSpan(
                                            text: "Don't receive code? "),
                                        TextSpan(
                                          text: 'ResendCode',
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () {
                                              setState(() {
                                                this._status = Status.Waiting;
                                              });
                                              verifyNumber();
                                            },
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
                                        ),
                                      ])),
                                    ),
                                  ),
                                ],
                              ),

                              Container(
                                decoration:
                                    ThemeHelper().buttonBoxDecoration(context),
                                child: ElevatedButton(
                                  style: ThemeHelper().buttonStyle(),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        40, 10, 40, 10),
                                    child: Text(
                                      otpCodeVisible ? "Sign In" : "Verify",
                                      // 'Sign In'.toUpperCase(),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  onPressed: () {
                                      Navigator.pushReplacement(
                                       context, MaterialPageRoute(builder: (context) => const MyHomePage()));
                                    // if (otpCodeVisible) {
                                    //   verifyCode();
                                    // } else {
                                    //   verifyNumber();
                                    // }
                                  },
                                ),
                              ),
                              // Container(
                              //   margin:
                              //       const EdgeInsets.fromLTRB(10, 20, 10, 20),
                              //   //child: Text('Don\'t have an account? Create'),
                              //   child: Text.rich(TextSpan(children: [
                              //     const TextSpan(
                              //         text: "Don't have an account? "),
                              //     TextSpan(
                              //       text: 'Create',
                              //       recognizer: TapGestureRecognizer()
                              //         ..onTap = () {
                              //           Navigator.push(
                              //               context,
                              //               MaterialPageRoute(
                              //                   builder: (context) =>
                              //                       const RegistrationPage()));
                              //         },
                              //       style: TextStyle(
                              //           fontWeight: FontWeight.bold,
                              //           color: Theme.of(context)
                              //               .colorScheme
                              //               .secondary),
                              //     ),
                              //   ])),
                              // ),
                            ],
                          )),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  void verifyNumber() {
    auth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value) {
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException exception) {
          print(exception.message);
        },
        codeSent: (String verificationID, int? resendToken) {
          verificationIDReceived = verificationID;
          otpCodeVisible = true;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationID) {});
  }

  void verifyCode() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationIDReceived, smsCode: otpController.text);
    await auth.signInWithCredential(credential).then((value) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MyHomePage()));
    });
  }
}
