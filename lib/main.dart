import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/features/mainpage_widget_observer.dart';
import 'package:smart_iot_app/pages/Login.dart';

// AWS
import 'package:aws_lambda_dart_runtime/aws_lambda_dart_runtime.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:smart_iot_app/services/PostRequest.dart';

import 'Theme/ThemeManager.dart';

void main() async {
  // Check if app open properly
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MainPageWidgetObserver();
  // ignore: prefer_function_declarations_over_variables
  // Handler<AwsApiGatewayEvent> farmApiGateway = (context, event) async {
  //   final resp = {
  //     'message': 'Hello to ${context.requestId}',
  //     'host': '${event.headers.host}',
  //     'userAgent': '${event.headers.userAgent}',
  //   };
  //   final response = AwsApiGatewayResponse(
  //     body: json.encode(resp),
  //     isBase64Encoded: false,
  //     statusCode: HttpStatus.ok,
  //     headers: {
  //       "Content-Type": "application/json",
  //     },
  //   );
  //   return response;
  // };

  // Runtime()
  //   ..registerHandler<AwsApiGatewayEvent>("main.farm", farmApiGateway)
  //   ..registerHandler("main.postRequest", PostRequest().postApiGateway)
  //   ..invoke();

  // Initialize AWS
  // Remove this part.
/*
  try {
    // Check if firebase already running in app. Instance: DEFAULT
    Firebase.app('[DEFAULT]');
  } catch (e) {
    // If app just started...
    await Firebase.initializeApp(
      name: 'Smart IOT',
      options: const FirebaseOptions(
          apiKey: "AIzaSyCB3LceCnDLpShGwKRSZ9NhW2Kg9txwv5U",
          appId: "1:774636778498:android:cab8029c00fecc576f231b",
          messagingSenderId: "774636778498",
          projectId: "smartiotapp-8b124"),
    );
  }*/
  return runApp(ChangeNotifierProvider(
    create: (_) => ThemeNotifier(),
    child: SmartIOTApp(),
  ));
}

bool themeState = false;

ThemeData lightTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.light(),
  dividerColor: Colors.black,
);

ThemeData DarkTheme = ThemeData(
  scaffoldBackgroundColor: Colors.grey.shade900,
  colorScheme: ColorScheme.dark(),
  dividerColor: Colors.white,
);

class SmartIOTApp extends StatelessWidget {
  SmartIOTApp({Key? key}) : super(key: key);

  //MQTTClientWrapper userClient = MQTTClientWrapper();

  @override
  Widget build(BuildContext context) {
    //print(userClient);
    return Consumer<ThemeNotifier>(
        builder: (context, theme, _) => MaterialApp(
              title: 'Smart IOT',
              debugShowCheckedModeBanner: false,
              theme: theme.getTheme(),
              //theme: themeState ? DarkTheme: lightTheme,
              home:
                  LogIn() /*RootPage(auth: Auth(), client: MQTTClientWrapper())*/,
            ));
  }
}
