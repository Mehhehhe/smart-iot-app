
import 'dart:convert';

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
  void initState(){
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getFutureData(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.none && snapshot.hasData == false){
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting && snapshot.hasData == false) {
            return CircularProgressIndicator();
          } else if (snapshot.connectionState == ConnectionState.done) {
            final Map? dataMapped = snapshot.data as Map?;
            dataPayload = DataPayload.fromJson(dataMapped ?? {});
            return ListView.builder(
                shrinkWrap: true,
                itemCount: 1,
                itemBuilder: (context, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Text(dataPayload.toJson().toString()),
                        TextButton(
                            onPressed: (){
                              SensorDataBlock testSensorBlock = SensorDataBlock({
                                "0": "sensor1"
                              }, {
                                "sensor1": "type1"
                              }, {
                                "sensor1": true
                              }, {
                                "sensor1": {
                                  "2022-06-23 18:15:00": {
                                    "flag": "flag{normal}",
                                    "message": "status{fine}",
                                    "value": "value{0.0}"
                                  },
                                }
                              }, {
                                "sensor1": "1.02"
                              }, {
                                "sensor1": "Auto"
                              },{
                                "sensor1": "0.0"
                              });

                              ActuatorDataBlock testActuator = ActuatorDataBlock(
                                  {"0": "act1"}, {"act1": "type 1"}, {"act1": "normal"}, {"act1": "90"});

                              DeviceBlock device1 =
                              DeviceBlock.createEncryptedModel(testSensorBlock, testActuator);
                              DataPayload data = DataPayload(
                                userId: widget.userId,
                                role: "admin",
                                approved: true,
                                encryption: "base64",
                                userDevice: {"device1": device1.toJson()},
                                widgetList: {"widget1": "widget1"},
                              );

                              SmIOTDatabase db = SmIOTDatabase();
                              db.testSendData(widget.userId, data.toJson());
                            },
                            child: const Text("Set Payload Model to user")
                        ),
                        TextButton(
                          onPressed: () {
                            var device = dataPayload.userDevice?.entries.firstWhere((element) => element.key=="device1").value;
                            Map<String, dynamic> data = <String,dynamic>{};

                            // Sensor Status
                            data["sensorStatus"] = device["userSensor"]["sensorStatus"];
                            // Sensor Thresh
                            data["sensorThresh"] = device["userSensor"]["sensorThresh"];
                            // Sensor Timing
                            data["sensorTiming"] = device["userSensor"]["sensorTiming"];
                            // Calibrate Value
                            data["calibrateValue"] = device["userSensor"]["calibrateValue"];
                            // Actuator Value
                            data["actuatorVal"] = device["actuator"]["value"];

                            data["sensorStatus"] = {"sensor1":true};
                            SmIOTDatabase db = SmIOTDatabase();
                            db.sendData(widget.userId, "device1", data);
                            print("Send successfully!");
                          },
                          child: const Text("Test Send Values"),
                        ),
                        TextButton(
                            onPressed: () async {
                              SmIOTDatabase db = SmIOTDatabase();
                              final snapTest = await db.ref.child('${widget.userId}/userDevice/').get();
                              print(snapTest.ref.path);
                            }, 
                            child: const Text("Check path")
                        )
                      ],
                    ),
                  );
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
