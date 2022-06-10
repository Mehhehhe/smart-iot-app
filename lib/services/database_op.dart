import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

abstract class SmIOTDatabaseMethod{
  Future<void> addUser(String? userId);
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
}

class DataPayload {
  String user;
  final sensorList;
  Map<dynamic, dynamic>? sensorStatus;
  Map<dynamic, dynamic>? sensorValues;


  DataPayload({
    required this.user,
    required this.sensorList,
    required this.sensorStatus,
    required this.sensorValues,
  });

  //Method to create data model from json
  factory DataPayload.fromJson(Map<dynamic, dynamic> json) {
    return DataPayload(
        user: json['user'],
        sensorValues: json['sensor_values'],
        sensorList: json['sensor_list'],
        sensorStatus: json['sensor_state']
    );
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'sensor_list':sensorList,
    'sensor_state':sensorStatus,
    'sensor_values': sensorValues,
  };
}

class SmIOTDatabase implements SmIOTDatabaseMethod {
  // Temporary reference link to database
  final ref = FirebaseDatabase.instance.ref();

  @override
  Future<void> addUser(String? userId) async {
    await ref.child('$userId').set({
      "userId": userId
    });
  }

  @override
  Future<Map<String, dynamic>> getData(String userId) async {
    final snapshot = await ref.child('$userId').get();
    final event = await ref.child('$userId').once(DatabaseEventType.value);

    if (snapshot.exists) {
      final Map? userSensorInfo = event.snapshot.value as Map?;

      final sensorList = userSensorInfo?.values.elementAt(1);
      final sensorState = userSensorInfo?.values.elementAt(0);
      final sensorValues = userSensorInfo?.values.elementAt(2);

      DataPayload data = DataPayload(user: userId, sensorList: sensorList, sensorStatus: sensorState,sensorValues: sensorValues);
      final json = jsonEncode(data.toJson());
      Map<String, dynamic> jsonDe = jsonDecode(json);
      return jsonDe;
    } else {
      print("Data not exists");
    }
    return {};
  }

  @override
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus) async {
    await ref.child('$userId').update({
      "Sensor Status": sensorStatus
    });
  }

}