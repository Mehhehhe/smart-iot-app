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
      final originalPos = splitTop.elementAt(1);
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
      data = pt;
      if (data.isNotEmpty &&
          client.connectionState != MqttConnectionState.disconnected) {
        Map<String, dynamic> construct = {
          "Data": pt,
          "FromDevice": originalPos,
          "FromFarm": originFarm,
        };
        add(_OnCompletedFetching(
          currentIndex: currentIndex(),
          farms: state.farms,
          devices: state.devices,
          data: data,
          pt: construct,
        ));
        autoSaveLocal(pt, originalPos, originFarm);
      }
    });
    // Fetch farm first by default
    _getOwnedFarmsList();
    // Handle based on events
    _handleChoosingIndex();
    _handleFetchingFarm();
    _handleFetchingDevice();
    _handlePassCompleteData();
  }

  void chooseIndex(int index, List farms) =>
      add(_OnChoosingIndex(index: index));

  int currentIndex() => state.farmIndex;

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
    on<_OnChoosingIndex>((event, emit) => emit(FarmCardReState.loaded(
          event.index,
          state.farms,
          state.devices,
          state.data,
          state.pt,
        )));
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
    // devices = temp_devices;
    print("Cubit fetch devices : => $tempDevices");
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
    print("Decoding $encodedFarmName");
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
      LocalHist tempForSav = LocalHist(
        h[v]["TimeStamp"].toString(),
        dev,
        farm,
        h[v]["Value"].toString(),
        "",
      );
      // print("[ID] ${h[v]["TimeStamp"].toString()}");
      var res = await lc.add(tempForSav);

      triggerThreshCheck(dev, h[v]["Value"]);
      // print(res.toJson());
      // var allHist = await lc.getAllHistory();
      // print("[Hist] ${}");
    }
  }

  void triggerThreshCheck(String dev, value) {
    var enc = sha1.convert(utf8.encode(dev)).toString();
    print("[BFonstart] $value , ${value.runtimeType}");
    FlutterBackgroundService().invoke('threshDiff', {
      "encryptedKey": enc,
      "name": dev,
      "value": value.runtimeType == double ? value.toString() : value,
      "isMap": value.runtimeType == double ? false : true,
    });
  }
}
