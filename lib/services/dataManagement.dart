// import 'package:firebase_database/firebase_database.dart';
// import 'dart:convert';

// import 'package:fpdart/fpdart.dart';

// extension MapTrySet<K, V> on Map<K, V> {
//   Map transformAndLocalize(
//       [Map<dynamic, dynamic> json, String nestedKey = ""]) {
//     final Map<dynamic, dynamic> translations = {};
//     if (json != null) {
//       json.forEach((dynamic key, dynamic value) {
//         if (value is Map) {
//           translations.addAll(transformAndLocalize(value, "$nestedKey$key."));
//         } else {
//           translations["$nestedKey${key.toString()}"] = value;
//         }
//       });
//     } else {
//       forEach((dynamic key, dynamic value) {
//         if (value is Map) {
//           translations.addAll(transformAndLocalize(value, "$nestedKey$key."));
//         } else {
//           translations["$nestedKey${key.toString()}"] = value;
//         }
//       });
//     }
//     return translations;
//   }

//   // A function to set a value in a nested map
//   // return a map that has localized path as a key and its value
//   Map localizedTrySet(String target,
//       [V valueToSet, Map<dynamic, dynamic> json, String nestedKey = '']) {
//     final Map<dynamic, dynamic> translations = {};
//     if (json != null) {
//       json.forEach((dynamic key, dynamic value) {
//         if ("$nestedKey$key" == target) {
//           json[key] = valueToSet;
//           translations["$nestedKey$key"] = valueToSet;
//         }
//         if (value is Map) {
//           translations.addAll(
//               localizedTrySet(target, valueToSet, value, "$nestedKey$key."));
//         }
//       });
//     } else {
//       forEach((dynamic key, dynamic value) {
//         if ("$nestedKey$key" == target) {
//           this[key] = valueToSet as V;
//           translations["$nestedKey$key"] = valueToSet;
//         }
//         if (value is Map) {
//           translations.addAll(
//               localizedTrySet(target, valueToSet, value, "$nestedKey$key."));
//         }
//       });
//     }

//     return translations;
//   }

//   Map localizedTrySetFromMap(Map<dynamic, dynamic> pathAndValueMap,
//       [Map<dynamic, dynamic> json, String prefix = ""]) {
//     final Map<dynamic, dynamic> translations = {};
//     if (json != null) {
//       json.forEach((dynamic key, dynamic value) {
//         print("In json: \t$key $prefix$key ${pathAndValueMap["$prefix$key"]}");
//         if (pathAndValueMap.containsKey("$prefix$key") == true) {
//           print("Json with key: ${json[key]}");
//           json[key] = pathAndValueMap["$prefix$key"];
//           translations["$prefix$key"] = pathAndValueMap["$prefix$key"];
//         }
//         if (value is Map) {
//           translations.addAll(
//               localizedTrySetFromMap(pathAndValueMap, value, "$prefix$key."));
//         }
//       });
//     } else {
//       forEach((dynamic key, dynamic value) {
//         print("$key $prefix$key");
//         if (pathAndValueMap.containsKey("$prefix$key") == true) {
//           print("This with key: ${this[key]}");
//           this[key] = pathAndValueMap["$prefix$key"];
//           translations["$prefix$key"] = pathAndValueMap["$prefix$key"];
//         }
//         if (value is Map) {
//           translations.addAll(
//               localizedTrySetFromMap(pathAndValueMap, value, "$prefix$key."));
//         }
//       });
//     }
//     print("Return translation $translations");
//     return translations;
//   }
// }

// abstract class SmIOTDatabaseMethod {
//   Future<Map<String, dynamic>> getData(String userId);
//   Future<void> sendData(String userId, Map<String, dynamic> sensorStatus);
//   Future<void> testSendData(String userId, Map<String, dynamic> data);
// }

// class DataPayload {
//   String userId;
//   String role;
//   bool approved;
//   Map<String, dynamic> userDevice;
//   String encryption;

//   DataPayload(
//       {this.userId,
//       this.role,
//       this.approved,
//       this.userDevice,
//       this.encryption});

//   DataPayload.createEmpty() {
//     userId = "";
//     role = "Unknown";
//     approved = false;
//     userDevice = {};
//     encryption = "";
//   }

//   DataPayload.createForSending(Map<String, dynamic> dev) {
//     userDevice = dev;
//   }

//   Either<String, Map<String, dynamic>> loadDevices() {
//     return userDevice.isNotEmpty ? Right(userDevice) : const Left("No devices");
//   }

//   Option<Map<String, dynamic>> getDeviceInfo(String deviceName) {
//     final devices = loadDevices();
//     Option<Map<String, dynamic>> targetDevice;
//     devices.match((err) => IOEither.of(unit), (deviceMap) {
//       return IOEither.tryCatch(() {
//         targetDevice = devices.getRight();
//       }, (error, stackTrace) {
//         return 'An error occurred: $error';
//       });
//     });
//     return targetDevice;
//   }

