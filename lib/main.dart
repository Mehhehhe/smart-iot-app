// Use for initialize page aka setup for firebase

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
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
      options: const FirebaseOptions(
          apiKey: "AIzaSyCB3LceCnDLpShGwKRSZ9NhW2Kg9txwv5U",
          appId: "1:774636778498:android:cab8029c00fecc576f231b",
          messagingSenderId: "774636778498",
          projectId: "smartiotapp-8b124"
      ),
    );
  }
  runApp(const SmartIOTApp());
  runApp(ChangeNotifierProvider(
    create: (context) => Mytheme(),
    child: SmartIOTApp(),
  ));
}

class Mytheme with ChangeNotifier {
  bool _isDark = false ;

  ThemeMode currentTheme() {
    return _isDark ? ThemeMode.dark : ThemeMode.light ;
  }

  void switchTheme(){
    _isDark = !_isDark;
    notifyListeners();
  }
}
const primaryColor = Color(0xFF151026);

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

    return MaterialApp(

      theme: ThemeData.light().copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: Color.fromRGBO(255, 164, 60, 1.0),
          secondary: Color.fromRGBO(255, 177, 113,1),
        ),
        dividerColor: Colors.black,
        textTheme:
        TextTheme(
          headline1: TextStyle(color: Colors.black ,fontSize: 22, fontWeight: FontWeight.bold ),
          headline2: TextStyle(color: Colors.black,fontSize: 15),
          bodyText2: TextStyle(color: Colors.black),
          subtitle1: TextStyle(color: Colors.deepPurpleAccent),

        ),
        iconTheme: IconThemeData(color: Colors.black),
        //bottomNavigationBarTheme: Colors.black
        highlightColor: Colors.red,

        listTileTheme: ListTileThemeData(
          textColor: Colors.black,
        ),
appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(
            color: Colors.white,
          )
      ),

      ),


      darkTheme: ThemeData.dark().copyWith(

        scaffoldBackgroundColor: Colors.grey.shade900,
        colorScheme: ColorScheme.dark(
          primary: Color.fromRGBO(0, 0, 0, 1.0),
          secondary: Color.fromRGBO(51, 51, 51, 1.0),
        ),
        dividerColor: Colors.white,
          textTheme:
          TextTheme(
            headline1: TextStyle(color: Colors.white ,fontSize: 25, fontWeight: FontWeight.bold,fontFamily:'Kanit', ),
            headline2: TextStyle(color: Colors.white,fontSize: 15),
            bodyText2: TextStyle(color: Colors.white),
            subtitle1: TextStyle(color: Colors.deepPurpleAccent),

          ),
          iconTheme: IconThemeData(color: Colors.white),
        highlightColor: Colors.red,
        listTileTheme: ListTileThemeData(
          textColor: Colors.white,
        ),
        appBarTheme: AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.white,
            )
        ),



      ),

          title: 'Smart IOT',
          debugShowCheckedModeBanner: false,
      themeMode: context.watch<Mytheme>().currentTheme(),
      home: RootPage(auth: Auth(), client: MQTTClientWrapper()),
    );
  }
}

