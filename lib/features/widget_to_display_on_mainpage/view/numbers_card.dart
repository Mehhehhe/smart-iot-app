import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/pages/DeviceDetail.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';

class numberCard extends StatefulWidget {
  List<Map> inputData;
  String whichFarm;
  MQTTClientWrapper existedCli;
  List devicesData;

  numberCard(
      {Key? key,
      required this.inputData,
      required this.whichFarm,
      required this.existedCli,
      required this.devicesData})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _numberCardState();
}

class _numberCardState extends State<numberCard> {
  late List<Map> data;

  void _setLatest(List<Map> target) {
    var latestList = <Map>[];
    for (var data_map in target) {
      var tempMap = {};
      final cardName = data_map["FromDevice"];
      final latestData = json.decode(data_map["Data"]);
      final lat = latestData[0];
      print("{$cardName: ${latestData[latestData.length - 1]}}");
      tempMap = {cardName: latestData[latestData.length - 1]};
      if (!latestList.contains(tempMap)) {
        print("[LatestList] $tempMap");
        // Check existing device
        for (var submap in latestList) {
          if (submap.containsKey(cardName)) {
            latestList.remove(submap);
            break;
          }
        }
        latestList.add(tempMap);
      }

      tempMap = {};
    }
    setState(() {
      data = latestList;
    });
  }

  getDetailOfDevice(String serial) {
    Map target = {};
    for (Map i in widget.devicesData) {
      target = i["SerialNumber"] == serial ? i : {};
    }
    return target;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      data = widget.inputData;
      _setLatest(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) {
        var currMap = Map<String, Map<String, dynamic>>.from(data[index]);
        var currentName = currMap.keys.first;
        var currentValue = currMap.values.first.values.first;

        var details = getDetailOfDevice(currentName);

        print("$currentName, $currentValue");
        return Card(
            child: Column(
          children: [
            TextButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                        create: (_) => UserDataStreamBloc(
                            client: widget.existedCli,
                            device: currentName,
                            location: widget.whichFarm),
                        child: DeviceDetail(detail: details)),
                  )),
              child: Text(currentName, style: const TextStyle(fontSize: 28)),
            ),

            Text(currentValue, style: const TextStyle(fontSize: 24)),
            // Text(data[index]["Value"].toString(),
            //     style: const TextStyle(fontSize: 28))
          ],
        ));
      },
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    );
  }
}
