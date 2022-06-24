import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:smart_iot_app/services/database_op.dart';

abstract class SmIOTDatabaseMethod{
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
  Future<String> sendReport(String? userId, Map<String, dynamic> reportMsg);
}

class DataPayload {
  late String userId;
  late String role;
  late bool approved;
  Map<String, dynamic>? userDevice;
  Map<dynamic, dynamic>? widgetList;
  late String encryption;

  DataPayload(
      {required this.userId,
        required this.role,
        required this.approved,
        this.userDevice,
        this.widgetList,
        required this.encryption});

  DataPayload.createEmpty() {
    userId = "";
    role = "Unknown";
    approved = false;
    userDevice = {};
    widgetList = {};
    encryption = "";
  }

  Map<String, dynamic>? loadUserDevices() {
    if (userDevice == null) {
      throw "[ERROR] Devices are not loaded. There were no devices";
    }

    return userDevice;
  }

  MapEntry<String, dynamic>? displayDevice(String deviceName) {
    final devices = loadUserDevices();
    final MapEntry<String, dynamic>? targetDevice;
    try {
      targetDevice =
          devices?.entries.firstWhere((element) => element.key == deviceName);
    } catch (e) {
      throw "[ERROR] Searched and found 0 device";
    }
    return targetDevice;
  }

  DataPayload encode(DataPayload payload, String encryption) {
    switch (encryption) {
      case "base64":
        payload.userId = base64.encode(utf8.encode(payload.userId));
        //print(payload.userId);

        payload.widgetList?.forEach(
              (key, value) {
            payload.widgetList?[key] = base64.encode(utf8.encode(value));
          },
        );

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
            if (payload.userDevice?[key]["userSensor"] != null) {
              Map? sensorList =
              payload.userDevice?[key]["userSensor"]["sensorName"];
              for (int i = 0; i < sensorList!.length; i++) {
                for (dynamic name in payload
                    .userDevice?[key]["userSensor"]["sensorValue"]
                [sensorList[i.toString()]]
                    .keys) {
                  for (dynamic att in payload
                      .userDevice?[key]["userSensor"]["sensorValue"]
                  [sensorList[i.toString()]][name]
                      .keys) {
                    payload.userDevice?[key]["userSensor"]["sensorValue"]
                    [sensorList[i.toString()]][name][att] =
                        utf8.decode(base64.decode(payload.userDevice?[key]
                        ["userSensor"]["sensorValue"]
                        [sensorList[i.toString()]][name][att]));
                  }
                }
              }
            }
            if (payload.userDevice?[key]["actuator"] != null) {
              Map? actuatorValue =
              payload.userDevice?[key]["actuator"]["value"];
              for (dynamic i in actuatorValue!.keys) {
                actuatorValue[i] = utf8.decode(base64.decode(actuatorValue[i]));
              }
            }
          },
        );

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
    'userId': userId,
    'role': role,
    'approved': approved,
    'userDevice': userDevice,
    'widgetList': widgetList,
    'encryption': encryption,
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

  DeviceBlock(this.userSensor, this.actuator);

  DeviceBlock.createEncryptedModel(SensorDataBlock us, ActuatorDataBlock act) {
    print("\n..Filling sensor and actuator into block..\n");
    userSensor = SensorDataBlock.createEncryptedModel(us);
    actuator = ActuatorDataBlock.createEncryptedModel(act);
    print(
        "[Process{DeviceModel}] \tCreated device block with size ${this.toJson().length} B");
  }

  Map<String, dynamic> toJson() =>
      {'userSensor': userSensor?.toJson(), 'actuator': actuator?.toJson()};
}

class SensorDataBlock {
  dynamic sensorName;
  Map<String, String>? sensorType;
  Map<String, bool>? sensorStatus;
  Map<String, dynamic>? sensorValue;
  Map<String, dynamic>? sensorThresh;
  Map<String, dynamic>? sensorTiming;
  Map<String, dynamic>? calibrateValue;

  SensorDataBlock(this.sensorName, this.sensorType, this.sensorStatus,
      this.sensorValue, this.sensorThresh, this.sensorTiming, this.calibrateValue);

  SensorDataBlock.createEncryptedModel(SensorDataBlock? sensor) {
    sensorName = sensor?.sensorName;
    sensorType = sensor?.sensorType;
    sensorStatus = sensor?.sensorStatus;
    sensorValue = sensor?.sensorValue;
    sensorThresh = sensor?.sensorThresh;
    sensorTiming = sensor?.sensorTiming;
    calibrateValue = sensor?.calibrateValue;

    for (int i = 0; i < sensorName?.length; i++) {
      for (dynamic name in sensorValue![sensorName[i.toString()]].keys) {
        for (dynamic att in sensorValue![sensorName[i.toString()]][name].keys) {
          sensorValue![sensorName[i.toString()]][name][att] = base64.encode(
              utf8.encode(sensorValue![sensorName[i.toString()]][name][att]
                  .toString()));
        }
      }
    }
    SensorDataBlock(sensorName, sensorType, sensorStatus, sensorValue,
        sensorThresh, sensorTiming, calibrateValue);
    print(
        "[Process{SensorModel}] \tCreated sensor block with size ${this.toJson().length} B");
  }

  Map<String, dynamic> toJson() => {
    'sensorName': sensorName,
    'sensorType': sensorType,
    'sensorStatus': sensorStatus,
    'sensorValue': sensorValue,
    'sensorThresh': sensorThresh,
    'sensorTiming': sensorTiming,
    'calibrateValue':calibrateValue
  };
}

class ActuatorDataBlock {
  Map<String, String>? actuatorId;
  Map<String, String>? type;
  Map<String, dynamic>? state;
  Map<String, dynamic>? value;

  ActuatorDataBlock(this.actuatorId, this.type, this.state, this.value);

  ActuatorDataBlock.createEncryptedModel(ActuatorDataBlock? act) {
    actuatorId = act?.actuatorId;
    type = act?.type;
    state = act?.state;
    value = act?.value;

    for (dynamic type in value!.keys) {
      value![type.toString()] =
          base64.encode(utf8.encode(value![type.toString()].toString()));
    }

    ActuatorDataBlock(actuatorId, type, state, value);
    print(
        "[Process{ActuatorModel}] \tCreated actuator block with size ${this.toJson().length} B");
  }

  Map<String, dynamic> toJson() =>
      {'actuatorId': actuatorId, 'type': type, 'state': state, 'value': value};
}