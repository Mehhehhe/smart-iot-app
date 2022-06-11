import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/database_op.dart';

class MainPage extends StatefulWidget{
  MainPage({Key? key, required this.auth, required this.logoutCallback, required this.userId}): super(key: key);

  final BaseAuth auth;
  final VoidCallback logoutCallback;
  final String userId;

  @override
  State<StatefulWidget> createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage>{

  bool value = true;

  final scaffKey = GlobalKey<ScaffoldState>();

  late DataPayload dataModel;
  var _addCard = 0;

  signOut() async {
    try{
      await widget.auth.signOut();
      widget.logoutCallback();
    }catch(e){
      print(e);
    }
  }


  @override
  void initState(){
    super.initState();
    print("User Id: "+widget.userId);
    showEmail();
  }

  String login = '....';
  Future<void> showEmail() async{
    String? email = await widget.auth.getUserEmail();
    setState(() {
      login = email!;
    });
  }

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = new SmIOTDatabase();
    Future<Map<String, dynamic>> dataFuture = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataFuture;
    return msg;
  }

  void setCardCount(int num) => _addCard = num;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        //backgroundColor: Color.fromRGBO(153, 252, 146, 1.0),
        appBar: AppBar(
          //backgroundColor: Color.fromRGBO(150, 150, 150, 1.0),
          //backgroundColor: Colors.orange,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      Color.fromRGBO(146, 222, 84, 1.0),
                      Color.fromRGBO(54, 174, 185, 1.0),
                    ],
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft
                )
            ),
          ),
          elevation: 10,
          title: Text("$login", style: TextStyle(
            fontSize: 15,
          ),),
          titleSpacing: 0,
          leading: GestureDetector(
            onTap: () {},
            child: Icon(
              Icons.account_circle,
            ),

          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home',),
              Tab(icon: Icon(Icons.phone_in_talk), text: 'Contact Admin',),
            ],
          ),

          actions: [
            IconButton(
              icon: Icon(Icons.logout), // The "-" icon
              onPressed: signOut, // The `_decrementCounter` function
            ),
          ],
        ),

        body: Container(
          decoration: BoxDecoration(
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
                    _showForm()
                  ],
                ),
              ),
              Center(
                child: Text(
                    'ไว้ทีหลัง'
                ),
              ),

            ],
          ),
        ),

      ),
    );
  }



  Widget _showForm() {
    return Container(
      //padding: EdgeInsets.all(25.0),
      child: Form(
        child: Center(
          child: FutureBuilder(
            future: getFutureData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.none && snapshot.hasData == null) {
                return Container();
              } else if(snapshot.connectionState == ConnectionState.waiting && snapshot.hasData == null) {
                return CircularProgressIndicator();
              } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData != null) {
                final Map? dataMap = snapshot.data as Map?;
                dataModel =  DataPayload.fromJson(dataMap??{});
                setCardCount(dataModel.sensorList?.length);
                print("Current card number: ${_addCard}");
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: _addCard,
                  itemBuilder: (context, index) {
                    return CardPreset(index);
                  },
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget CardPreset(int ind) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
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
                image: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/6080/6080697.png'),
                child: InkWell(
                  onTap: () {},
                ),
                height: 240,
                fit: BoxFit.contain,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
            child: Text("${dataModel.sensorList![ind]} : ${dataModel.sensorValues![dataModel.sensorList[ind]].toString()}"),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              Container( margin: EdgeInsets.only(right: 160),
                child: CupertinoSwitch(
                  activeColor: Colors.greenAccent,
                  value: value,
                  onChanged: (val){

                    setState((){
                      value = val;
                    });
                    if(value == true){
                      dataModel.sensorStatus![dataModel.sensorList[ind]]= "on";
                    } else {
                      dataModel.sensorStatus![dataModel.sensorList[ind]]= "off";
                    }
                    SmIOTDatabase db = new SmIOTDatabase();
                    db.sendData(widget.userId, dataModel.sensorStatus);
                    print("Sent data!");
                    value != value;
                  },
                ),
              ),
              Container(margin: EdgeInsets.only(right: 10),
                child: TextButton(
                  onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => const Manage_Page()));
                  },
                  child: Text('Manage'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}