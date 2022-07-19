// Use for initialize page aka setup for firebase



import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/root.dart';



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
  runApp(ChangeNotifierProvider(
      create: (context) => Mytheme(),
      child: SmartIOTApp(),
  ));
}



class SmartIOTApp extends StatelessWidget{
  const SmartIOTApp({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context)  {

    return MaterialApp(
          title: 'Smart IOT',
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light().copyWith(
            scaffoldBackgroundColor: Colors.white,
            colorScheme: ColorScheme.light(),
            dividerColor: Colors.black,

          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.grey.shade900,
            colorScheme: ColorScheme.dark(),
            dividerColor: Colors.white,
          ),
          themeMode: context.watch<Mytheme>().currentTheme(),
          home: RootPage(auth: Auth()),
    );
  }
}

