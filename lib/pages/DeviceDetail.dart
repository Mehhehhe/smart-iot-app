import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/graph_in_farm_card.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/pages/DeviceEditor.dart';

class DeviceDetail extends StatelessWidget {
  Map detail;
  List<Map> liveData = [];
  List<Map> latestDatePlaceholder = [];
  List<ChartData> dataToPlot = [];
  String serial;
  String location;

  List graphTypes = ["line", "bar", "pie"];

  DeviceDetail({
    Key? key,
    required this.detail,
    required this.serial,
    required this.location,
    required this.latestDatePlaceholder,
  }) : super(key: key);

  void insertChartData(String data) {
    var temp = json.decode(data);
    bool deviceState = temp["State"];
    DateTime deviceTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(temp["TimeStamp"]).toUtc();
    double value = double.parse(temp["Value"]);
    dataToPlot
        .add(ChartData(deviceTimeStamp, value, detail["Location"] ?? location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        centerTitle: true,
        title: Text(
          "${detail["DeviceName"] ?? serial}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: ListView(
              shrinkWrap: true,
              children: [
                BlocBuilder<UserDataStreamBloc, UserDataStreamState>(
                  builder: (context, state) {
                    // print(
                    //     "[CheckLength] length = ${state.data.length}, [Details] : $detail");
                    if (state.data != "" || state.data != null) {
                      // print(
                      //     "[CheckDetail] .${state.data}. ${latestDatePlaceholder[0]}, device: ${state.location}");
                      if (state.data.isEmpty) {
                        liveData.add(latestDatePlaceholder[0]
                            [detail["SerialNumber"] ?? serial]);
                        insertChartData(
                          json.encode(
                            latestDatePlaceholder[0]
                                [detail["SerialNumber"] ?? serial],
                          ),
                        );
                      } else {
                        String trimmedData =
                            state.data.substring(1, state.data.length - 1);
                        liveData.add(json.decode(trimmedData));
                        insertChartData(trimmedData);
                      }

                      return Column(
                        children: [
                          ExpansionTile(
                            title: const Text('Detail'),
                            initiallyExpanded: false,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 4,
                                      color: Color(0x33000000),
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  itemCount: detail.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    var dateCreate = "";
                                    if (detail.entries.elementAt(index).key ==
                                        "CreateAt") {
                                      dateCreate =
                                          DateTime.fromMillisecondsSinceEpoch(
                                        detail.entries.elementAt(index).value,
                                      ).toLocal().toString();
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 5, 20, 0),
                                          child: Text(
                                            detail.entries
                                                .elementAt(index)
                                                .key
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              20, 5, 20, 0),
                                          child: Text(
                                            dateCreate == ""
                                                ? detail.entries
                                                    .elementAt(index)
                                                    .value
                                                    .toString()
                                                : dateCreate,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          DropdownButton(
                            items: graphTypes
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (value) => print(value),
                          ),
                          if (dataToPlot != null && liveData != null)
                            Container(
                              height: 300,
                              width: MediaQuery.of(context).size.width,
                              child: BlocProvider(
                                create: (_) =>
                                    LiveDataCubit(liveData, dataToPlot),
                                child: LiveChart(
                                  type: 'line',
                                  devices: liveData,
                                ),
                              ),
                            )
                          else
                            const CircularProgressIndicator(),
                        ],
                      );
                    }

                    return const Text("Fetching data ... ");
                  },
                ),
                // Redirect to device editor page.
                DeviceEditor(
                  deviceName: detail["SerialNumber"] ?? serial,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
