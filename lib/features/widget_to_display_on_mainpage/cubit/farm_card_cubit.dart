import 'dart:convert';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

part 'farm_card_state.dart';

class FarmCardCubit extends Cubit<FarmCardInitial> {
  FarmCardCubit() : super(FarmCardInitial(farmIndex: 0, farms: const []));

  void chooseIndex(int index, List farms) =>
      emit(FarmCardInitial(farmIndex: index));

  int currentIndex() => state.farmIndex;

  getOwnedFarmsList() async {
    var res = await Amplify.Auth.getCurrentUser();
    var data = await getUserById(res.username);
    //emit(data);
    return data;
  }

  decodeAndRemovePadding(String encodedFarmName) {
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

  // fetch data for plotting graph
  prepareDataForGraph(
      Stream<String> mqttFetchData, List<dynamic> chartToAdded, dynamic _obj) {
    Stream<String> rawData = mqttFetchData;
    rawData.forEach((element) {
      var sv = json.decode(element);
      Map jsonSV = Map<String, dynamic>.from(sv);
      // access Items
      List<Map> data = jsonSV["Items"]["DeviceValue"];
      data.forEach((element) {
        var ts = DateTime.fromMillisecondsSinceEpoch(element["TimeStamp"]);
        var v = element["value"];
        chartToAdded.add(_obj(ts, v));
      });
    });
    return chartToAdded;
  }
}
