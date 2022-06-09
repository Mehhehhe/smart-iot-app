import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  final scaffKey = GlobalKey<ScaffoldState>();

  //late Map<String, dynamic> dataTemp;

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
                    colors: [Colors.blue, Colors.pink],
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

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = new SmIOTDatabase();
    Future<Map<String, dynamic>> dataFuture = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataFuture;
    return msg;
  }

  /*Widget mainBody() {
    return FutureBuilder<String?>(
        future: getFutureData(),
        builder: (context, snapshot){
          if(snapshot.hasData){
            return Container(
              child: Text(snapshot.data.toString()),
            );
          }
          return CircularProgressIndicator();
        }

    );

  }*/


  Widget _showForm() {
    return Container(
      //padding: EdgeInsets.all(25.0),
      child: Form(
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              CardPreset(),
              CardPreset(),
              CardPreset(),
            ],
          ),
        ),
      ),
    );
  }

  Widget CardPreset() {
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
            child: FutureBuilder(

                future: getFutureData(),
                builder: (context, snapshot){

                  if (snapshot.connectionState == ConnectionState.none && snapshot.hasData == null) {
                    return Container();
                  }
                  print(snapshot.data);
                  final Map? dataMap = snapshot.data as Map?;
                  DataPayload dataModel =  DataPayload.fromJson(dataMap!);
                  //Map<String, dynamic> sensorsVals = dataTemp['sensors'];
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: dataModel.sensorValMap?.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Text(dataModel.sensorValMap?.keys.elementAt(index)+": "+dataModel.sensorValMap?.values.elementAt(index).toString()??""),
                          ],
                        );
                      }
                  );
                }
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {},
                child: Text('Manage'),
              ),
              TextButton(
                onPressed: () {},
                child: Text('delete'),
              ),
            ],
          )
        ],
      ),
    );
  }




}






