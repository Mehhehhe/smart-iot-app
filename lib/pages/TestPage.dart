import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/dataManagement.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';

class TestPage extends StatefulWidget {
  TestPage({Key? key, required this.auth, required this.userId})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  @override
  State<StatefulWidget> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  late DataPayload dataPayload;
  MQTTClientWrapper newclient = MQTTClientWrapper();

  Future<Map<String, dynamic>> getFutureData() async {
    SmIOTDatabase db = SmIOTDatabase();
    Future<Map<String, dynamic>> dataF = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataF;
    return msg;
  }

  Future<DataPayload> testAlbumSend(DataPayload data) async {
    final http.Response response = await http.post(
      Uri.parse('http://192.168.1.56:1880/userData'),
      headers: <String, String>{
        'Content-Type': "application/json; charset=UTF-8"
      },
      body: jsonEncode(data.toJsonForSending()),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      return DataPayload.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create data payload');
    }
  }

  Future<DataPayload> testFetchAlbum() async {
    final http.Response response = await http.get(
      Uri.parse('http://192.168.1.56:1880/userInfo'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("GET: ${json.decode(response.body)}");
      return DataPayload.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchDeviceMap(String mapID) async {
    print(mapID);
    http.Response response = await http.get(
      Uri.parse('http://192.168.1.56:1880/userInfo?deviceMap=$mapID'),
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      print("query GET: ${json.decode(response.body)}");
      response = await http.get(
        Uri.parse('http://192.168.1.56:1880/userInfo?sensorValsRequest=true'),
      );
      List<dynamic> senValues = json.decode(response.body);
      print("sensor query GET: ${senValues.length}");
      print("sensor test first 10 elements: ${senValues[1]}");
    } else {
      throw Exception('Failed to load data');
    }
  }

  void prepareMQTT() {
    newclient.prepareMqttClient();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: getFutureData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none &&
              snapshot.hasData == false) {
            return Container();
          } else if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.hasData == false) {
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
                            onPressed: () {
                              SensorDataBlock testSensorBlock = SensorDataBlock(
                                {"0": "sensor1"},
                                {"sensor1": "type1"},
                                {"sensor1": true},
                                {
                                  "sensor1": {
                                    "2022-06-23 18:15:00": {
                                      "flag": "flag{normal}",
                                      "message": "status{fine}",
                                      "value": "value{0.0}"
                                    },
                                  }
                                },
                                {"sensor1": "1.02"},
                              );

                              ActuatorDataBlock testActuator =
                                  ActuatorDataBlock(
                                {"0": "act1"},
                                {"act1": "type 1"},
                              );

                              DeviceBlock device1 =
                                  DeviceBlock.createEncryptedModel(
                                      testSensorBlock, testActuator);
                              DataPayload data = DataPayload(
                                userId: widget.userId,
                                role: "admin",
                                approved: true,
                                encryption: "base64",
                                userDevice: {"device1": device1.toJson()},
                              );

                              SmIOTDatabase db = SmIOTDatabase();
                              db.testSendData(widget.userId, data.toJson());
                            },
                            child: const Text("Set Payload Model to user")),
                        TextButton(
                          onPressed: () {
                            Map device = dataPayload.toJson();
                            Map<String, dynamic> data = <String, dynamic>{};
                            device.removeWhere(
                                (key, value) => key != "userDevice");
                            for (dynamic devices in device["userDevice"].keys) {
                              device["userDevice"]["$devices"]["userSensor"]
                                  .remove('sensorName');
                              device["userDevice"]["$devices"]["userSensor"]
                                  .remove('sensorType');
                              device["userDevice"]["$devices"]["userSensor"]
                                  .remove('sensorValue');

                              device["userDevice"]["$devices"]["actuator"]
                                  .remove('actuatorId');
                              device["userDevice"]["$devices"]["actuator"]
                                  .remove('type');
                              device["userDevice"]["$devices"]["actuator"]
                                  .remove('state');
                            }
                            device = device.transformAndLocalize();
                            data = Map<String, dynamic>.from(device);
                            SmIOTDatabase db = SmIOTDatabase();
                            db.sendData(widget.userId, data);
                            print("Send successfully!");
                          },
                          child: const Text("Test Send Values"),
                        ),
                        TextButton(
                            onPressed: () async {
                              SmIOTDatabase db = SmIOTDatabase();
                              final snapTest = await db.ref
                                  .child('${widget.userId}/userDevice/')
                                  .get();
                              print(snapTest.ref.path);
                            },
                            child: const Text("Check path")),
                        TextButton(
                            onPressed: () {
                              Map<dynamic, dynamic>? testMap;
                              Map testData = {
                                "userDevice": {
                                  "device1": {
                                    "userSensor": {
                                      "sensorStatus": {"sensor1": true},
                                      "sensorThresh": {"sensor1": 1.10}
                                    }
                                  }
                                }
                              };

                              try {
                                testData = testData.transformAndLocalize();
                                testMap = dataPayload
                                    .toJson()
                                    .localizedTrySetFromMap(testData);
                              } catch (e) {
                                print(e);
                              }
                              // Feedback response from localizing and set a value from another map
                              print(testMap);
                            },
                            child: Text("Test Try Set From Map")),
                        TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Manage_Page(
                                      userId: widget.userId,
                                      device: "device1",
                                      user: MQTTClientWrapper(),
                                    ),
                                  ));
                            },
                            child: Text("Navigate to manage")),
                        TextButton(
                          onPressed: () {
                            testAlbumSend(dataPayload);
                          },
                          child: Text("Test Send to Node-RED"),
                        ),
                        TextButton(
                          onPressed: () async {
                            DataPayload dataGET = await testFetchAlbum();
                            try {
                              fetchDeviceMap(dataGET.userDevice?.entries
                                  .elementAt(0)
                                  .value);
                            } catch (e) {
                              print(e);
                            }
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("GET completed"),
                                    content: Text(dataGET.toJson().toString()),
                                  );
                                });
                          },
                          child: Text("Test Get From Node-RED"),
                        ),
                        TextButton(
                          onPressed: () {
                            prepareMQTT();
                          },
                          child: Text("Prepare MQTT"),
                        )
                      ],
                    ),
                  );
                });
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
