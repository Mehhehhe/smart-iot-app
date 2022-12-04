import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/graph_in_farm_card.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';

class DeviceDetail extends StatelessWidget {
  Map detail;
  List<Map> liveData = [];
  List<Map> latestDatePlaceholder = [];
  List<ChartData> dataToPlot = [];

  DeviceDetail(
      {Key? key, required this.detail, required this.latestDatePlaceholder})
      : super(key: key);

  void insertChartData(String data) {
    var temp = json.decode(data);
    bool deviceState = temp["State"];
    DateTime deviceTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(temp["TimeStamp"]).toLocal();
    double value = double.parse(temp["Value"]);
    dataToPlot.add(ChartData(deviceTimeStamp, value, detail["Location"]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      child: ListView(shrinkWrap: true, children: [
        Text("${detail["DeviceName"]}"),
        BlocBuilder<UserDataStreamBloc, UserDataStreamState>(
          builder: (context, state) {
            print(
                "[CheckLength] length = ${state.data.length}, [Details] : $detail");
            if (state.data != "" || state.data != null) {
              print("[CheckDetail] .${state.data}.");
              if (state.data.length == 0) {
                print("[CheckSerial] ${detail["SerialNumber"]}");
                print(
                    "[LatestPlaceholder] ${latestDatePlaceholder[0].runtimeType}");
                liveData.add(latestDatePlaceholder[0][detail["SerialNumber"]]);
                insertChartData(json
                    .encode(latestDatePlaceholder[0][detail["SerialNumber"]]));
              } else {
                print(
                    "[LiveReceived] state updated : ${state.data.runtimeType}");
                String trimmedData =
                    state.data.substring(1, state.data.length - 1);
                liveData.add(json.decode(trimmedData));
                insertChartData(trimmedData);
              }
              return Column(
                children: [
                  Text("Detail"),
                  Text(detail.toString()),
                  Text("Graph"),
                  Text(state.data),
                  if (dataToPlot != null && liveData != null)
                    Container(
                      height: 300,
                      width: MediaQuery.of(context).size.width,
                      child: BlocProvider(
                          create: (_) => LiveDataCubit(liveData, dataToPlot),
                          child: LiveChart(type: 'line', devices: liveData)),
                    )
                  else
                    const CircularProgressIndicator()
                ],
              );
            }
            return Text("Fetching data ... ");
          },
        )
      ]),
    )));
  }
}
