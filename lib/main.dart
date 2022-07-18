// Use for initialize page aka setup for firebase

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/root.dart';

import 'Theme/ThemeManager.dart';


void main() async {
  // Check if app open properly
  WidgetsFlutterBinding.ensureInitialized();
  try{
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
          projectId: "smartiotapp-8b124"
      ),
    );
  }
  runApp(const SmartIOTApp());
}

bool themeState = false ;

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

class SmartIOTApp extends StatelessWidget{
  const SmartIOTApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context)  {

    return Consumer<ThemeNotifier>(
      builder: (context, theme, _) => MaterialApp(
          title: 'Smart IOT',
          debugShowCheckedModeBanner: false,
      theme: theme.getTheme(),
          //theme: themeState ? DarkTheme: lightTheme,
          home: RootPage(auth: Auth()),
    );
  }
}

