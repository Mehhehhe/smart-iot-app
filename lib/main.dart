// Use for initialize page aka setup for firebase

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/root.dart';

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
      options: FirebaseOptions(
          apiKey: "AIzaSyCB3LceCnDLpShGwKRSZ9NhW2Kg9txwv5U",
          appId: "1:774636778498:android:cab8029c00fecc576f231b",
          messagingSenderId: "774636778498",
          projectId: "smartiotapp-8b124"
      ),
    );
  }
  runApp(new SmartIOTApp());
}

class SmartIOTApp extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart IOT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: new RootPage(auth: new Auth()),
    );
  }
}