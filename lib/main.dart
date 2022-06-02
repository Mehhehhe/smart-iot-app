// Use for initialize page aka setup for firebase

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
          apiKey: "xxxx",
          appId: "xxxx",
          messagingSenderId: "xxxx",
          projectId: "xxxx"
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
      home: ,
    );
  }
}