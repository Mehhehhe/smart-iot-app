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

  late Map<String, dynamic> dataTemp;
  late Map<String, dynamic> sensorsVals;

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(153, 252, 146, 1.0),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text('1111'),
            ),
            ListTile(
              title: const Text('1'),
              onTap: (){},
            ),
            ListTile(
              title: const Text('Log out'),
              onTap: signOut,
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(150, 150, 150, 1.0),
        leading: GestureDetector(
          onTap: () {},
          child: Icon(
            Icons.account_circle,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
        onPressed: () {},
      ),
      body: Stack(
        children: [
          _showForm(),
        ],
      ),

    );
  }

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = new SmIOTDatabase();
    Future<Map<String, dynamic>> dataFuture = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataFuture;
    dataTemp = msg;
    sensorsVals = dataTemp["sensors"];
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

                  return ListView.builder(
                     shrinkWrap: true,
                      itemCount: sensorsVals.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Text(sensorsVals.keys.elementAt(index)+": "+sensorsVals.values.elementAt(index).toString()??""),
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