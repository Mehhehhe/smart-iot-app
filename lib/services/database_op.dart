import 'package:firebase_database/firebase_database.dart';

abstract class SmIOTDatabaseMethod{
  Future<void> addUser(String? userId);
  Future<String?> getData(String? userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
}

class DataPayload {
  late final String user;
  late Map<String?, dynamic> sensorValMap = {};

  DataPayload({required this.user, required this.sensorValMap});

  //Method to create data model from json
  factory DataPayload.fromJson(Map<String, dynamic> json) {
    return DataPayload(user: json['user'], sensorValMap: json['sensors']);
  }
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
  Future<String?> getData(String? userId) async {
    final snapshot = await ref.child('$userId').get();
    if (snapshot.exists) {
      print(snapshot.value);
      return snapshot.value.toString();
    } else {
      print("Data not exists");
    }
  }

  @override
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus) async {
    await ref.child('$userId').update({
      "Sensor Status": sensorStatus
    });
  }

}