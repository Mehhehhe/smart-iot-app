import 'dart:async';

// import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user_agentx/flutter_user_agent.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';
// import 'package:smart_iot_app/pages/MainPage.dart';
// import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/authentication.dart';

// Amplify Flutter Packages
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Generated in previous step
import '../amplifyconfiguration.dart';
import 'onboard.dart';

import '../secrets/secrets.dart';

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
  final InAppBrowser browser = InAppBrowser();
  LogIn({Key? key, required this.onboard}) : super(key: key);

  //final BaseAuth auth;
  //final VoidCallback loginCallback;
  final bool onboard;

  @override
  State<LogIn> createState() => _LogIn();
}

class _LogIn extends State<LogIn> with SingleTickerProviderStateMixin {
  // User variables
  Map<String, dynamic> account = {"name": "", "id": ""};
  late SharedPreferences prefs;
  bool pageSwitch = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _configureAmplify();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  // User-related methods

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      body: _awsAuth(),
    );
  }

  //ignore: long-method
  Widget _awsAuth() {
    return Authenticator(
      authenticatorBuilder: (p0, p1) {
        const padding =
            EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 16);
        switch (p1.currentStep) {
          case AuthenticatorStep.loading:
            break;
          case AuthenticatorStep.onboarding:
            break;
          case AuthenticatorStep.signUp:
            return AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: _animation,
                  child: child,
                );
              },
              child: _signUpForm(padding, p1),
            );
          // return _signUpForm(padding, p1);
          case AuthenticatorStep.signIn:
            return AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 100,
              ),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: _animation,
                  child: child,
                );
                // return ScaleTransition(scale: _animation, child: child);
              },
              child: _signInForm(padding, p1),
            );
          case AuthenticatorStep.confirmSignUp:
            break;
          case AuthenticatorStep.confirmSignInCustomAuth:
            break;
          case AuthenticatorStep.confirmSignInMfa:
            break;
          case AuthenticatorStep.confirmSignInNewPassword:
            break;
          case AuthenticatorStep.resetPassword:
            break;
          case AuthenticatorStep.confirmResetPassword:
            break;
          case AuthenticatorStep.verifyUser:
            break;
          case AuthenticatorStep.confirmVerifyUser:
            break;
        }
      },
      // initialStep: AuthenticatorStep.signUp,
      child: mainApp(),
    );
  }

  Widget mainApp() {
    return MaterialApp(
      builder: Authenticator.builder(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context) {
            if (widget.onboard) {
              return farmCard();
            }

            return OnboardingPage();
          },
        ),
        // FutureBuilder(
        //   future: _isOnboardingCompleted(),
        //   builder: (context, snapshot) {
        //     return snapshot.hasData && snapshot.data == true
        //         ? farmCard()
        //         : OnboardingPage();
        //   },
        // ),
      ),
    );
  }

  // ignore: long-method
  Widget _signUpForm(EdgeInsets padding, AuthenticatorState state) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(253, 167, 102, 0.2),
            Color.fromRGBO(253, 183, 119, 1.0),
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.blueGrey,
                          spreadRadius: 1,
                          blurRadius: 5,
                          blurStyle: BlurStyle.normal,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    margin: const EdgeInsets.only(top: 70),
                    child: Column(
                      children: [
                        // const Text(
                        //   "Karriot",
                        //   style: TextStyle(
                        //     fontSize: 24,
                        //     fontWeight: FontWeight.bold,
                        //   ),
                        // ),
                        SignUpForm.custom(
                          fields: [
                            SignUpFormField.username(),
                            SignUpFormField.email(required: true),
                            SignUpFormField.password(),
                            SignUpFormField.passwordConfirmation(),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                            TextButton(
                              onPressed: () {
                                _controller.reset();
                                _controller.forward();
                                state.changeStep(AuthenticatorStep.signIn);
                              },
                              child: const Text(
                                "Sign in",
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Replace logo here!
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Container(
                        height: 150.0,
                        width: 150.0,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/appicon.jpg'),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
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

  // ignore: long-method
  Widget _signInForm(EdgeInsets padding, AuthenticatorState state) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black87,
            Colors.black87,
            Colors.black,
          ],
        ),
      ),
      child: Padding(
        padding: padding,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  all_box(),
                  Container(
                    // height: MediaQuery.of(context).size.height * 0.7,

                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    margin: const EdgeInsets.only(top: 90),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 80.0,
                        ),
                        /*const Text(
                          "Karriot",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),*/
                        SignInForm(includeDefaultSocialProviders: true),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                _controller.reset();
                                _controller.forward();
                                state.changeStep(AuthenticatorStep.signUp);
                              },
                              child: const Text(
                                "Sign up",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'OpenSans',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Logo replace here!
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.0),
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/appicon.jpg'),
                            fit: BoxFit.fill,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15,
                              offset: Offset(5, 5), // Shadow position
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Center(
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget all_box() {
  return Padding(
    padding: const EdgeInsets.only(top: 197),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Email_box(),
        SizedBox(
          height: 7,
        ),
        Password_box(),
        SizedBox(
          height: 183,
        ),
        hotmail_box(),
      ],
    ),
  );
}

Widget Email_box() {
  return Padding(
    padding: const EdgeInsets.only(top: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '  Email',
          style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 55,
        )
      ],
    ),
  );
}

Widget Password_box() {
  return Padding(
    padding: const EdgeInsets.only(top: 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '  Password',
          style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
              fontSize: 15),
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 55,
        )
      ],
    ),
  );
}

Widget Sign_in() {
  return Padding(
      padding: const EdgeInsets.only(top: 396),
      child: Container(
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        height: 37,
      ));
}

Widget hotmail_box() {
  return Center(
    child: Padding(
        padding: const EdgeInsets.only(top: 0),
        child: Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 43,
          width: 320,
        )),
  );
}

Widget box() {
  return Padding(
    padding: const EdgeInsets.only(top: 190),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6.0,
                offset: Offset(0, 2),
              ),
            ],
          ),
          height: 220,
        ),
      ],
    ),
  );
}
