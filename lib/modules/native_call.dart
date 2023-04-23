import 'dart:convert';
import 'dart:math';

import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/src/native.dart';
import 'package:smart_iot_app/src/native/bridge_definitions.dart';

class RustNativeCall {
  // Future<Platform> platform = api.platform();
  var test = api.test();
  // var test_neural = api.testNeural();

  static const List<dynamic> valueErrs = [
    null,
    "null",
    "",
    "{}",
  ];

  List<RtDeviceVec> generateVec({
    required List<LocalHist> hist,
    bool uncleaned = false,
    bool multiValue = false,
  }) {
    List<RtDeviceVec> rtList = [];
    // generate struct for calling rust fn
    // print("Input to gen len: ${hist.length}");
    int countFalse = 0;
    for (int hIndex = 0; hIndex < hist.length; hIndex++) {
      LocalHist h = hist[hIndex];
      // error flag check
      if (valueErrs.contains(h.value)) {
        countFalse++;
        if (uncleaned) {
          rtList.add(RtDeviceVec(
            id: h.dateUnixAsId,
            device: h.device,
            farm: h.farm,
            value: !multiValue
                ? DeviceVal.single(double.parse("-1"))
                : const DeviceVal.three(
                    MultiVal(nValue: -1.0, pValue: -1.0, kValue: -1.0),
                  ),
            comment: h.comment,
          ));
        }
      } else {
        // print("Adding in ${h.value}");
        rtList.add(RtDeviceVec(
          id: h.dateUnixAsId,
          device: h.device,
          farm: h.farm,
          value: !multiValue
              ? DeviceVal.single(double.parse(h.value))
              : transformMultiValues(h.value),
          comment: h.comment,
        ));
        // print("Add completed!");
      }
    }
    rtList.sort(
      (a, b) => int.parse(b.id).compareTo(int.parse(a.id)),
    );
    // print("Generate vec get len ${rtList.length}, deleted $countFalse");

    return rtList;
  }

  DeviceVal transformMultiValues(String val) {
    Map valueToSet = {};
    // print("Transform this => $val");
    if (!val.contains('"')) {
      // print("Enter case");
      final modifiedString = val.replaceAllMapped(
        RegExp(r'([A-Za-z]+)(\s*:)', multiLine: true),
        (match) => '"${match.group(1)}"${match.group(2)}',
      );
      valueToSet = jsonDecode(modifiedString);
      // print("[TransformThree] ${valueToSet["N"].runtimeType}");
    } else {
      // print("Enter no case");
      valueToSet = json.decode(val);
      // print("[TransformThree] $valueToSet");
    }

    return DeviceVal.three(MultiVal(
      nValue: valueToSet["N"].toDouble(),
      pValue: valueToSet["P"].toDouble(),
      kValue: valueToSet["K"].toDouble(),
    ));
  }

  Future<List<MaReturnTypes>> calculateSMA({
    required List<RtDeviceVec> hist,
    int window_size = 5,
  }) async {
    var res = api.calculateSma(period: window_size, data: hist);

    return res;
  }

  Future<List<MaReturnTypes>> calculateEMA({
    required List<RtDeviceVec> hist,
    int period = 5,
  }) async {
    var res = api.calculateEma(period: period, data: hist);

    return res;
  }

  Future<List<MaReturnTypes>> staticAvg({required List<RtDeviceVec> hist}) {
    var res = api.getStaticAverage(data: hist);

    return res;
  }
}
