import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/search_widget_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/model/SearchResult.dart';
import 'package:smart_iot_app/pages/DeviceDetail.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class numberCard extends StatefulWidget {
  List<Map> inputData;
  String whichFarm;
  MQTTClientWrapper existedCli;
  List? devicesData;

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
    if (widget.devicesData![0].runtimeType == ResultItem) {
      return widget.devicesData![0].details;
    }
    for (Map i in widget.devicesData!) {
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
  void dispose() {
    data.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      builder: (context, state) {
        if (state.dataResponse.isNotEmpty) {
          return GridView.builder(
            shrinkWrap: true,
            itemCount: (widget.devicesData == null || data.length == 0)
                ? 1
                : widget.devicesData!.length,
            itemBuilder: (context, index) {
              print("Building item: $data");
              return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
                builder: (context, state) {
                  if (state is SearchWidgetSuccess && state.items.isNotEmpty) {
                    // if (state.items.isEmpty) {
                    //   return Container();
                    // }
                    var name = state.items[0].deviceName;
                    print("Build searched $name, from $data");
                    var currmap = Map<String, dynamic>.from(data
                        .where(
                            (element) => element.keys.toString() == "($name)")
                        .toList()[0]);
                    print("Query get : $currmap");
                    var currentValue = currmap[name]["Value"];
                    var details = getDetailOfDevice(name);
                    print("Target searched details: $details");
                    return Card(
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                  create: (_) => UserDataStreamBloc(
                                      client: widget.existedCli,
                                      device: name,
                                      location: widget.whichFarm),
                                  child: DeviceDetail(
                                      detail: details,
                                      serial: name,
                                      location: widget.whichFarm,
                                      latestDatePlaceholder: [currmap])),
                            )),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Stack(
                            children: [
                              // gauge here!
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: SfRadialGauge(
                                  enableLoadingAnimation: true,
                                  title: GaugeTitle(text: name),
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 0,
                                      maximum: 100,
                                      radiusFactor: 0.8,
                                      showLabels: false,
                                      showTicks: false,
                                      pointers: <GaugePointer>[
                                        RangePointer(
                                          value: double.parse(currentValue),
                                          width: 18,
                                          color: Colors.greenAccent,
                                        ),
                                      ],
                                      annotations: [
                                        GaugeAnnotation(
                                            widget: Text(
                                          double.parse(currentValue).toString(),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Center(
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                                child: Switch(
                                  value: currmap[name]!["State"],
                                  onChanged: (value) {
                                    widget.existedCli.publishToSetDeviceState(
                                        widget.whichFarm, name, value);
                                  },
                                ),
                              ))
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is SearchStateEmpty) {
                    print("Enter empty cond, $data");

                    var currmap =
                        Map<String, Map<String, dynamic>>.from(data[index]);
                    var name = currmap.keys.first;
                    print(name);
                    var currentValue = data[index][name]["Value"];
                    var details = getDetailOfDevice(name);
                    return Card(
                      child: InkWell(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                  create: (_) => UserDataStreamBloc(
                                      client: widget.existedCli,
                                      device: name,
                                      location: widget.whichFarm),
                                  child: DeviceDetail(
                                      detail: details,
                                      serial: name,
                                      location: widget.whichFarm,
                                      latestDatePlaceholder: [currmap])),
                            )),
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: Stack(
                            children: [
                              // gauge here!
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.2,
                                child: SfRadialGauge(
                                  enableLoadingAnimation: true,
                                  title: GaugeTitle(text: name),
                                  axes: <RadialAxis>[
                                    RadialAxis(
                                      minimum: 0,
                                      maximum: 100,
                                      radiusFactor: 0.8,
                                      showLabels: false,
                                      showTicks: false,
                                      pointers: <GaugePointer>[
                                        RangePointer(
                                          value: double.parse(currentValue),
                                          width: 18,
                                          color: Colors.greenAccent,
                                        ),
                                      ],
                                      annotations: [
                                        GaugeAnnotation(
                                            widget: Text(
                                          double.parse(currentValue).toString(),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold),
                                        ))
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Center(
                                  child: Padding(
                                padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                                child: Switch(
                                  value: currmap[name]!["State"],
                                  onChanged: (value) {
                                    widget.existedCli.publishToSetDeviceState(
                                        widget.whichFarm, name, value);
                                  },
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (state is SearchError) {
                    print("State $state");
                    return Container();
                  }
                  return Container(
                    child: Center(
                      child: Text(
                        "No result. Please try again",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  );
                },
              );
            },
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.devicesData == null ? 1 : 2),
          );
        } else if (data.isEmpty) {
          return Container(
            child: Center(
              child: Text("No device"),
            ),
          );
        }
        return Container();
      },
    );
  }
}
