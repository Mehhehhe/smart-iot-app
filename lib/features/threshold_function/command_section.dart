import '../../services/MQTTClientHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum RUNTYPE { ONCE, LOOP }

// class DeviceFunction {
//   final String deviceId;
//   final Map<String, dynamic> condition;
//   final List selfFunction;
//   final RUNTYPE runtype;
//   final MQTTClientWrapper cli;

//   List errTracks = [];

//   DeviceFunction(
//     this.deviceId,
//     this.condition,
//     this.selfFunction,
//     this.runtype,
//     this.cli,
//   );

//   run() => _execute();

//   Map _execute() {
//     String farmName = deviceId.split(".")[1];
//     for (var i = 1; i < selfFunction.length - 1; i++) {
//       if (selfFunction[0] != "START" ||
//           selfFunction[selfFunction.length - 1] != "END") {
//         return {
//           "code": "1",
//           "message":
//               "Cycle not exists. Initialization or finalization is not found",
//           "value": false,
//         };
//       } else if (selfFunction[i] == "END") {
//         break;
//       }
//       List spl = selfFunction[i].toString().split(" ");
//       // do some action
//       switch (spl[0]) {
//         case "STATE":
//           _statusChange(spl, farmName);
//           break;
//         case "POP":
//           _popNotification(spl, farmName);
//           break;
//         default:
//           return {
//             "code": "-1",
//             "message": "`${spl[0]}` not exists. Invalid command.",
//             "value": false,
//           };
//       }
//     }

//     return {
//       "code": "SUCCESS",
//       "message": "code executed successfully!",
//       "value": true,
//     };
//   }

//   _statusChange(List statusFunc, String farmName) {
//     if (statusFunc[0] != "STATE") {
//       return {
//         "code": "2",
//         "message": "`STATE` not exists. Invalid syntax.",
//         "value": false,
//       };
//     }
//     bool stateToSet = statusFunc[2] == "ON" ? true : false;
//     print("Change status device ${statusFunc[1]} to $stateToSet");
//     cli.publishToSetDeviceState(farmName, statusFunc[1], stateToSet);
//   }

//   _popNotification(List statusFunc, String farmName) {
//     if (statusFunc[0] != "POP") {
//       return {
//         "code": "2",
//         "message": "`POP` not exists. Invalid syntax.",
//         "value": false,
//       };
//     }
//     String temp = "";
//     for (var w = 1; w <= statusFunc.length - 1; w++) {
//       temp += statusFunc[w] + " ";
//     }
//     print(temp);
//   }
// }

class SignalStop {
  bool signalStop;
  SignalStop({this.signalStop = false});
  bool get isStopped => signalStop;
  stop() => {signalStop = true};
  resume() => {signalStop = false};
}

class DeviceCommand {
  final String id;
  final String cmd;
  final String args;

  DeviceCommand({
    required this.id,
    required this.cmd,
    required this.args,
  });

  factory DeviceCommand.load({required Map json}) => DeviceCommand(
        id: json["id"],
        cmd: json["cmd"],
        args: json["args"],
      );

  final Map<String, Function> _deviceFunctionMap = {
    "Device.state": (Map args) {
      // Create obj
      Device target = Device(id: args["id"]);

      return target.state();
    },
  };

  execute() {
    List _cmd = cmd.split(";");
    List _args =
        args.split("/").map((e) => e.contains("+") ? e.split("+") : e).toList();

    // List<Function> generator
  }
}

class Device {
  String id;

  Device({required this.id}) {}

  /// `state({String target = ""})`
  ///
  /// Optional `target`: device's serial number
  ///
  /// Return the state of the device.
  ///
  state({String target = ""}) {
    if (target == "") target = id;
    // State retrieving function (lambda?)
  }

  toggleState({
    required String safety_check_mode,
    required String action,
  }) {}
}
