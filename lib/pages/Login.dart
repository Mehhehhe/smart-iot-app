import 'dart:async';

import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MainPage.dart';
import 'package:smart_iot_app/services/authentication.dart';

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
            body: MainPage(),
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
}
