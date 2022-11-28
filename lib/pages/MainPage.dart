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
  String accountName = "";
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
      accountName = res.username.toString();
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
    _screen = [farmCard(username: accountName), const Text("Second")];
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
                // bottomNavigationBar: NavigationBarTheme(
                //   data: NavigationBarThemeData(
                //       indicatorColor: Colors.white,
                //       labelTextStyle: MaterialStateProperty.all(const TextStyle(
                //           fontSize: 14, fontWeight: FontWeight.w500))),
                //   child: NavigationBar(
                //     height: 60,
                //     //               backgroundColor: Colors.amberAccent,
                //     labelBehavior:
                //         NavigationDestinationLabelBehavior.onlyShowSelected,
                //     selectedIndex: index,
                //     animationDuration: const Duration(milliseconds: 500),
                //     onDestinationSelected: (index) =>
                //         setState(() => this.index = index),
                //     destinations: const [
                //       NavigationDestination(
                //           icon: Icon(Icons.home_outlined),
                //           selectedIcon: Icon(Icons.home),
                //           label: 'Home'),
                //       NavigationDestination(
                //           icon: Icon(Icons.history), label: 'History'),
                //     ],
                //   ),
                // ),
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
                            title: const Text(
                              "เปลี่ยนฟาร์ม",
                              style: TextStyle(fontSize: 22),
                            ),
                            isThreeLine: true,
                            hoverColor: Colors.white70,
                            onTap: () {},
                            onLongPress: () => const Dialog(
                                child: Text(
                                    "เลือกฟาร์มของคุณ กด 1 ครั้งเพื่อนำทางไปยังหน้าต่างเลือกฟาร์ม โดยจะแสดงผลเป็นรายชื่อฟาร์มทั้งหมด")),
                          ),

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
