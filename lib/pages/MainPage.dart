// ignore: file_names

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/farm_card_re_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card_view.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

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
    print("[AfterSelected] $farmInd");
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
            floatingActionButton: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 200.0, 0.0, 0.0),
              child: FloatingActionButton.extended(
                backgroundColor: Colors.white,
                onPressed: () => showModalBottomSheet(
                  context: context,
                  builder: (context) => FarmEditor(farm: ownedFarm),
                ).then((value) => onIndexSelection(value)),
                label: const Text("Change Farm",
                    style: TextStyle(color: Colors.black, fontSize: 16.0)),
                icon: const Icon(Icons.change_circle, color: Colors.black),
              ),
            ),
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            resizeToAvoidBottomInset: false,
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
              elevation: 5.0,
              title: const Text(
                'Karriot',
                style: TextStyle(color: Colors.black),
              ),
              titleSpacing: 47,
              leadingWidth: 80,
              toolbarHeight: 65,
            ),
            body: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(top: 200),
                child: Container(
                  decoration: const BoxDecoration(
                    //color: Colors.grey.shade200
                    image: DecorationImage(
                      //opacity: 100,
                      image: NetworkImage(
                        "https://t4.ftcdn.net/jpg/05/42/77/55/360_F_542775509_kukwGVyxAEiLtbWF54xIHtQzil8QAwLC.jpg",
                      ),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height,
                child: BlocConsumer<FarmCardReBloc, FarmCardReState>(
                  bloc: context.read<FarmCardReBloc>(),
                  listener: (context, state) {
                    if (state.farms.isNotEmpty) {
                      ownedFarm = state.farms;
                    }
                  },
                  builder: (context, state) {
                    return farmCardView(
                      username: accountName,
                      overrideFarmIndex: farmInd,
                      cli: widget.cli,
                    );
                  },
                ),
              ),
            ]),
            backgroundColor: Colors.grey.shade200,
          ),
        ),
      ),
    );
  }
}
