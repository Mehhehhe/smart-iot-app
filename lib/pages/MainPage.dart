// ignore: file_names

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/farm_card_re_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card_view.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

import 'onboard.dart';

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
        //color: Colors.black,
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            floatingActionButton: Padding(
              padding: EdgeInsets.fromLTRB(50.0, 50.0, 0.0, 0.0),
              child: Container(
                height: 33,
                child: FloatingActionButton.extended(
                  backgroundColor: Colors.white,
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    builder: (context) => FarmEditor(farm: ownedFarm),
                  ).then((value) => onIndexSelection(value)),
                  label: const Text("Change Farm",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              iconTheme: IconThemeData(color: Colors.white),

              actions: [
                IconButton(
                    onPressed: () => setState(() {
                          context.read<FarmCardReBloc>().getDeviceData();
                        }),
                    icon: Icon(Icons.cached)),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => OnboardingPage()));
                    },
                    icon: Icon(Icons.question_mark)),
                IconButton(
                    onPressed: () => signOutCurrentUser(),
                    icon: Icon(Icons.logout)),
              ],
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: const Text(
                'Karriot',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 5,
                  shadows: <Shadow>[
                    Shadow(
                        offset: Offset(2.0, 2.0),
                        blurRadius: 5,
                        color: Colors.orange),
                  ],
                ),
              ),
              //titleSpacing: 47,
              //leadingWidth: 80,
              toolbarHeight: 70,
            ),
            body: Stack(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 340),
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
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
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
