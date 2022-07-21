import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/dataManagement.dart';

class Home_Page extends StatefulWidget {
  Home_Page({Key? key, required this.user, required this.userId})
      : super(key: key);

  final Stream<String> user;
  final String userId;

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  late Stream<String> cli;
  // data model for reporting
  late DataPayload dataModel;
  late String description;
  // number to generate a card for each user's sensor
  var _addCard = 0;
  // Store boolean of sensor status state ("on"=true, "off"=false)
  late List<bool> switchToggles = <bool>[];

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

  @override
  void initState() {
    setState(() {
      cli = widget.user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
              decoration: BoxDecoration(
                  color: Color.fromARGB(50, 133, 133, 133),
                  borderRadius: BorderRadius.all(Radius.circular(22))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      margin: EdgeInsets.only(left: 15),
                      child: TextFormField(
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search device',
                          helperStyle: TextStyle(
                            color: Color.fromRGBO(241, 241, 241, 1.0),
                          ),
                          icon: Icon(Icons.search, color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.only(top: 60),
              child: GridView.extent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                children: [
                  _showForm(),
                  /*
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),
                  cardPreset(),*/
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
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
              setCardCount(dataModel.loadUserDevices()!.length);
              setBoolSwitches(dataModel.loadUserDevices()!.length);
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
        )),
      ),
    );
  }

  Widget cardPreset(int index) {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                    'https://static.onecms.io/wp-content/uploads/sites/20/2021/04/30/petlibro-automatic-cat-feeder-timed-tout.jpg'),
                height: 115,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {
                    // Go to manage page
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Manage_Page(
                            device: dataModel.userDevice!.keys.elementAt(index),
                            user: widget.user,
                            userId: widget.userId,
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child: Text('Cat feeding machine'),
              ),
            ],
          )
        ],
      ),
    );
  }
}
