// ignore: file_names
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  // Map<String, dynamic>? account;
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Screen variables
  int index = 0;
  late List<Widget> _screen;
  // User variables
  Map<String, dynamic> account = {"name": "name", "email": "email"};
  late String accountName;
  late String accountEmail;
  late var ownedFarm;
  // Farm variables
  Map<String, dynamic> farm = {
    "farm": [
      {"ID": "id_placeholder", "FarmName": "Farm_name"}
    ]
  };
  int farmInd = 0;

  // AWS Interaction methods

  Future<void> signOutCurrentUser() async {
    try {
      await Amplify.Auth.signOut();
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  // Get user informations
  // username and id which came from UserPool in the authentication part
  // This section is separated from DynamoDB
  // Note: Username in both db must be the same.
  getUserInfo() async {
    var res = await Amplify.Auth.getCurrentUser();
    var userData = await getUserById(res.username);
    var userInf = {
      "name": res.username.toString(),
      "id": res.userId.toString(),
      "ownedFarm": userData["OwnedFarm"],
    };

    setState(() {
      account = userInf;
      ownedFarm = userInf["ownedFarm"];
    });
    return userInf;
  }

  // Fetch all farms and set to global var
  // Note: Must be used by admin or in debugging only.
  setAllFarmsListToGlobal() async {
    var farms = fetchFarmList();
    setState(() {
      farm = farms;
    });
  }

  @override
  void initState() {
    // Test if farm table is interable
    fetchFarmList();

    // Fetch user's name & email for drawer
    getUserInfo();
    // ignore: todo
    // TODO: fetch this user's farms and set to farm vars.
    // use getUserList() first to get all users.
    // select a user where name is matched then return id.
    // using this id in parameter of `get_farm_by_id`
    _screen = [const farmCard(), const Text("Second")];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
        style: const TextStyle(decoration: TextDecoration.none),
        child: Material(
          color: Colors.black,
          child: DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  actions: [
                    IconButton(
                        onPressed: () => signOutCurrentUser(),
                        icon: const Icon(Icons.logout))
                  ],
                  backgroundColor: Colors.amber,
                  elevation: 0,
                  title: const Text('Smart IOT App',
                      style: TextStyle(color: Colors.black)),
                  titleSpacing: 47,
                  leadingWidth: 80,
                  toolbarHeight: 80,
                ),
                body: _screen[index],
                bottomNavigationBar: NavigationBarTheme(
                  data: NavigationBarThemeData(
                      indicatorColor: Colors.white,
                      labelTextStyle: MaterialStateProperty.all(const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500))),
                  child: NavigationBar(
                    height: 60,
                    //               backgroundColor: Colors.amberAccent,
                    labelBehavior:
                        NavigationDestinationLabelBehavior.onlyShowSelected,
                    selectedIndex: index,
                    animationDuration: const Duration(milliseconds: 500),
                    onDestinationSelected: (index) =>
                        setState(() => this.index = index),
                    destinations: const [
                      NavigationDestination(
                          icon: Icon(Icons.home_outlined),
                          selectedIcon: Icon(Icons.home),
                          label: 'Home'),
                      NavigationDestination(
                          icon: Icon(Icons.history), label: 'History'),
                    ],
                  ),
                ),
                backgroundColor: Color.fromARGB(255, 79, 168, 108),
                drawer: Drawer(
                  elevation: 5.0,
                  child: Material(
                    child: Padding(
                      padding: const EdgeInsets.all(0),
                      child: ListView(
                        children: [
                          Builder(
                            builder: (context) {
                              accountEmail = account["id"];
                              accountName = account["name"];
                              return UserAccountsDrawerHeader(
                                accountName: Text(accountName,
                                    style:
                                        Theme.of(context).textTheme.headline5),
                                accountEmail: Text(
                                  accountEmail,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                decoration: BoxDecoration(color: Colors.green),
                              );
                            },
                          ),
                          // UserAccountsDrawerHeader(
                          //     accountName: Text(accountName ?? "Name",
                          //         style: Theme.of(context).textTheme.headline5),
                          //     accountEmail: Text(accountEmail ?? "Email",
                          //         style: Theme.of(context).textTheme.headline6)),
                          ListTile(
                            title: const Text("Profile",
                                style: TextStyle(fontSize: 22)),
                            isThreeLine: true,
                            subtitle: const Text("ดูหน้าโปรไฟล์และแก้ไขข้อมูล"),
                            hoverColor: Colors.white70,
                            onTap: () {},
                          ),

                          ListTile(
                            title: const Text(
                              "Setting",
                              style: TextStyle(fontSize: 22),
                            ),
                            isThreeLine: true,
                            subtitle: const Text("การตั้งค่าภายในแอพและอื่นๆ"),
                            hoverColor: Colors.white70,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ));
  }
}
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// import 'package:google_fonts/google_fonts.dart';

// import 'package:path_provider/path_provider.dart';

// import 'package:smart_iot_app/pages/ContactPage.dart';
// import 'package:smart_iot_app/pages/HistoryPage.dart';
// import 'package:smart_iot_app/pages/HomePage.dart';

// import 'package:smart_iot_app/pages/ProfilePage.dart';
// import 'package:smart_iot_app/pages/TestPage.dart';
// import 'package:smart_iot_app/services/MQTTClientHandler.dart';
// import 'dart:async';
// import 'package:smart_iot_app/services/authentication.dart';
// import 'package:smart_iot_app/services/notification.dart';

// import '../services/dataManagement.dart';
// import 'SettingPage.dart';

// import 'package:fpdart/fpdart.dart' as fp;

// class MainPage extends StatefulWidget {
//   const MainPage(
//       {Key? key,
//       required this.auth,
//       required this.logoutCallback,
//       required this.userId,
//       required this.user})
//       : super(key: key);

//   final BaseAuth auth;
//   final VoidCallback logoutCallback;
//   final String userId;
//   final MQTTClientWrapper user;

//   @override
//   State<StatefulWidget> createState() => _MainPageState();
// }

// class _MainPageState extends State<MainPage> {
//   static MQTTClientWrapper? cli;
//   late Timer timer;
//   static Stream<String>? syncDataResponse;
//   static String userId = "";
//   _MainPageState() {
//     timer = Timer.periodic(const Duration(seconds: 10), syncData);
//   }

//   // boolean for checking button in contact page
//   bool _hasBeenPressed1 = true;
//   bool _hasBeenPressed2 = true;
//   bool _hasBeenPressed3 = true;
//   bool _hasBeenPressed4 = true;
//   int check = 0;

//   // using for checking state when press submit
//   bool _isLoading;
//   bool _isFeedbackForm = true;

//   // using to check state and save value
//   final _formKey = GlobalKey<FormState>();

//   // data model for reporting
//   DataPayload dataModel;
//   String description;
//   // number to generate a card for each user's sensor
//   var _addCard = 0;
//   // Store boolean of sensor status state ("on"=true, "off"=false)
//   List<bool> switchToggles = <bool>[];

//   Map<String, dynamic> log = {};

//   NotifyUser notifyUser = NotifyUser();

//   signOut() async {
//     try {
//       await widget.auth.signOut();
//       widget.logoutCallback();
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   @override
//   void initState() {
//     if (kDebugMode) {
//       print("User Id: ${widget.userId}");
//     }
//     showEmail();
//     findDisplayName();

//     setState(() {
//       userId = widget.userId;
//       cli = widget.user;

//       screens = [
//         Home_Page(
//             user: cli!, userId: userId, liveData: const Stream<String>.empty()),
//         const History_Page(liveData: Stream<String>.empty())
//       ];
//     });
//     cli!.prepareMqttClient();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   String login = '....';

//   Future<void> showEmail() async {
//     String email = await widget.auth.getUserEmail();
//     setState(() {
//       login = email;
//     });
//   }

//   String displayName = '...';

//   Future<void> findDisplayName() async {
//     await widget.auth.getCurrentUser().then((value) {
//       setState(() {
//         displayName = value.displayName;
//       });
//     });
//   }

//   Future<Map<String, dynamic>> getFutureData() async {
//     SmIOTDatabase db = SmIOTDatabase();
//     Future<Map<String, dynamic>> dataFuture = db.getData(widget.userId);
//     Map<String, dynamic> msg = await dataFuture;
//     return msg;
//   }

//   void setCardCount(int num) => _addCard = num;

//   void setBoolSwitches(int num) {
//     if (switchToggles.isEmpty) {
//       switchToggles = List.filled(num, true);
//     }
//   }

//   void showTextDialog(String textToShow) {
//     showCupertinoDialog(
//       context: context,
//       builder: (context) {
//         return CupertinoAlertDialog(
//           title: Text(textToShow),
//         );
//       },
//       barrierDismissible: true,
//     );
//   }

//   bool validateAndSave() {
//     final form = _formKey.currentState;
//     if (form.validate()) {
//       form.save();
//       return true;
//     }
//     return false;
//   }

//   void syncData(Timer timer) async {
//     //print(cli.connectionState);
//     syncDataResponse = await cli.subscribeToResponse();
//     setState(() {
//       syncDataResponse.forEach((element) {
//         var sv = json.decode(element);
//         Map jsonSv = Map<String, dynamic>.from(sv);
//         jsonSv.map((key, value) {
//           key = DateTime.parse(key).toLocal();
//           value = Map<String, dynamic>.from(value);
//           // Set initial message (depend on flag value)
//           value["message"] = fp.Option.of(value)
//               .filter((t) => t["flag"] == "flag{normal}")
//               .andThen(() => fp.Option.of("This device is working normally."))
//               .getOrElse(() => "Something went wrong ...");
//           // Checking again if flag is not normal, do chain function
//           value["message"] =
//               value["message"] != "This device is working normally."
//                   ? value["flag"] == "flag{threshNotSet}"
//                       ? "Threshold is not set yet. Please set a threshold"
//                       : value["flag"] == "flag{warning}"
//                           ? "Warning. Device at risk."
//                           : "Error occured!"
//                   : value["message"];
//           if (value["flag"] != "flag{normal}") {
//             bool flagTypeCheck = value["flag"] == "flag{warning}";
//             notifyUser.initialize();
//             notifyUser.pushNotification(
//                 flagTypeCheck ? Importance.low : Importance.high,
//                 flagTypeCheck ? Priority.low : Priority.high,
//                 flagTypeCheck ? "Warning" : "Error/Unknown",
//                 value["message"]);
//           }
//           log.addAll(Map<String, dynamic>.from({key.toString(): value}));
//           writeHistory("${json.encode(Map<String, dynamic>.from({
//                 key.toString(): value
//               }))}\n");
//           return MapEntry(key, value);
//         });
//       });
//       //print("[TestList] ${syncDataResponse!.runtimeType}");
//       screens = [
//         Home_Page(user: cli, userId: userId, liveData: syncDataResponse!),
//         History_Page(
//           liveData: syncDataResponse,
//         )
//       ];
//     });
//   }

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     //print("path => $path");
//     return File("$path/history.txt");
//   }

//   Future<File> writeHistory(String content) async {
//     final file = await _localFile;
//     bool fileCheck = await file.exists();
//     //print("File exists? $fileCheck");
//     //print("Write $content, type: ${content.runtimeType}");

//     return file.writeAsString(content, mode: FileMode.append);
//   }

//   int index = 0;
//   late List<StatefulWidget> screens;

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//           //extendBodyBehindAppBar: true,
//           appBar: AppBar(
//             backgroundColor: Colors.amber,
//             elevation: 0,
//             title: Text(
//                 //displayName,
//                 'Smart IOT App',
//                 style: GoogleFonts.kanit(
//                   textStyle: Theme.of(context).textTheme.headline5,
//                 )),
//             titleSpacing: 47,
//             leadingWidth: 80,
//             toolbarHeight: 80,
//             leading: const Icon(
//               (Icons.logo_dev_sharp),
//               size: 80,
//             ),
//           ),
//           body: screens[index],
//           bottomNavigationBar: NavigationBarTheme(
//             data: NavigationBarThemeData(
//                 indicatorColor: Colors.white,
//                 labelTextStyle: MaterialStateProperty.all(const TextStyle(
//                     fontSize: 14, fontWeight: FontWeight.w500))),
//             child: NavigationBar(
//               height: 60,
//               backgroundColor: Colors.amberAccent,
//               labelBehavior:
//                   NavigationDestinationLabelBehavior.onlyShowSelected,
//               selectedIndex: index,
//               animationDuration: const Duration(milliseconds: 500),
//               onDestinationSelected: (index) =>
//                   setState(() => this.index = index),
//               destinations: [
//                 const NavigationDestination(
//                     icon: Icon(Icons.home_outlined),
//                     selectedIcon: Icon(Icons.home),
//                     label: 'Home'),
//                 const NavigationDestination(
//                     icon: Icon(Icons.history), label: 'History'),
//               ],
//             ),
//           ),
//           endDrawer: Drawer(
//             child: Material(
//               child: Padding(
//                 padding: const EdgeInsets.all(0),
//                 child: ListView(
//                   children: <Widget>[
//                     UserAccountsDrawerHeader(
//                         accountName: Text(
//                           "  $displayName",
//                           style: Theme.of(context).textTheme.headline5,
//                         ),
//                         accountEmail: Text(
//                           "  $login",
//                           style: Theme.of(context).textTheme.headline6,
//                         ),
//                         currentAccountPicture: GestureDetector(
//                           child: CircleAvatar(
//                             backgroundImage: NetworkImage(
//                                 "https://e7.pngegg.com/pngimages/507/702/png-clipart-profile-icon-simple-user-icon-icons-logos-emojis-users.png"),
//                           ),
//                         ),
//                         decoration: BoxDecoration(
//                             image: DecorationImage(
//                           fit: BoxFit.fill,
//                           image: NetworkImage(
//                               "https://wallpapercave.com/wp/wp4464900.png"),
//                         ))),
//                     ListTile(
//                       leading: const Icon(Icons.account_circle),
//                       title: const Text(
//                         'Profile',
//                       ),
//                       hoverColor: Colors.white70,
//                       onTap: () async {
//                         final value = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => Profile_Page(
//                                       auth: widget.auth,
//                                     )));
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(
//                         Icons.settings,
//                       ),
//                       title: const Text(
//                         'Setting',
//                       ),
//                       hoverColor: Colors.white70,
//                       onTap: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const Setting_Page()));
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(
//                         Icons.phone,
//                       ),
//                       title: const Text(
//                         'Contact',
//                       ),
//                       hoverColor: Colors.white70,
//                       onTap: () {
//                         Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => const Contact_page()));
//                       },
//                     ),
//                     ListTile(
//                       leading: const Icon(
//                         Icons.logout,
//                       ),
//                       title: const Text(
//                         'Signout',
//                       ),
//                       hoverColor: Colors.white70,
//                       onTap: signOut,
//                     ),
//                     ListTile(
//                       leading: const Icon(
//                         Icons.abc_sharp,
//                       ),
//                       title: const Text(
//                         'test backend',
//                       ),
//                       hoverColor: Colors.white70,
//                       onTap: () async {
//                         final value = await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => TestPage(
//                                   auth: widget.auth, userId: widget.userId)),
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ));
//   }
// }
