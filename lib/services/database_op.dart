import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

abstract class SmIOTDatabaseMethod{
  Future<void> addUser(String? userId);
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
}

class DataPayload {
  String user;
  Map<dynamic, dynamic>? sensorValMap;

  DataPayload({required this.user, required this.sensorValMap});

  //Method to create data model from json
  factory DataPayload.fromJson(Map<dynamic, dynamic> json) {
    return DataPayload(user: json['user'], sensorValMap: json['sensors']);
  }

  Map<String, dynamic> toJson() => {
    'user': user,
    'sensors': sensorValMap
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
      final Map? sensorsVals = event.snapshot.value as Map?;
      DataPayload data = DataPayload(user: userId, sensorValMap: sensorsVals);
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