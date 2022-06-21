import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'package:smart_iot_app/pages/ProfilePage.dart';
import 'dart:async';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/database_op.dart';

class MainPage extends StatefulWidget {
  const MainPage(
      {Key? key,
      required this.auth,
      required this.logoutCallback,
      required this.userId})
      : super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
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
    super.initState();
    if (kDebugMode) {
      print("User Id: ${widget.userId}");
    }
    showEmail();
    findDisplayName();
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
    if (form!.validate()){
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

    if (validateAndSave()){
      SmIOTDatabase db = SmIOTDatabase();
      String category = "";
      if (_hasBeenPressed1) category = "Bug";
      if (_hasBeenPressed2) category = "Request";
      if (_hasBeenPressed3) category = "Suggestion";
      if (_hasBeenPressed4) category = "Others";

      final reportMsg = {
        "category":category,
        "description":description,
      };
      String? response = await db.sendReport(widget.userId, reportMsg);
      print(response);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromRGBO(146, 222, 84, 1.0),
              Color.fromRGBO(54, 174, 185, 1.0),
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
          leading: GestureDetector(
            child: IconButton(
              icon: const Icon(Icons.account_circle), // The "-" icon
              onPressed: () async {
                final value = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Profile_Page(
                              auth: widget.auth,
                            )));
                findDisplayName();
              },
            ),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Icon(Icons.home),
                text: 'Home',
              ),
              Tab(
                icon: Icon(Icons.phone_in_talk),
                text: 'Contact Admin',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout), // The "-" icon
              onPressed: signOut, // The `_decrementCounter` function
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(12, 210, 193, 1.0),
                Color.fromRGBO(195, 255, 232, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: TabBarView(
            children: [
              Center(
                child: Stack(
                  children: [
                    _showForm(),
                  ],
                ),
              ),
              Center(
                child: Form(
                  key: _formKey,
                  child: contactAdmin(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                            builder: (context) => const Manage_Page()));
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
                padding: const EdgeInsets.only(left: 20,top: 30),
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
                padding: const EdgeInsets.only(top: 30,bottom: 70),
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
                padding: const EdgeInsets.only(left: 20,top: 30,bottom: 70),
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
                          offset: const Offset(0,3),
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
              fillColor: const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
              border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.transparent),
                  borderRadius: BorderRadius.circular(30)),
              labelText: 'Details',
            ),
            validator: (value) => value!.isEmpty ? 'Please give us your feedback' : null,
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
                        check = _hasBeenPressed1 == false ? check+1 : check+0;
                        check = _hasBeenPressed2 == false ? check+1 : check+0;
                        check = _hasBeenPressed3 == false ? check+1 : check+0;
                        check = _hasBeenPressed4 == false ? check+1 : check+0;
                        check == 1 ? contactMessage() : contactMessageError();
                        check=0;
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
                    onPressed: (){
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
}
