// ignore: file_names
import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/farm_card_re_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/search_widget_bloc.dart';
// import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
// import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/screen_index_change_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card_view.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/model/SearchResult.dart';
import 'package:smart_iot_app/pages/Login.dart';
import 'package:smart_iot_app/pages/settings.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

import '../features/widget_to_display_on_mainpage/view/history_log.dart';

class MainPage extends StatefulWidget {
  MQTTClientWrapper cli;
  MainPage(this.cli, {Key? key}) : super(key: key);
  // Map<String, dynamic>? account;
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Screen variables
  int index = 0;
  // User variables
  Map<String, dynamic> account = {"name": "name", "email": "email"};
  String accountName = "";
  late String accountEmail;
  var ownedFarm = [];
  // Farm variables
  Map<String, dynamic> farm = {
    "farm": [
      {
        "ID": "id_placeholder",
        "FarmName": "Farm_name",
      },
    ],
  };
  int farmInd = 0;

  // AWS Interaction methods

  Future<void> signOutCurrentUser() async {
    try {
      await Amplify.Auth.signOut(
        options: const SignOutOptions(
          globalSignOut: false,
        ),
      );

      // ignore: use_build_context_synchronously
      // Navigator.pushNamed(context, 'logout');
    } on AuthException catch (e) {
      print(e.message);
    }
  }

  // Fetch all farms and set to global var
  // Note: Must be used by admin or in debugging only.
  setAllFarmsListToGlobal() async {
    var farms = fetchFarmList();
    setState(() {
      farm = farms;
    });
  }

  onIndexSelection(int value) {
    setState(() {
      farmInd = value;
    });
  }

  @override
  void initState() {
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
                  icon: const Icon(
                    Icons.logout,
                  ),
                ),
              ],
              backgroundColor: Colors.amber,
              elevation: 0,
              title: const Text(
                'Karriot',
                style: TextStyle(color: Colors.black),
              ),
              titleSpacing: 47,
              leadingWidth: 80,
              toolbarHeight: 80,
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.greenAccent,
                    Colors.greenAccent,
                    Colors.white,
                    // Colors.white,
                    // Colors.white,
                  ],
                ),
              ),
              child: BlocConsumer<FarmCardReBloc, FarmCardReState>(
                bloc: context.read<FarmCardReBloc>(),
                listener: (context, state) {},
                builder: (context, state) {
                  return farmCardView(
                    username: accountName,
                    overrideFarmIndex:
                        state.farmIndex == farmInd ? state.farmIndex : farmInd,
                    cli: widget.cli,
                  );
                },
              ),
            ),
            backgroundColor: Colors.transparent,
            // drawer: Drawer(
            //   elevation: 5.0,
            //   child: Material(
            //     child: Padding(
            //       padding: const EdgeInsets.all(0),
            //       child: ListView(
            //         children: [
            //           Builder(
            //             builder: (context) {
            //               accountEmail = account["id"];
            //               accountName = account["name"];

            //               return UserAccountsDrawerHeader(
            //                 accountName: Text(
            //                   accountName,
            //                   style: Theme.of(context).textTheme.headlineSmall,
            //                 ),
            //                 accountEmail: Text(
            //                   accountEmail,
            //                   style: const TextStyle(
            //                     color: Colors.black,
            //                     fontWeight: FontWeight.bold,
            //                   ),
            //                 ),
            //                 decoration: const BoxDecoration(
            //                   color: Colors.green,
            //                 ),
            //               );
            //             },
            //           ),
            //           // UserAccountsDrawerHeader(
            //           //     accountName: Text(accountName ?? "Name",
            //           //         style: Theme.of(context).textTheme.headline5),
            //           //     accountEmail: Text(accountEmail ?? "Email",
            //           //         style: Theme.of(context).textTheme.headline6)),
            //           ListTile(
            //             title: const Text(
            //               "เปลี่ยนฟาร์ม",
            //               style: TextStyle(fontSize: 22),
            //             ),
            //             isThreeLine: true,
            //             hoverColor: Colors.white70,
            //             subtitle: const Text(""),
            //             onTap: () async {
            //               // _displayFarmEditor(context, data);
            //               await Navigator.push(
            //                 context,
            //                 MaterialPageRoute(
            //                   builder: (context) => FarmEditor(farm: ownedFarm),
            //                 ),
            //               ).then((value) {
            //                 onIndexSelection(value);
            //                 context
            //                     .read<FarmCardReBloc>()
            //                     .chooseIndex(index, ownedFarm);
            //               });
            //             },
            //             onLongPress: () => const Dialog(
            //               child: Text(
            //                 "เลือกฟาร์มของคุณ กด 1 ครั้งเพื่อนำทางไปยังหน้าต่างเลือกฟาร์ม โดยจะแสดงผลเป็นรายชื่อฟาร์มทั้งหมด",
            //               ),
            //             ),
            //           ),

            //           ListTile(
            //             title: const Text(
            //               "Profile",
            //               style: TextStyle(fontSize: 22),
            //             ),
            //             isThreeLine: true,
            //             subtitle: const Text("ดูหน้าโปรไฟล์และแก้ไขข้อมูล"),
            //             hoverColor: Colors.white70,
            //             onTap: () {},
            //           ),

            //           ListTile(
            //             title: const Text(
            //               "Setting",
            //               style: TextStyle(fontSize: 22),
            //             ),
            //             isThreeLine: true,
            //             subtitle: const Text("การตั้งค่าภายในแอพและอื่นๆ"),
            //             hoverColor: Colors.white70,
            //             onTap: () => Navigator.of(context).push(
            //               MaterialPageRoute(
            //                 builder: (context) => SettingPage(),
            //               ),
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ),
        ),
      ),
    );
  }
}
