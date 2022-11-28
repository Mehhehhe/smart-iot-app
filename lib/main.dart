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
// import 'package:smart_iot_app/services/PostRequest.dart';

import 'Theme/ThemeManager.dart';

void main(List list) async {
  // Check if app open properly
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MainPageWidgetObserver();
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
