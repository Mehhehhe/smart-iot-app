import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

part 'farm_card_re_event.dart';
part 'farm_card_re_state.dart';

class FarmCardReBloc extends Bloc<FarmCardReEvent, FarmCardReState> {
  final MQTTClientWrapper client;
  late String data;
  LocalHistoryDatabase lc = LocalHistoryDatabase.instance;
  List<Map<String, dynamic>> dataResponse = [];
  Map deviceByType = {};

  //ignore: long-method
  FarmCardReBloc(MQTTClientWrapper cli)
      : client = cli,
        super(const FarmCardReState.notLoaded()) {
    // create listener for data
    client
        .getMessageStream()!
        .listen((List<MqttReceivedMessage<MqttMessage>>? event) {
      final recMsg = event![0].payload as MqttPublishMessage;
      final splitTop = event[0].topic.split("/");
      final originFarm = splitTop.elementAt(0);
      final originalPos =
          splitTop.elementAt(1) == "for_init" ? "init" : splitTop.elementAt(1);
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
      data = pt;
      print("[FetchedData] $data");
      if (data != "" &&
          client.connectionState != MqttConnectionState.disconnected) {
        if (originalPos == "init") {
          var initResponse = json.decode(pt);
          List<Map<String, dynamic>> tempRes = [];
          for (Map<String, dynamic> d in initResponse) {
            // print("[d] ${d.keys}, ${d.values}");
            Map<String, dynamic> construct = {
              "Data": d.values.first,
              "FromDevice": d.keys.first,
              "FromFarm": originFarm,
            };
            tempRes.add(construct);
          }
          dataResponse.addAll(tempRes);
          add(_OnCompletedFetching(
            currentIndex: currentIndex(),
            farms: state.farms,
            devices: state.devices,
            data: data,
            pt: {"initValues": tempRes},
          ));
          autoSaveLocal(pt, originalPos, originFarm);
        } else {
          Map<String, dynamic> construct = {
            "Data": pt,
            "FromDevice": originalPos,
            "FromFarm": originFarm,
          };

          if (data != "") {
            if (!dataResponse.contains(construct)) {
              dataResponse.add(construct);
            }
          }
          print("[FetchingDP] ${dataResponse}");
          add(_OnCompletedFetching(
            currentIndex: currentIndex(),
            farms: state.farms,
            devices: state.devices,
            data: data,
            pt: construct,
          ));
          autoSaveLocal(pt, originalPos, originFarm);
        }
        // print(
        //     "\n\n[dt] ${deviceByType["Farmtest"]["FAN_CONTROL"]["data"][0]["Data"]}\n\n");
      }
    });
    // Handle based on events
    _handleChoosingIndex();
    _handleFetchingFarm();
    _handleFetchingDevice();
    _handlePassCompleteData();
    // Fetch farm first by default
    _getOwnedFarmsList();
  }

  createNewFarmDataMapForNumCard(tempLoc, List s) {
    Map temp = {tempLoc: {}};
    for (var d in state.devices) {
      Map t = {
        d["Type"]: {
          "prefix": d["Type"].toString().substring(0, 2),
          "data": [],
        },
      };
      temp[tempLoc].addEntries(t.entries);
    }
    for (var ss in s) {
      temp.forEach((key, value) {
        // print("check data $ss");
        for (var t in value.keys) {
          if (temp.containsKey(ss["FromFarm"]) &&
              ss["FromDevice"]
                  .contains(value[t]["prefix"].toString().toUpperCase())) {
            if (value[t]["data"].isEmpty) {
              if (ss["Data"].runtimeType == String) {
                ss["Data"] = json.decode(ss["Data"]);
              }
              value[t]["data"].add(ss);
              // print(value[t]);
              break;
            }
            List temp2 = [];
            for (int i = 0; i < value[t]["data"].length; i++) {
              if (value[t]["data"][i]["FromDevice"] == ss["FromDevice"]) {
                temp2.addAll(
                  ss["Data"].runtimeType == String
                      ? json.decode(ss["Data"])
                      : ss["Data"],
                );
              }
            }
            if (temp2.isNotEmpty) {
              value[t]["data"][0]["Data"].addAll(temp2);
              // print("Another cond: ${value[t]}");
            }
          }
        }
      });
    }
    // print("[temp] $temp");

    return temp;
  }