//   // Reduction here!
//   // Must change to Node-RED
//   checkDeviceStatus(String deviceName, [Map source]) {
//     // Get MQTT client and subscribe to "flag_checker"
//     // require: accessId in localized map from Node-RED
//     // accessId := device.sensor_name
//     //
//     Option<Map> mapOpts = Option.of(source);
//     var filter = mapOpts.match((t) {
//       return t.filterWithKey((key, value) =>
//           key.toString().contains(deviceName).toString().endsWith("state"));
//     }, () => IOEither.of(unit));
//     return filter;
//   }

//   DataPayload decode(DataPayload payload) {
//     switch (payload.encryption) {
//       case "base64":
//         payload.userDevice?.forEach(
//           (key, value) {
//             if (payload.userDevice[key]["userSensor"] != null) {
//               List sensorList =
//                   payload.userDevice[key]["userSensor"]["sensorName"];
//               for (int i = 0; i < sensorList.length; i++) {
//                 for (dynamic name in payload
//                     .userDevice[key]["userSensor"]["sensorValue"][sensorList[i]]
//                     .keys) {
//                   for (dynamic att in payload
//                       .userDevice[key]["userSensor"]["sensorValue"]
//                           [sensorList[i]][name]
//                       .keys) {
//                     payload.userDevice[key]["userSensor"]["sensorValue"]
//                             [sensorList[i]][name][att] =
//                         utf8.decode(base64.decode(payload.userDevice[key]
//                                 ["userSensor"]["sensorValue"][sensorList[i]]
//                             [name][att]));
//                   }
//                 }
//               }
//             }
//             if (payload.userDevice[key]["actuator"] != null) {
//               Map actuatorValue = payload.userDevice[key]["actuator"]["value"];
//               for (dynamic i in actuatorValue.keys) {
//                 actuatorValue[i] = utf8.decode(base64.decode(actuatorValue[i]));
//               }
//             }
//           },
//         );
//         break;
//       default:
//         throw "[ERROR] Decoding error. Unable to decode or unsupported";
//     }
//     return payload;
//   }

//   Map<String, dynamic> toJson() => {
//         'userId': userId,
//         'role': role,
//         'approved': approved,
//         'userDevice': userDevice,
//         'encryption': encryption,
//       };

//   Map<String, dynamic> toJsonForSending() => {'userDevice': userDevice};

//   factory DataPayload.createModelFromJson(Map<dynamic, dynamic> json) {
//     final List<String> keyList = [
//       "userId",
//       "role",
//       "approved",
//       "userDevice",
//       "encryption"
//     ];
//     for (String key in keyList) {
//       json[key] = json.lookupWithKey(key).getOrElse(() {
//         var genAtt = Option.of(key).match((t) {
//           return t.contains("userDevice")
//               ? {"mapID": json["userDeviceMapId"] ?? ""}
//               : t.contains("approved")
//                   ? false
//                   : "Unknown";
//         }, () => "Unexpected key");
//         return Tuple2(key, genAtt);
//       }).second;
//     }
//     return DataPayload(
//         userId: json['userId'],
//         role: json['role'],
//         approved: json['approved'],
//         userDevice: json['userDevice'].runtimeType != Map
//             ? Map<String, dynamic>.from(json["userDevice"])
//             : json["userDevice"],
//         encryption: json['encryption']);
//   }

//   DataPayload bind(Function(IO) fn) {
//     return fn.call(IO.of(fn));
//   }
// }

// class DeviceBlock {
//   SensorDataBlock sensor;
//   ActuatorDataBlock actuator;

//   DeviceBlock(this.sensor, this.actuator);

//   DeviceBlock.createEncryptedModel(SensorDataBlock us, ActuatorDataBlock act) {
//     print("\n..Filling sensor and actuator into block..\n");
//     sensor = SensorDataBlock.createEncryptedModel(us);
//     actuator = ActuatorDataBlock.createEncryptedModel(act);
//     print(
//         "[Process{DeviceModel}] \tCreated device block with size ${this.toJson().length} B");
//   }

//   // Require user to manually encrypted data
//   DeviceBlock.createPartialEncryptedModel(
//       SensorDataBlock sen, ActuatorDataBlock act) {
//     sensor = sen;
//     actuator = act;
//   }

//   Map<String, dynamic> toJson() =>
//       {'userSensor': sensor?.toJson(), 'actuator': actuator?.toJson()};
//   /*
//   Map<String, dynamic> toJsonForSending() => {
//         'userSensor': sensor?.toJsonForSending(),
//         'actuator': actuator?.toJsonWithOnlyValue()
//       };
//   */
//   factory DeviceBlock.fromJson(Map<dynamic, dynamic> json) {
//     return DeviceBlock(json["userSensor"], json["actuator"]);
//   }
// }

