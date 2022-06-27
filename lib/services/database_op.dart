import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';

abstract class SmIOTDatabaseMethod{
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
  Future<String> sendReport(String? userId, Map<String, dynamic> reportMsg);
}

class DataPayload {
  String user;
  final sensorList;
  Map<dynamic, dynamic>? sensorStatus;
  Map<dynamic, dynamic>? sensorValues;
  Map<dynamic, dynamic>? reportMsg;


  DataPayload({
    required this.user,
    required this.sensorList,
    required this.sensorStatus,
    required this.sensorValues,
    this.reportMsg
  });

  //Method to create data model from json
  factory DataPayload.fromJson(Map<dynamic, dynamic> json) {
    if (json["report_msg"] != null) {
      return DataPayload(
          user: json['user'],
          sensorValues: json['sensor_values'],
          sensorList: json['sensor_list'],
          sensorStatus: json['sensor_state'],
          reportMsg: json['report_msg']
      );
    }
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

  Map<String, dynamic> toJsonWithReportMsg() => {
    'user': user,
    'sensor_list':sensorList,
    'sensor_state':sensorStatus,
    'sensor_values': sensorValues,
    'report_msg':reportMsg
  };
}

class SmIOTDatabase implements SmIOTDatabaseMethod {
  // Temporary reference link to database
  final ref = FirebaseDatabase.instance.ref();

  @override
  Future<Map<String, dynamic>> getData(String userId) async {
    final snapshot = await ref.child(userId).get();
    final event = await ref.child(userId).once(DatabaseEventType.value);

    DataPayload data;

    if (snapshot.exists) {
      final Map? userSensorInfo = event.snapshot.value as Map?;
      print(userSensorInfo?.length);

      final sensorList = userSensorInfo?.entries.firstWhere((element) => element.key == "sensorList").value;
      final sensorState = userSensorInfo?.entries.firstWhere((element) => element.key == "sensorStatus").value;
      final sensorValues = userSensorInfo?.entries.firstWhere((element) => element.key == "sensorVals").value;
      
      if (userSensorInfo!.containsKey("reportMsg")) {
        final reportMsg = userSensorInfo.entries.firstWhere((element) => element.key == "reportMsg").value;
        data = DataPayload(
            user: userId,
            sensorList: sensorList,
            sensorStatus: sensorState,
            sensorValues: sensorValues,
            reportMsg: reportMsg
        );
      } else {
        data = DataPayload(
            user: userId,
            sensorList: sensorList,
            sensorStatus: sensorState,
            sensorValues: sensorValues
        );
      }

      final json = jsonEncode(data.toJson());

      print("Encoded in json [SIZE] ${json.length} B");

      Map<String, dynamic> jsonDe = jsonDecode(json);

      if(kDebugMode){
        print("dataPayload [SIZE]: ${data.toJson().length}");
      }

      return jsonDe;
    } else {
      if (kDebugMode) {
        print("Data not exists");
      }
      return {
        'user':userId,
        'sensor_list':{0:"Sensor not found"},
        'sensor_state': {"":""},
        'sensor_values': {"Sensor not found":"Contact admin"},
      };
    }
  }

  @override
  Future<void> sendData(String? userId, Map<dynamic, dynamic>? sensorStatus) async {
    await ref.child('$userId').update({
      "sensorStatus": sensorStatus
    });
  }

  @override
  Future<String> sendReport(String? userId, Map<String, dynamic> reportMsg) async {
    final reportStructure = {
      "category":reportMsg["category"],
      "description":reportMsg["description"],
      "submittedDate":DateTime.now().toString()
    };

    await ref.child('$userId').update({
      "reportMsg": reportStructure
    });

    return reportStructure.toString();
  }
}