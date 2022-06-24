import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:smart_iot_app/services/database_op.dart';

abstract class SmIOTDatabaseMethod{
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
  Future<String> sendReport(String? userId, Map<String, dynamic> reportMsg);
}

class DataPayload{
  late String userId;
  late String role;
  late bool approved;
  Map<String, dynamic>? userDevice;
  Map<dynamic, dynamic>? widgetList;
  late String encryption;

  DataPayload({
    required this.userId,
    required this.role,
    required this.approved,
    this.userDevice,
    this.widgetList,
    required this.encryption
  });

  DataPayload.createEmpty(){
    userId = "";
    role = "Unknown";
    approved = false;
    userDevice = {};
    widgetList = {};
    encryption = "";
  }

  Map<String, dynamic>? loadUserDevices() {
    if (userDevice == null) throw "[ERROR] Devices are not loaded. There were no devices";
    return userDevice;
  }

  MapEntry<String, dynamic>? displayDevice (String deviceName) {
    final devices = loadUserDevices();
    final MapEntry<String, dynamic>? targetDevice;
    try{
      targetDevice = devices?.entries.firstWhere((element) => element.key == deviceName);
    } catch (e) {
      throw "[ERROR] Searched and found 0 device";
    }
    return targetDevice;
  }

  DataPayload encode(DataPayload payload, String encryption) {
    switch(encryption) {
      case "base64":
        payload.userId = base64.encode(utf8.encode(payload.userId));
        print(payload.userId);

        payload.widgetList?.forEach((key, value) {
          payload.widgetList?[key] = base64.encode(utf8.encode(value));
        },);

        break;
      default:
        throw "[ERROR] Encoding error. Not supported type";
    }
    return payload;
  }

  DataPayload decode(DataPayload payload) {
    switch (payload.encryption) {
      case "base64":
        payload.userId = utf8.decode(base64.decode(payload.userId));

        payload.userDevice?.forEach(
              (key, value) {
            if(payload.userDevice?[key]["userSensor"] != null){
              Map? sensorValue = payload.userDevice?[key]["userSensor"]["sensorValue"];
              for(dynamic i in sensorValue!.keys) {
                sensorValue[i] = utf8.decode(base64.decode(sensorValue[i]));
              }
            }
            if(payload.userDevice?[key]["actuator"] != null){
              Map? actuatorValue = payload.userDevice?[key]["actuator"]["value"];
              for(dynamic i in actuatorValue!.keys){
                actuatorValue[i] = utf8.decode(base64.decode(actuatorValue[i]));
              }
            }
          },);

        payload.widgetList?.forEach(
              (key, value) {
            payload.widgetList?[key] = utf8.decode(base64.decode(value));
          },
        );

        break;
      default:
        throw "[ERROR] Decoding error. Unable to decode or unsupported";
    }
    return payload;
  }

  Map<String, dynamic> toJson() => {
    'userId':userId,
    'role':role,
    'approved':approved,
    'userDevice':userDevice,
    'widgetList':widgetList,
    'encryption':encryption,
  };

  factory DataPayload.fromJson(Map<String, dynamic> json) {
    return DataPayload(
        userId: json['userId'],
        role: json['role'],
        approved: json['approved'],
        userDevice: json['userDevice'],
        widgetList: json['widgetList'],
        encryption: json['encryption']);
  }
}

class DeviceBlock {
  SensorDataBlock? userSensor;
  ActuatorDataBlock? actuator;

  DeviceBlock(
      this.userSensor,
      this.actuator
      );

  DeviceBlock.createEncryptedModel(SensorDataBlock us, ActuatorDataBlock act){
    userSensor = SensorDataBlock.createEncryptedModel(us);
    actuator = ActuatorDataBlock.createEncryptedModel(act);
  }

  Map<String, dynamic> toJson() => {
    'userSensor':userSensor?.toJson(),
    'actuator':actuator?.toJson()
  };
}

class SensorDataBlock {
  String? sensorName;
  String? sensorType;
  bool? sensorStatus;
  Map<dynamic, dynamic>? sensorValue;
  String? sensorThresh;
  String? sensorTiming;

  SensorDataBlock(this.sensorName, this.sensorType, this.sensorStatus, this.sensorValue, this.sensorThresh, this.sensorTiming);

  SensorDataBlock.createEncryptedModel(SensorDataBlock? sensor){
    sensorName = sensor?.sensorName;
    sensorType = sensor?.sensorType;
    sensorStatus = sensor?.sensorStatus;
    sensorValue = sensor?.sensorValue;
    sensorThresh = sensor?.sensorThresh;
    sensorTiming = sensor?.sensorTiming;

    for(dynamic type in sensorValue!.keys) {
      print("$type, ${type.runtimeType}");
      sensorValue![type.toString()] = base64.encode(utf8.encode(sensorValue![type.toString()].toString()));
    }
    SensorDataBlock(
        sensorName,
        sensorType,
        sensorStatus,
        sensorValue,
        sensorThresh,
        sensorTiming
    );
  }

  Map<String, dynamic> toJson() => {
    'sensorName':sensorName,
    'sensorType':sensorType,
    'sensorStatus': sensorStatus,
    'sensorValue': sensorValue,
    'sensorThresh': sensorThresh,
    'sensorTiming': sensorTiming
  };
}

class ActuatorDataBlock {
  Map<String, String>? actuatorId;
  Map<String, String>? type;
  Map<String, dynamic>? state;
  Map<String, dynamic>? value;

  ActuatorDataBlock(this.actuatorId, this.type, this.state, this.value);

  ActuatorDataBlock.createEncryptedModel(ActuatorDataBlock? act){
    actuatorId = act?.actuatorId;
    type = act?.type;
    state = act?.state;
    value = act?.value;

    for(dynamic type in value!.keys) {
      value![type.toString()] = base64.encode(utf8.encode(value![type.toString()].toString()));
    }

    ActuatorDataBlock(actuatorId, type, state, value);
  }

  Map<String, dynamic> toJson() => {
    'actuatorId':actuatorId,
    'type':type,
    'state':state,
    'value':value
  };

}