// class SensorDataBlock {
//   dynamic id;
//   Map<String, String> type;
//   Map<String, dynamic> threshold;
//   Map<String, dynamic> timing;
//   Map<String, dynamic> calibrate;

//   SensorDataBlock(
//       this.id, this.type, this.threshold, this.timing, this.calibrate);

//   // For using in report, not for sending data in normal process.
//   SensorDataBlock.createEncryptedModel(SensorDataBlock sensor) {
//     id = sensor?.id;
//     type = sensor?.type;
//     threshold = sensor?.threshold;
//     timing = sensor?.timing;
//     calibrate = sensor?.calibrate;
//     /*
//     for (int i = 0; i < id?.length; i++) {
//       for (dynamic name in sensorValue![id[i.toString()]].keys) {
//         for (dynamic att in sensorValue![sensorName[i.toString()]][name].keys) {
//           sensorValue![sensorName[i.toString()]][name][att] = base64.encode(
//               utf8.encode(sensorValue![sensorName[i.toString()]][name][att]
//                   .toString()));
//         }
//       }
//     }*/
//     SensorDataBlock(id, type, threshold, timing, calibrate);
//     print(
//         "[Process{SensorModel}] \tCreated sensor block with size ${this.toJson().length} B");
//   }

//   //SensorDataBlock.createForSending(this.sensorStatus, this.sensorTiming,
//   //    this.calibrateValue, this.sensorThresh);
//   Map<String, dynamic> toJson() => {
//         'id': id,
//         'type': type,
//         'threshold': threshold,
//         'timing': timing,
//         'calibrate': calibrate
//       };
//   /*
//   Map<String, dynamic> toJsonForSending() => {
//         'sensorStatus': sensorStatus,
//         'sensorThresh': sensorThresh,
//         'sensorTiming': sensorTiming,
//         'calibrateValue': calibrateValue
//       };
//   */
//   factory SensorDataBlock.fromJson(Map<dynamic, dynamic> json) {
//     return SensorDataBlock(json['id'], json['type'], json['threshold'],
//         json['timing'], json['calibrate']);
//   }
// }

// class ActuatorDataBlock {
//   Map<String, String> actuatorId;
//   Map<String, String> type;

//   ActuatorDataBlock(this.actuatorId, this.type);

//   ActuatorDataBlock.createEncryptedModel(ActuatorDataBlock act) {
//     actuatorId = act?.actuatorId;
//     type = act?.type;
// /*
//     for (dynamic type in value!.keys) {
//       value![type.toString()] =
//           base64.encode(utf8.encode(value![type.toString()].toString()));
//     }*/

//     ActuatorDataBlock(actuatorId, type);
//     print(
//         "[Process{ActuatorModel}] \tCreated actuator block with size ${this.toJson().length} B");
//   }
// /*
//   ActuatorDataBlock.createEncryptedModelWithOnlyValue(ActuatorDataBlock? act) {
//     value = act?.value;
//     for (dynamic type in value!.keys) {
//       value![type.toString()] =
//           base64.encode(utf8.encode(value![type.toString()].toString()));
//     }
//   }*/

//   Map<String, dynamic> toJson() => {'actuatorId': actuatorId, 'type': type};

//   factory ActuatorDataBlock.fromJson(Map<dynamic, dynamic> json) {
//     return ActuatorDataBlock(json["actuatorId"], json["type"]);
//   }
// }

// class SmIOTDatabase implements SmIOTDatabaseMethod {
//   final ref = FirebaseDatabase.instance.ref();

//   @override
//   Future<Map<String, dynamic>> getData(String userId) async {
//     final snapshot = await ref.child(userId).get();
//     final event = await ref.child(userId).once(DatabaseEventType.value);
//     // create empty model of DataPayload;
//     DataPayload data = DataPayload.createEmpty();
//     return Option.of(snapshot).match((t) {
//       final Map userInfo = event.snapshot.value as Map;
//       return Option.of(userInfo).match((t) {
//         data = DataPayload.createModelFromJson(Map.from(t));
//         return data.toJson();
//       }, () => DataPayload.createModelFromJson({}).toJson());
//     }, () {
//       return data.toJson();
//     });
//   }

//   @override
//   Future<void> sendData(String userId, Map<String, dynamic> data) async {
//     TransactionResult result =
//         await ref.child('$userId').runTransaction((Object object) {
//       return Option.of(object).match((t) {
//         Map<String, dynamic> _obj = Map<String, dynamic>.from(object as Map);
//         _obj.localizedTrySetFromMap(data);
//         return Transaction.success(_obj);
//       }, () {
//         return Transaction.abort();
//       });
//     }, applyLocally: true);
//   }

//   @override
//   Future<void> testSendData(String userId, Map<String, dynamic> data) async {
//     await ref.child('$userId').update(data);
//   }
// }
