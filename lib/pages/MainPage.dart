import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_iot_app/pages/ContactPage.dart';
import 'package:smart_iot_app/pages/HistoryPage.dart';
import 'package:smart_iot_app/pages/HomePage.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'package:smart_iot_app/pages/ProfilePage.dart';
import 'package:smart_iot_app/pages/TestPage.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'dart:async';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/notification.dart';

import '../services/dataManagement.dart';
import 'SettingPage.dart';

class MainPage extends StatefulWidget {
  const MainPage(
      {Key? key,
      required this.auth,
      required this.logoutCallback,
      required this.userId,
      required this.user})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;
  final MQTTClientWrapper user;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  static late MQTTClientWrapper cli;
  Timer? timer;
  static Stream<String>? syncDataResponse;
  static String userId = "";
  _MainPageState() {
    //print("[MainPage] ${widget.user}");
    //cli = widget.user;
    //userId = widget.userId;
    timer = Timer.periodic(const Duration(seconds: 10), syncData);
    //syncDataResponse = const Stream<String>.empty();
    //print(syncDataResponse);
  }

  // boolean for checking button in contact page
  bool _hasBeenPressed1 = true;
  bool _hasBeenPressed2 = true;
  bool _hasBeenPressed3 = true;
  bool _hasBeenPressed4 = true;
  int check = 0;

  // using for checking state when press submit
  late bool _isLoading;
  bool _isFeedbackForm = true;

  // using to check state and save value
  final _formKey = GlobalKey<FormState>();

  // data model for reporting
  late DataPayload dataModel;
  late String description;
  // number to generate a card for each user's sensor
  var _addCard = 0;
  // Store boolean of sensor status state ("on"=true, "off"=false)
  late List<bool> switchToggles = <bool>[];

  signOut() async {
    try {
      await widget.auth.signOut();
      widget.logoutCallback();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    if (kDebugMode) {
      print("User Id: ${widget.userId}");
    }
    showEmail();
    findDisplayName();

    setState(() {
      userId = widget.userId;
      cli = widget.user;

      screens = [
        Home_Page(
            user: cli, userId: userId, liveData: const Stream<String>.empty()),
        const History_Page()
      ];
    });
    cli.prepareMqttClient();
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String login = '....';

  Future<void> showEmail() async {
    String? email = await widget.auth.getUserEmail();
    setState(() {
      login = email!;
    });
  }

  String displayName = '...';

  Future<void> findDisplayName() async {
    await widget.auth.getCurrentUser().then((value) {
      setState(() {
        displayName = value!.displayName!;
      });
    });
  }

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = SmIOTDatabase();
    Future<Map<String, dynamic>> dataFuture = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataFuture;
    return msg;
  }

  void setCardCount(int num) => _addCard = num;

  void setBoolSwitches(int num) {
    if (switchToggles.isEmpty) {
      switchToggles = List.filled(num, true);
    }
  }

  void showTextDialog(String textToShow) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(textToShow),
        );
      },
      barrierDismissible: true,
    );
  }

  bool validateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void syncData(Timer timer) async {
    //print(cli.connectionState);
    syncDataResponse = await cli.subscribeToResponse();
    setState(() {
      syncDataResponse!.forEach((element) {
        var sv = json.decode(element);
        Map jsonSv = Map<String, dynamic>.from(sv);
        jsonSv.map((key, value) {
          key = DateTime.parse(key);
          value = Map<String, dynamic>.from(value);
          if (value["flag"] != "flag{normal}") {
            NotifyUser notifyUser = NotifyUser();
            bool flagTypeCheck = value["flag"] == "flag{warning}";
            notifyUser.initialize();
            notifyUser.pushNotification(
                flagTypeCheck ? Importance.low : Importance.high,
                flagTypeCheck ? Priority.low : Priority.high,
                flagTypeCheck ? "Warning" : "Error/Unknown",
                value["message"]);
          }
          return MapEntry(key, value);
        });
      });
      screens = [
        Home_Page(user: cli, userId: userId, liveData: syncDataResponse!),
        const History_Page()
      ];
    });
  }

  int index = 0;
  late List<StatefulWidget> screens;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [
                Color.fromRGBO(78, 92, 252, 1.0),
                Color.fromRGBO(168, 30, 255, 1.0),
              ], begin: Alignment.bottomRight, end: Alignment.topLeft)),
            ),
            elevation: 10,
            title: Text(
              displayName,
              style: const TextStyle(
                fontSize: 15,
              ),
            ),
            titleSpacing: 0,
            leading: const Icon(
              (Icons.account_circle),
            ),
          ),
          body: screens[index],
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
                indicatorColor: Colors.blue.shade100,
                labelTextStyle: MaterialStateProperty.all(const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500))),
            child: NavigationBar(
              height: 60,
              backgroundColor: const Color(0xffe1e1e1),
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: index,
              animationDuration: const Duration(milliseconds: 500),
              onDestinationSelected: (index) =>
                  setState(() => this.index = index),
              destinations: [
                const NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: 'Home'),
                const NavigationDestination(
                    icon: Icon(Icons.history), label: 'History'),
              ],
            ),
          ),
          endDrawer: Drawer(
            child: Material(
              color: Colors.blue,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: ListView(
                  children: <Widget>[
                    const SizedBox(
                      height: 48,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.account_circle,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                      hoverColor: Colors.white70,
                      onTap: () async {
                        final value = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile_Page(
                                      auth: widget.auth,
                                    )));
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Setting',
                        style: TextStyle(color: Colors.white),
                      ),
                      hoverColor: Colors.white70,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Setting_Page()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Contact',
                        style: TextStyle(color: Colors.white),
                      ),
                      hoverColor: Colors.white70,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Contact_page()));
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    const Divider(
                      color: Colors.white70,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'Signout',
                        style: TextStyle(color: Colors.white),
                      ),
                      hoverColor: Colors.white70,
                      onTap: signOut,
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.abc_sharp,
                        color: Colors.white,
                      ),
                      title: const Text(
                        'test backend',
                        style: TextStyle(color: Colors.white),
                      ),
                      hoverColor: Colors.white70,
                      onTap: () async {
                        final value = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TestPage(
                                  auth: widget.auth, userId: widget.userId)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
