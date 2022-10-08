import 'dart:async';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MainPage.dart';
import 'package:smart_iot_app/pages/ResetPassWordPage.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/RegisterPage.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Generated in previous step
import '../amplifyconfiguration.dart';

// Initialize AWS Auth in authentication page instead.
Future<void> _configureAmplify() async {
  // Add AWS plugin
  final authPlugin = AmplifyAuthCognito();
  await Amplify.addPlugin(authPlugin);
  try {
    await Amplify.configure(amplifyconfig);
  } on AmplifyAlreadyConfiguredException {
    print("Tried to re-configure; Android app was restarted");
  }
}

class LogIn extends StatefulWidget {
  //const LogIn({Key? key, required this.auth, required this.loginCallback})
  //    : super(key: key);
  const LogIn({Key? key}) : super(key: key);

  //final BaseAuth auth;
  //final VoidCallback loginCallback;

  @override
  State<LogIn> createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  // User variables
  Map<String, dynamic> account = {"name": "", "id": ""};

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // User-related methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromRGBO(146, 252, 232, 1.0),
      body: _awsAuth(),
      /*body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(255, 63, 242, 1.0),
              Color.fromRGBO(123, 168, 255, 1.0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          //gradient : LinearGradient(
          //                               begin: Alignment(0.38533756136894226,0.47234928607940674),
          //                               end: Alignment(-0.47234928607940674,0.38533756136894226),
          //                               colors: [Color.fromRGBO(255, 0, 184, 1),Color.fromRGBO(34, 0, 241, 0.4947916567325592),Color.fromRGBO(0, 255, 240, 0)]
          //                           ),
        ),
        child: Stack(
          children: [
            loginFrame(),
            _showForm(),
            _showCircularProgress(),
          ],
        ),
      ),*/
    );
  }

  Widget _awsAuth() {
    return Authenticator(
        authenticatorBuilder: (p0, p1) {
          const padding =
              EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 16);
          switch (p1.currentStep) {
            case AuthenticatorStep.loading:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.onboarding:
              break;
            case AuthenticatorStep.signUp:
              return _signUpForm(padding, p1);
              break;
            case AuthenticatorStep.signIn:
              return _signInForm(padding, p1);
              break;
            case AuthenticatorStep.confirmSignUp:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.confirmSignInCustomAuth:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.confirmSignInMfa:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.confirmSignInNewPassword:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.resetPassword:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.confirmResetPassword:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.verifyUser:
              // TODO: Handle this case.
              break;
            case AuthenticatorStep.confirmVerifyUser:
              // TODO: Handle this case.
              break;
          }
        },
        // initialStep: AuthenticatorStep.signUp,
        child: MaterialApp(
          builder: Authenticator.builder(),
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            body: MainPage(),
          ),
        ));
  }

  // Widget _showCircularProgress() {
  //   if (_isLoading) {
  //     return const Center(
  //       child: CircularProgressIndicator(),
  //     );
  //   }
  //   return const SizedBox(
  //     height: 0.0,
  //     width: 0.0,
  //   );
  // }

  Widget _signUpForm(EdgeInsets padding, AuthenticatorState state) {
    return Scaffold(
      body: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Center(
                child: FlutterLogo(
                  size: 100,
                ),
              ),
              SignUpForm.custom(fields: [
                SignUpFormField.username(),
                SignUpFormField.email(required: true),
                SignUpFormField.password(),
                SignUpFormField.passwordConfirmation(),
              ]),
              const Divider(color: Colors.black),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: 18),
                  ),
                  TextButton(
                      onPressed: () =>
                          state.changeStep(AuthenticatorStep.signIn),
                      child: const Text(
                        "Sign in",
                        style: TextStyle(fontSize: 18),
                      ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _signInForm(EdgeInsets padding, AuthenticatorState state) {
    return Scaffold(
      body: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 600,
                color: Colors.amber,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Center(
                      child: FlutterLogo(
                        size: 100,
                      ),
                    ),
                    SignInForm.custom(fields: [
                      SignInFormField.username(),
                      SignInFormField.password()
                    ]),
                    const Divider(
                      color: Colors.black,
                      height: 30,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 18),
                        ),
                        TextButton(
                            onPressed: () =>
                                state.changeStep(AuthenticatorStep.signUp),
                            child: const Text(
                              "Sign up",
                              style: TextStyle(fontSize: 18),
                            ))
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget _showForm() {
  //   return Container(
  //     child: Container(
  //       padding: const EdgeInsets.all(15.0),
  //       child: Form(
  //         key: _formKey,
  //         child: Center(
  //           child: ListView(
  //             shrinkWrap: true,
  //             children: <Widget>[
  //               //showTitle(),
  //               showLogo(),
  //               Emailtext(),
  //               showEmailInput(),
  //               Passwordtext(),
  //               showPasswordInput(),
  //               forgotPassword(),
  //               showLoginButton(),
  //               showRegisterButton(),
  //               showOtherLogInOption(),
  //               showErrorMsg(),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget showErrorMsg() {
  //   if (_errorMsg.isNotEmpty) {
  //     return Text(
  //       _errorMsg,
  //       style: const TextStyle(
  //         fontSize: 18.0,
  //         color: Colors.red,
  //         height: 1.0,
  //         fontWeight: FontWeight.w500,
  //       ),
  //     );
  //   } else {
  //     return Container(
  //       height: 0.0,
  //     );
  //   }
  // }

  // Widget Emailtext() {
  //   return Container(
  //     margin: EdgeInsets.only(left: 30, bottom: 15),
  //     alignment: Alignment.bottomLeft,
  //     child: Text(
  //       "Email address",
  //       textAlign: TextAlign.left,
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 17,
  //         shadows: <Shadow>[
  //           Shadow(
  //             offset: Offset(0.0, 2.0),
  //             blurRadius: 12,
  //             color: Color.fromARGB(255, 0, 0, 0),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget showEmailInput() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20),
  //     child: SizedBox(
  //       width: 300,
  //       height: 80,
  //       child: TextFormField(
  //         obscureText: false,
  //         maxLines: 1,
  //         keyboardType: TextInputType.emailAddress,
  //         decoration: InputDecoration(
  //           filled: true,
  //           fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
  //           suffixIcon: const Icon(Icons.account_circle),
  //           border: OutlineInputBorder(
  //             borderSide: BorderSide.none,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           hintText: 'Username',
  //         ),
  //         validator: (value) =>
  //             value!.isEmpty ? 'Please enter your email' : null,
  //         onSaved: (value) => _email = value!.trim(),
  //       ),
  //     ),
  //   );
  // }

  // Widget Passwordtext() {
  //   return Container(
  //     margin: EdgeInsets.only(left: 30, bottom: 15),
  //     alignment: Alignment.bottomLeft,
  //     child: Text(
  //       "Password",
  //       textAlign: TextAlign.left,
  //       style: TextStyle(
  //         color: Colors.white,
  //         fontSize: 17,
  //         shadows: <Shadow>[
  //           Shadow(
  //             offset: Offset(0.0, 2.0),
  //             blurRadius: 12,
  //             color: Color.fromARGB(255, 0, 0, 0),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget showPasswordInput() {
  //   return Container(
  //     margin: EdgeInsets.symmetric(horizontal: 20),
  //     child: SizedBox(
  //       width: 300,
  //       child: TextFormField(
  //         obscureText: _isObscure,
  //         //obscureText: true,
  //         maxLines: 1,
  //         decoration: InputDecoration(
  //           filled: true,
  //           fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
  //           suffixIcon: IconButton(
  //             icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
  //             onPressed: () {
  //               setState(() {
  //                 _isObscure = !_isObscure;
  //               });
  //             },
  //           ),
  //           border: OutlineInputBorder(
  //             borderSide: BorderSide.none,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           labelText: 'Password',
  //         ),
  //         validator: (value) => value!.isEmpty ? 'Please enter password' : null,
  //         onSaved: (value) => _password = value!.trim(),
  //       ),
  //     ),
  //   );
  // }

  // Widget showLoginButton() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 60),
  //     width: 200,
  //     height: 50,
  //     decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [
  //             Color.fromRGBO(255, 57, 57, 1.0),
  //             Color.fromRGBO(255, 224, 93, 1.0),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //         borderRadius: const BorderRadius.all(
  //           Radius.circular(25.0),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.pink.withOpacity(0.2),
  //             spreadRadius: 4,
  //             blurRadius: 10,
  //             offset: const Offset(0, 3),
  //           )
  //         ]),
  //     child: OutlinedButton(
  //       style: ButtonStyle(
  //         shape: MaterialStateProperty.all(
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  //         ),
  //       ),
  //       onPressed: validateAndSubmit,
  //       child: const Text(
  //         'Login',
  //         textAlign: TextAlign.left,
  //         style: TextStyle(
  //           fontFamily: "Roboto Slab",
  //           fontWeight: FontWeight.w600,
  //           fontSize: 18,
  //           letterSpacing: 0.0,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget showRegisterButton() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(horizontal: 60),
  //     width: 200,
  //     height: 50,
  //     decoration: BoxDecoration(
  //         gradient: const LinearGradient(
  //           colors: [
  //             Color.fromRGBO(41, 56, 220, 1.0),
  //             Color.fromRGBO(118, 182, 255, 1.0),
  //           ],
  //           begin: Alignment.centerLeft,
  //           end: Alignment.centerRight,
  //         ),
  //         borderRadius: const BorderRadius.all(
  //           Radius.circular(25.0),
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.pink.withOpacity(0.2),
  //             spreadRadius: 4,
  //             blurRadius: 10,
  //             offset: const Offset(0, 3),
  //           )
  //         ]),
  //     child: OutlinedButton(
  //       style: ButtonStyle(
  //         shape: MaterialStateProperty.all(
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
  //         ),
  //       ),
  //       onPressed: () {
  //         /*Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //               builder: (context) => Register(
  //                     auth: widget.auth,
  //                     loginCallback: widget.loginCallback,
  //                   )),
  //         );*/
  //       },
  //       child: const Text(
  //         'Create new account',
  //         textAlign: TextAlign.left,
  //         style: TextStyle(
  //           fontFamily: "Roboto Slab",
  //           fontWeight: FontWeight.w600,
  //           fontSize: 18,
  //           letterSpacing: 0.0,
  //           color: Colors.white,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget showLogo() {
  //   return Container(
  //     margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 85),
  //     width: 150,
  //     height: 190,
  //     decoration: BoxDecoration(
  //       borderRadius: const BorderRadius.only(
  //         topLeft: Radius.circular(154.5),
  //         topRight: Radius.circular(154.5),
  //         bottomLeft: Radius.circular(154.5),
  //         bottomRight: Radius.circular(154.5),
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.pink.withOpacity(0.2),
  //           spreadRadius: 4,
  //           blurRadius: 10,
  //           offset: const Offset(0, 3),
  //         )
  //       ],
  //     ),
  //     child: Image.network(
  //         'https://bursakerja.jatengprov.go.id/assets/default-logo.png',
  //         fit: BoxFit.fitWidth),
  //   );
  // }

  // Widget showOtherLogInOption() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: IconButton(
  //           icon: Image.asset('assets/images/Facebook_icon.png'),
  //           iconSize: 50,
  //           onPressed: () {},
  //         ),
  //       ),
  //       Padding(
  //         padding: const EdgeInsets.all(10.0),
  //         child: IconButton(
  //           icon: Image.asset('assets/images/google_icon.png'),
  //           iconSize: 60,
  //           onPressed: () async {
  //             /*String? userId = await widget.auth.signInWithGoogle();
  //             if (userId!.isNotEmpty) {
  //               widget.loginCallback();
  //             }*/
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget forgotPassword() {
  //   return Row(
  //     children: [
  //       Container(
  //         margin: EdgeInsets.only(left: 30),
  //         height: 15,
  //         width: 15,
  //         decoration: BoxDecoration(color: Colors.white),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(left: 10),
  //         //alignment: Alignment.bottomLeft,
  //         child: Text(
  //           "Keep me signin",
  //           //textAlign: TextAlign.right,
  //           style: TextStyle(
  //             color: Colors.white,
  //             shadows: <Shadow>[
  //               Shadow(
  //                 offset: Offset(0.0, 2.0),
  //                 blurRadius: 12,
  //                 color: Color.fromARGB(255, 0, 0, 0),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       Container(
  //         margin: EdgeInsets.only(left: 70),
  //         //alignment: Alignment.bottomRight,
  //         child: TextButton(
  //           child: const Text(
  //             "Forgot Password",
  //             //textAlign: TextAlign.right,
  //             style: TextStyle(
  //               color: Colors.white,
  //               shadows: <Shadow>[
  //                 Shadow(
  //                   offset: Offset(0.0, 2.0),
  //                   blurRadius: 12,
  //                   color: Color.fromARGB(255, 0, 0, 0),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           onPressed: () async {
  //             /*Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                   builder: (context) =>
  //                       ResetPassWord_Page(auth: widget.auth)),
  //             );*/
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  // Widget loginFrame() {
  //   return Container(
  //       height: 615,
  //       margin: EdgeInsets.only(top: 150, left: 20, right: 20),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.only(
  //           topLeft: Radius.circular(16),
  //           topRight: Radius.circular(16),
  //           bottomLeft: Radius.circular(16),
  //           bottomRight: Radius.circular(16),
  //         ),
  //         color: Color.fromRGBO(255, 255, 255, 0.3),
  //       ));
  // }
}
