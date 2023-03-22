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
  LogIn({Key? key}) : super(key: key);

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
    // return Scaffold(
    //   appBar: AppBar(title: Text("Test Web Auth")),
    //   body: Column(children: [
    //     ElevatedButton(
    //       onPressed: () => hostedUIWebView(),
    //       child: const Text("Sign in"),
    //     ),
    //   ]),
    // );
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
      child: mainApp(),
    );
  }

  Widget mainApp() {
    return MaterialApp(
      builder: Authenticator.builder(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: FutureBuilder(
          future: _isOnboardingCompleted(),
          builder: (context, snapshot) {
            return snapshot.hasData && snapshot.data == true
                ? farmCard()
                : OnboardingPage();
          },
        ),
      ),
    );
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

  // ignore: long-method
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
                    height: 700,
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                    margin: const EdgeInsets.only(top: 70),
                    child: Column(
                      children: [
                        SignInForm(includeDefaultSocialProviders: true),
                        // ElevatedButton(
                        //   child: Text("Test login"),
                        //   onPressed: () => Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //       builder: (context) => getGoogleWebView(),
                        //     ),
                        //   ),
                        // ),
                        const Divider(
                          color: Colors.black,
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0),
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
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Center(
                    child: FlutterLogo(
                      size: 100,
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

  _isOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool('onboarding') ?? false;
  }

  _googleWebViewController(uri) {
    print("[GoogleWebView] $uri");

    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("random")
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onWebResourceError: (error) => print(
            "[WebError] ${error.errorCode} :${error.description}, ${error.errorType}"),
        onNavigationRequest: (request) async {
          Map query = Uri.splitQueryString(request.url);
          print("[RequestWebView] ${query}");
          if (query.containsKey("karriot://?code")) {
            String code = query["karriot://?code"];
            CognitoUser user = await Auth().signInWithGoogle(code);
            if (user.username != null) {
              // ignore: use_build_context_synchronously
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FutureBuilder(
                    future: _isOnboardingCompleted(),
                    builder: (context, snapshot) {
                      return snapshot.hasData && snapshot.data == true
                          ? farmCard()
                          : OnboardingPage();
                    },
                  ),
                ),
              );
            }

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(uri);
  }

  Widget getGoogleWebView() {
    var url = Secret().getAuthUrl();
    print(url);

    return WebViewWidget(controller: _googleWebViewController(url));
  }

  Widget hostedUIWebView() {
    var loginUrl = Secret().loginUrl();
    print(loginUrl);
    WebViewController wv = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent("random")
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        // onProgress: ,
        onWebResourceError: (error) =>
            print("[WebHostError] ${error.errorCode}:${error.description}"),
        // onPageStarted: ,
        // onPageFinished: ,
        onNavigationRequest: (request) async {
          print("[HostUI] ${request.url}");
          Map query = Uri.splitQueryString(request.url);
          if (query.containsKey("karriot://?code")) {
            String code = query["karriot://?code"];
            // post to token endpoint method

            return NavigationDecision.prevent;
          }

          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(loginUrl);

    return WebViewWidget(
      controller: wv,
    );
  }
}
