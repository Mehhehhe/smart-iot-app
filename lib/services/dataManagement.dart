import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';

extension MapTrySet<K,V> on Map<K,V>{

  Map transformAndLocalize([Map<dynamic, dynamic>? json,String nestedKey=""]){
    final Map<dynamic,dynamic> translations = {};
    if (json!=null){
      json.forEach((dynamic key, dynamic value) {
        if(value is Map){
          translations.addAll(transformAndLocalize(value, "$nestedKey$key."));
        } else {
          translations["$nestedKey${key.toString()}"] = value;
        }
      });
    } else {
      forEach((dynamic key, dynamic value) {
        if(value is Map){
          translations.addAll(transformAndLocalize(value, "$nestedKey$key."));
        } else {
          translations["$nestedKey${key.toString()}"] = value;
        }
      });
    }
    return translations;
  }

  // A function to set a value in a nested map
  // return a map that has localized path as a key and its value
  Map localizedTrySet( String target,[ V? valueToSet,Map<dynamic,dynamic>? json,String nestedKey='']){
    final Map<dynamic, dynamic> translations = {};
    if(json!=null){
      json.forEach((dynamic key, dynamic value) {
        if("$nestedKey$key"==target){
          json[key] = valueToSet;
          translations["$nestedKey$key"] = valueToSet;
        }
        if(value is Map){
          translations.addAll(localizedTrySet(target,valueToSet,value,"$nestedKey$key."));
        }
      });
    } else {
      forEach((dynamic key, dynamic value) {
        if("$nestedKey$key"==target){
          this[key] = valueToSet as V;
          translations["$nestedKey$key"] = valueToSet;
        }
        if(value is Map){
          translations.addAll(localizedTrySet(target, valueToSet,value, "$nestedKey$key."));
        }
      });
    }

    return translations;
  }

  Map localizedTrySetFromMap(Map<dynamic, dynamic> pathAndValueMap,[Map<dynamic, dynamic>? json, String prefix=""]){
    final Map<dynamic, dynamic> translations = {};
    if(json!=null){
      json.forEach((dynamic key, dynamic value) {
        print("In json: \t$key $prefix$key ${pathAndValueMap["$prefix$key"]}");
        if(pathAndValueMap.containsKey("$prefix$key") == true){
          print("Json with key: ${json[key]}");
          json[key] = pathAndValueMap["$prefix$key"];
          translations["$prefix$key"] = pathAndValueMap["$prefix$key"];
        }
        if(value is Map){
          translations.addAll(localizedTrySetFromMap(pathAndValueMap, value, "$prefix$key."));
        }
      });
    } else {
      forEach((dynamic key, dynamic value) {
        print("$key $prefix$key");
        if(pathAndValueMap.containsKey("$prefix$key") == true){
          print("This with key: ${this[key]}");
          this[key] = pathAndValueMap["$prefix$key"];
          translations["$prefix$key"] = pathAndValueMap["$prefix$key"];
        }
        if(value is Map){
          translations.addAll(localizedTrySetFromMap(pathAndValueMap, value, "$prefix$key."));
        }
      });
    }
    print("Return translation $translations");
    return translations;
  }
}

abstract class SmIOTDatabaseMethod{
  Future<Map<String, dynamic>> getData(String userId);
  Future<void> sendData(String? userId, Map<String, dynamic> sensorStatus);
  Future<void> testSendData(String? userId, Map<String, dynamic> data);
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

  DataPayload.createForSending(Map<String, dynamic> dev) {
    userDevice = dev;
  }

  Map<String, dynamic>? loadUserDevices() {
    if (userDevice == null) {
      throw "[ERROR] Devices are not loaded. There were no devices";
    }

    return userDevice;
  }

  MapEntry<String, dynamic> displayDevice(String deviceName) {
    final devices = loadUserDevices();
    final MapEntry<String, dynamic> targetDevice;
    try {
      targetDevice =
          devices!.entries.firstWhere((element) => element.key == deviceName);
    } catch (e) {
      throw "[ERROR] Searched and found 0 device";
    }
    return targetDevice;
  }

