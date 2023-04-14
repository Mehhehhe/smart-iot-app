import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/src/native.dart';
import 'package:smart_iot_app/src/native/bridge_definitions.dart';

class RustNativeCall {
  // Future<Platform> platform = api.platform();
  var test = api.test();
  var test_neural = api.testNeural();

  List<RtDeviceVec> generateVec({required List<LocalHist> hist}) {
    List<RtDeviceVec> rtList = [];
    // generate struct for calling rust fn
    for (int hIndex = 0; hIndex < hist.length; hIndex++) {
      LocalHist h = hist[hIndex];
      if (!h.device.contains("NPK") &&
          h.value != null &&
          h.value != "null" &&
          h.value != "") {
        rtList.add(RtDeviceVec(
          id: h.dateUnixAsId,
          device: h.device,
          farm: h.farm,
          value: DeviceVal.single(double.parse(h.value)),
          comment: h.comment,
        ));
      }
    }

    return rtList;
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
}