  void chooseIndex(int index) {
    add(_OnChoosingIndex(index: index));
  }

  int currentIndex() => state.farmIndex;

  List userFarmList() => state.farms;

  List<Map<String, dynamic>> getDataResponse() => dataResponse;

  _getOwnedFarmsList() async {
    var res = await Amplify.Auth.getCurrentUser();
    var data = await getUserById(res.username);
    // // Notify for user's owned farm!
    List temp = [];
    for (var i in data["OwnedFarm"]) {
      temp.add(decodeAndRemovePadding(i));
    }
    // print("[ReFarm] $temp");
    add(
      _OnFarmFetched(
        farms: temp,
        defaultIndex: currentIndex(),
      ),
    );
    // temporary sol'n

    // print("Cubit target farm: => $currentFarm");

    // emit(FarmCardInitial(farmIndex: currentIndex(), farms: state.farms, devices: devices));
    // return data;
  }

  _handleChoosingIndex() {
    on<_OnChoosingIndex>((event, emit) {
      _devicesToList(state.farms[event.index]);
    });
  }

  _handleFetchingFarm() {
    on<_OnFarmFetched>((event, emit) {
      emit(FarmCardReState.loaded(
        event.defaultIndex,
        event.farms,
        state.devices,
        "",
        const {},
      ));
      String currentFarm = event.farms[currentIndex()];
      _devicesToList(currentFarm);
    });
  }

  _handleFetchingDevice() {
    on<_OnDeviceFetched>((event, emit) => emit(FarmCardReState.loaded(
          currentIndex(),
          state.farms,
          event.devices,
          "",
          const {},
        )));
  }

  _handlePassCompleteData() {
    on<_OnCompletedFetching>((event, emit) => emit(FarmCardReState.loaded(
          event.currentIndex,
          event.farms,
          event.devices,
          event.data,
          event.pt,
        )));
  }

  _devicesToList(farm) async {
    var tempDevices = await getDevicesByFarmName(farm);
    // print("Farm devices: $tempDevices");

    emit(FarmCardReState.loaded(
      currentIndex(),
      state.farms,
      tempDevices,
      "",
      const {},
    ));
    getDeviceData();
  }

  Future<void> getDeviceData() async => client.subscribeToOneResponse(
        state.farms[currentIndex()],
        state.devices,
        false,
      );

  decodeAndRemovePadding(String encodedFarmName) {
    // print("Decoding $encodedFarmName");
    var dec = utf8.decode(base64.decode(encodedFarmName));
    // Check empty farm
    if (dec.contains("Wait for")) return "Wait for update";
    // Check padding
    int countZero = 0;
    var temp = dec.split('');
    for (int i = 0; i < temp.length; i++) {
      if (temp[i].contains('0')) {
        if (temp[i + 1].contains('0')) {
          countZero = countZero + 1;
        } else if (!temp[i + 1].contains('0')) {
          countZero = countZero + 1;
          break;
        }
      }
    }

    return dec.replaceRange(0, countZero, '');
  }

  Future<void> autoSaveLocal(histVals, dev, farm) async {
    var h = json.decode(histVals).cast().toList();
    for (var v = 0; v < h.length; v++) {
      // print(h[v]);
      LocalHist tempForSav = LocalHist(
        h[v]["TimeStamp"].toString(),
        dev,
        farm,
        h[v]["Value"].toString(),
        "",
      );
      var res = await lc.add(tempForSav);

      triggerThreshCheck(dev, h[v]["Value"], h[v]["TimeStamp"].toString());
    }
  }

  void triggerThreshCheck(String dev, value, String id) {
    var enc = sha1.convert(utf8.encode(dev)).toString();
    // print("[BFonstart] $value , ${value.runtimeType}");
    FlutterBackgroundService().invoke('threshDiff', {
      "encryptedKey": enc,
      "name": dev,
      "id": id,
      "value": value.runtimeType == double ? value.toString() : value,
      "isMap": value.runtimeType == double ? false : true,
    });
  }
}