  List<dynamic> checkDeviceStatus(String deviceName){
    final Map<String, dynamic>? target = loadUserDevices();
    List<dynamic> whereErr = [];

    for(dynamic device in target!.keys){
      if(device == deviceName){
        for(dynamic part in target[device].keys){
          // actuator and userSensor
          for(dynamic att in target[device][part].keys){
            // attribute of actuator and userSensor
            if(att == "sensorStatus"){
              for(dynamic sensor in target[device][part][att].keys){
                if(target[device][part][att][sensor] == false){
                  whereErr.add(sensor);
                }
              }
            }
            if(att == "state"){
              for(dynamic act in target[device][part][att].keys){
                if(target[device][part][att][act] != "normal" || target[device][part][att][act] == false){
                  whereErr.add(act);
                }
              }
            }
          }
        }
      }
    }
    return whereErr;
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

  Map<String, dynamic> toJsonForSending() => {
    'userDevice' : userDevice
  };

  factory DataPayload.fromJson(Map<dynamic, dynamic> json) {
    final List<String> keyList = ["userId","role","approved","userDevice","widgetList","encryption"];
    int count = 0;
    for(String key in keyList){
      if(!json.containsKey(key)){
        if(key == "userId" || key == "role" || key == "encryption") {
          json[key] = "Unknown";
        } else if(key == "userDevice" || key == "widgetList") {
          json[key] = {};
        } else if(key == "approved"){
          json[key] = false;
        }
        count+=1;
      }
    }
    if(count == 6){
      count = 0;
      return DataPayload.createEmpty();
    }
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

  // Require user to manually encrypted data
  DeviceBlock.createPartialEncryptedModel(SensorDataBlock sen, ActuatorDataBlock act){
    userSensor = sen;
    actuator = act;
  }

  Map<String, dynamic> toJson() =>
      {'userSensor': userSensor?.toJson(), 'actuator': actuator?.toJson()};

  Map<String, dynamic> toJsonForSending() => {
    'userSensor':userSensor?.toJsonForSending(), 'actuator': actuator?.toJsonWithOnlyValue()
  };

  factory DeviceBlock.fromJson(Map<dynamic, dynamic> json) {
    return DeviceBlock(json["userSensor"], json["actuator"]);
  }
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

  // For using in report, not for sending data in normal process.
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

  SensorDataBlock.createForSending(this.sensorStatus, this.sensorTiming, this.calibrateValue, this.sensorThresh);
  Map<String, dynamic> toJson() => {
    'sensorName': sensorName,
    'sensorType': sensorType,
    'sensorStatus': sensorStatus,
    'sensorValue': sensorValue,
    'sensorThresh': sensorThresh,
    'sensorTiming': sensorTiming,
    'calibrateValue':calibrateValue
  };

  Map<String, dynamic> toJsonForSending() => {
    'sensorStatus': sensorStatus,
    'sensorThresh': sensorThresh,
    'sensorTiming': sensorTiming,
    'calibrateValue': calibrateValue
  };

  factory SensorDataBlock.fromJson(Map<dynamic, dynamic> json){
    return SensorDataBlock(
        json['sensorName'],
        json['sensorType'],
        json['sensorStatus'],
        json['sensorValue'],
        json['sensorThresh'],
        json['sensorTiming'],
        json['calibrateValue']
    );
  }
}

class ActuatorDataBlock {
  Map<String, String>? actuatorId;
  Map<String, String>? type;
  Map<String, dynamic>? state;
  Map<String, dynamic>? value;

  ActuatorDataBlock(this.actuatorId, this.type, this.state, this.value);

  ActuatorDataBlock.createForSending(this.value);

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

  ActuatorDataBlock.createEncryptedModelWithOnlyValue(ActuatorDataBlock? act){
    value = act?.value;
    for (dynamic type in value!.keys) {
      value![type.toString()] =
          base64.encode(utf8.encode(value![type.toString()].toString()));
    }
  }

  Map<String, dynamic> toJson() =>
      {'actuatorId': actuatorId, 'type': type, 'state': state, 'value': value};

  Map<String, dynamic> toJsonWithOnlyValue() => {'value':value};

  factory ActuatorDataBlock.fromJson(Map<dynamic, dynamic> json) {
    return ActuatorDataBlock(json["actuatorId"],json["type"],json["state"],json["value"]);
  }
}

class SmIOTDatabase implements SmIOTDatabaseMethod {
  final ref = FirebaseDatabase.instance.ref();

  @override
  Future<Map<String, dynamic>> getData(String userId) async {
    final snapshot = await ref.child(userId).get();
    final event = await ref.child(userId).once(DatabaseEventType.value);
    // create empty model of DataPayload;
    DataPayload data = DataPayload.createEmpty();
    if (snapshot.exists) {
      final Map? userInfo = event.snapshot.value as Map?;
      // get user's data from snapshot
      final role = userInfo?.entries.firstWhere((element) => element.key == "role").value;
      final approved = userInfo?.entries.firstWhere((element) => element.key == "approved").value;
      var userDevices = userInfo?.entries.firstWhere((element) => element.key == "userDevice").value;
      var widgetList = userInfo?.entries.firstWhere((element) => element.key == "widgetList").value;
      final encryption  = userInfo?.entries.firstWhere((element) => element.key == "encryption").value;
      userDevices = Map<String, dynamic>.from(userDevices);
      widgetList = Map<String,dynamic>.from(widgetList);
      // assign value to empty model;
      data = DataPayload(
          userId: userId,
          role: role,
          approved: approved,
          encryption: encryption,
          userDevice: userDevices,
          widgetList: widgetList
      );
      final jsons = jsonEncode(data.toJson());
      Map<String, dynamic> jsonDecoded = jsonDecode(jsons);
      return jsonDecoded;
    } else {
      data = DataPayload.createEmpty();
      return data.toJson();
    }
  }

  @override
  Future<void> sendData(String? userId, Map<String, dynamic> data) async {

    TransactionResult result = await ref.child('$userId').runTransaction(
            (Object? object) {
          if(object == null){
            return Transaction.abort();
          }
          Map<String, dynamic> _obj = Map<String, dynamic>.from(object as Map);
          print("Data : $data");
          _obj.localizedTrySetFromMap(data);
          //print("Sent! $_obj");
          return Transaction.success(_obj);
        }, applyLocally: true
    );
  }

  @override
  Future<void> testSendData(String? userId, Map<String, dynamic> data) async {
    await ref.child('$userId').update(data);

  }
}