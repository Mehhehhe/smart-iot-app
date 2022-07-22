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
import 'package:smart_iot_app/services/database_op.dart';
import 'package:smart_iot_app/services/notification.dart';

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
          user: cli,
          userId: userId,
        ),
        const History_Page()
      ];
    });
    cli.prepareMqttClient();
    print("Prepare completed");
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
    print("[GET][FutureData] $userId");
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

  Future<void> validateAndSubmit() async {
    setState(() {
      _isLoading = true;
      _isFeedbackForm = true;
    });

    if (validateAndSave()) {
      SmIOTDatabase db = SmIOTDatabase();
      String category = "";
      if (_hasBeenPressed1) category = "Bug";
      if (_hasBeenPressed2) category = "Request";
      if (_hasBeenPressed3) category = "Suggestion";
      if (_hasBeenPressed4) category = "Others";

      final reportMsg = {
        "category": category,
        "description": description,
      };
      String? response = await db.sendReport(widget.userId, reportMsg);
      print(response);
    }
  }

  void syncData(Timer timer) async {
    print(cli.connectionState);
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
/*
  Widget _showForm() {
    return Form(
      child: Center(
        child: FutureBuilder(
          future: getFutureData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.none &&
                snapshot.hasData == null) {
              return Container();
            } else if (snapshot.connectionState == ConnectionState.waiting &&
                snapshot.hasData == null) {
              return const CircularProgressIndicator();
            } else if (snapshot.connectionState == ConnectionState.done) {
              final Map? dataMap = snapshot.data as Map?;
              if (kDebugMode) {
                print(dataMap.toString());
              }
              dataModel = DataPayload.fromJson(dataMap ?? {});
              setCardCount(dataModel.sensorList?.length);
              setBoolSwitches(dataModel.sensorList?.length);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _addCard,
                itemBuilder: (context, index) {
                  return cardPreset(index);
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }

  Widget cardPreset(int ind) {
    if (dataModel.sensorStatus![dataModel.sensorList[ind]] == "on") {
      switchToggles[ind] = true;
    } else {
      switchToggles[ind] = false;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shadowColor: Colors.black,
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Ink.image(
                image: const NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/6080/6080697.png'),
                height: 240,
                fit: BoxFit.contain,
                child: InkWell(
                  onTap: () {},
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
            child: Text(
                "${dataModel.sensorList![ind]} : ${dataModel.sensorValues![dataModel.sensorList[ind]].toString()}"),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 160),
                child: CupertinoSwitch(
                  activeColor: Colors.greenAccent,
                  value: switchToggles[ind],
                  onChanged: (val) {
                    setState(() {
                      switchToggles[ind] = val;
                      if (kDebugMode) {
                        print("$ind,${switchToggles[ind]}");
                      }

                      if (switchToggles[ind]) {
                        dataModel.sensorStatus![dataModel.sensorList[ind]] =
                            "on";
                      } else {
                        dataModel.sensorStatus![dataModel.sensorList[ind]] =
                            "off";
                      }
                      SmIOTDatabase db = SmIOTDatabase();
                      db.sendData(widget.userId, dataModel.sensorStatus);
                      if (kDebugMode) {
                        print("Sent data!");
                        print(
                            "${dataModel.sensorStatus} , ${dataModel.sensorList[ind]}");
                      }
                      showTextDialog(
                          "Set ${dataModel.sensorList[ind]} to ${dataModel.sensorStatus![dataModel.sensorList[ind]]}");
                    });
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Manage_Page(
                                  auth: widget.auth,
                                  device: "device1",
                                  userId: widget.userId,
                                  user: widget.user,
                                )));
                  },
                  child: const Text('Manage'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget contactAdmin() {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      width: 349,
      height: 600,
      child: ListView(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasBeenPressed1
                            ? [
                                const Color.fromRGBO(197, 132, 78, 1.0),
                                const Color.fromRGBO(225, 217, 57, 1.0),
                              ]
                            : [
                                const Color.fromRGBO(246, 138, 208, 1.0),
                                const Color.fromRGBO(189, 98, 199, 1.0),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasBeenPressed1 = !_hasBeenPressed1;
                      });
                    },
                    child: const Text(
                      'Bug',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto Slab",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 30),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasBeenPressed2
                            ? [
                                const Color.fromRGBO(197, 132, 78, 1.0),
                                const Color.fromRGBO(225, 217, 57, 1.0),
                              ]
                            : [
                                const Color.fromRGBO(246, 138, 208, 1.0),
                                const Color.fromRGBO(189, 98, 199, 1.0),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasBeenPressed2 = !_hasBeenPressed2;
                      });
                    },
                    child: const Text(
                      'Request',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto Slab",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 30, bottom: 70),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasBeenPressed3
                            ? [
                                const Color.fromRGBO(197, 132, 78, 1.0),
                                const Color.fromRGBO(225, 217, 57, 1.0),
                              ]
                            : [
                                const Color.fromRGBO(246, 138, 208, 1.0),
                                const Color.fromRGBO(189, 98, 199, 1.0),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasBeenPressed3 = !_hasBeenPressed3;
                      });
                    },
                    child: const Text(
                      'Suggestion',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto Slab",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 30, bottom: 70),
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _hasBeenPressed4
                            ? [
                                const Color.fromRGBO(197, 132, 78, 1.0),
                                const Color.fromRGBO(225, 217, 57, 1.0),
                              ]
                            : [
                                const Color.fromRGBO(246, 138, 208, 1.0),
                                const Color.fromRGBO(189, 98, 199, 1.0),
                              ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _hasBeenPressed4 = !_hasBeenPressed4;
                      });
                    },
                    child: const Text(
                      'Others',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto Slab",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            obscureText: false,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
              border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30)),
              labelText: 'Details',
            ),
            validator: (value) =>
                value!.isEmpty ? 'Please give us your feedback' : null,
            onSaved: (value) => description = value!.trim(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 100),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromRGBO(220, 41, 104, 1.0),
                          Color.fromRGBO(255, 118, 196, 1.0),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.all(
                        Radius.circular(25.0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.2),
                          spreadRadius: 4,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]),
                  child: OutlinedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        check =
                            _hasBeenPressed1 == false ? check + 1 : check + 0;
                        check =
                            _hasBeenPressed2 == false ? check + 1 : check + 0;
                        check =
                            _hasBeenPressed3 == false ? check + 1 : check + 0;
                        check =
                            _hasBeenPressed4 == false ? check + 1 : check + 0;
                        check == 1 ? contactMessage() : contactMessageError();
                        check = 0;
                        _hasBeenPressed1 = true;
                        _hasBeenPressed2 = true;
                        _hasBeenPressed3 = true;
                        _hasBeenPressed4 = true;
                      });
                    },
                    child: const Text(
                      'Submit',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: "Roboto Slab",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 0.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> contactMessage() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const ListTile(
                title: Center(child: Text('Rquest Sent')),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          validateAndSubmit();
                          Navigator.pop(context);
                        },
                        child: const Text('Close')),
                  ],
                )
              ],
            ));
  }

  Future<void> contactMessageError() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
              title: const ListTile(
                title: Center(child: Text('Prees select Only one per Submit')),
              ),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close')),
                  ],
                )
              ],
            ));
  }
*/
}
