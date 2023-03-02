import 'dart:async';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';
import 'package:smart_iot_app/pages/MainPage.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/authentication.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Generated in previous step
import '../amplifyconfiguration.dart';
import 'onboard.dart';

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
      body: _awsAuth(),
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
            body: FutureBuilder(
              future: _isOnboardingCompleted(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data == true) {
                  return farmCard();
                } else {
                  return OnboardingPage();
                }
              },
            ),
          ),
        ));
  }

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
                    onPressed: () => state.changeStep(AuthenticatorStep.signIn),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
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
              Stack(
                children: [
                  Container(
                    height: 450,
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    margin: const EdgeInsets.only(top: 70),
                    // decoration: BoxDecoration(
                    //     color: Colors.amber,
                    //     borderRadius: BorderRadius.circular(25),
                    //     boxShadow: const [
                    //       BoxShadow(
                    //         blurRadius: 4,
                    //         color: Color(0x33000000),
                    //         offset: Offset(0, 5),
                    //       )
                    //     ]),
                    child: Column(
                      children: [
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
                  const Center(
                    child: FlutterLogo(
                      size: 100,
                    ),
                  ),
                  // Center(
                  //   child: CircleAvatar(
                  //     radius: 80,
                  //     backgroundColor: Colors.black87,
                  //     child: Container(
                  //       height: 110,
                  //       width: 110,
                  //       decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.white,
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black26,
                  //             offset: Offset(0, 2),
                  //             blurRadius: 6,
                  //           ),
                  //         ],
                  //       ),
                  //       child: Image.network(
                  //         "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBwvh_i0UMh_LTBJ17Ct47fqBSwLVy142SgYa7QpZxbIuV_6Mn_UKLvObmWvzvJw0r92c&usqp=CAU",
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _isOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding') ?? false;
  }
}
