import 'package:flutter/material.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/dataManagement.dart';

class TestPage extends StatefulWidget {

  TestPage({Key? key, required this.auth, required this.userId}) :super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage>{

  late DataPayload dataPayload;

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = SmIOTDatabase();
    Future<Map<String, dynamic>> dataF = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataF;
    return msg;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getFutureData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.none && snapshot.hasData == null){
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting && snapshot.hasData == null) {
            return CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            final Map? dataMapped = snapshot.data as Map?;
            dataPayload = DataPayload.fromJson(dataMapped ?? {});
            return ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Text(dataPayload.toJson().toString());
                }
            );
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }

}
