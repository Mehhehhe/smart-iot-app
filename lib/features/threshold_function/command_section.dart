import '../../services/MQTTClientHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RUNTYPE { ONCE, ALWAYS_ON }

class DeviceFunction {
  final String deviceId;
  final Map<String, dynamic> condition;
  final List selfFunction;
  final RUNTYPE runtype;
  final MQTTClientWrapper cli;

  List errTracks = [];

  DeviceFunction(
    this.deviceId,
    this.condition,
    this.selfFunction,
    this.runtype,
    this.cli,
  );

  run() => _execute();

  Map _execute() {
    String farmName = deviceId.split(".")[1];
    for (var i = 1; i < selfFunction.length - 1; i++) {
      if (selfFunction[0] != "START" ||
          selfFunction[selfFunction.length - 1] != "END") {
        return {
          "code": "1",
          "message":
              "Cycle not exists. Initialization or finalization is not found",
          "value": false,
        };
      } else if (selfFunction[i] == "END") {
        break;
      }
      List spl = selfFunction[i].toString().split(" ");
      // do some action
      switch (spl[0]) {
        case "STATE":
          _statusChange(spl, farmName);
          break;
        case "POP":
          _popNotification(spl, farmName);
          break;
        default:
          return {
            "code": "-1",
            "message": "`${spl[0]}` not exists. Invalid command.",
            "value": false,
          };
      }
    }

    return {
      "code": "SUCCESS",
      "message": "code executed successfully!",
      "value": true,
    };
  }

  _statusChange(List statusFunc, String farmName) {
    if (statusFunc[0] != "STATE") {
      return {
        "code": "2",
        "message": "`STATE` not exists. Invalid syntax.",
        "value": false,
      };
    }
    bool stateToSet = statusFunc[2] == "ON" ? true : false;
    print("Change status device ${statusFunc[1]} to $stateToSet");
    cli.publishToSetDeviceState(farmName, statusFunc[1], stateToSet);
  }

  _popNotification(List statusFunc, String farmName) {
    if (statusFunc[0] != "POP") {
      return {
        "code": "2",
        "message": "`POP` not exists. Invalid syntax.",
        "value": false,
      };
    }
    String temp = "";
    for (var w = 1; w <= statusFunc.length - 1; w++) {
      temp += statusFunc[w] + " ";
    }
    print(temp);
  }
}
