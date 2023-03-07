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

  numberCard({
    Key? key,
    required this.inputData,
    required this.whichFarm,
    required this.existedCli,
    required this.devicesData,
  }) : super(key: key);

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
    if (widget.devicesData == null) {
      return target;
    }
    print("[getDetailOfDevice] ${widget.devicesData!} , serial = $serial");
    if (widget.devicesData![0].runtimeType == ResultItem) {
      return widget.devicesData![0].details;
    }
    for (Map i in widget.devicesData!) {
      print("[InDetailLoop] $i , ${i["SerialNumber"] == serial}");
      if (i["SerialNumber"] == serial) {
        target = i;
        break;
      }
    }
    print("[DetailFetched] $target");
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
    // return createStreamDataDisplay(context);
    return createStreamDataDisplay(context);
  }

  Widget createStreamDataDisplay(BuildContext contextP) {
    return BlocBuilder<LiveDataCubit, LiveDataState>(
      bloc: contextP.read<LiveDataCubit>(),
      buildWhen: (previous, current) =>
          previous != current && current.dataResponse.isNotEmpty,
      builder: (context, state) {
        return buildSearchable(contextP);
      },
    );
  }

  Widget buildSearchable(BuildContext contextP) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.devicesData == null ? 1 : 2,
      ),
      shrinkWrap: true,
      itemCount: (data.isEmpty)
          ? 0
          : widget.devicesData![0].runtimeType == ResultItem
              ? 1
              : data.length,
      itemBuilder: (context, index) {
        if (widget.devicesData == null) {
          return Container();
        }

        return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
          builder: (context, state) {
            if (state is SearchWidgetSuccess) {
              return buildSearchFound(contextP);
            } else if (state is SearchWidgetError) {
              return buildSearchError(contextP);
            }

            return buildSearchEmpty(contextP, index);
          },
        );
      },
    );
  }

  // Default
  Widget buildSearchEmpty(BuildContext contextP, index) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) => current is SearchStateEmpty,
      builder: (context, state) {
        print("[BuildBloc] $data");
        Map<String, dynamic> currMap = Map<String, dynamic>.from(data[index]);
        String name = currMap.keys.first;
        print("[CheckBuildCard] $name");
        var currentValue = data[index][name]["Value"];
        var details = getDetailOfDevice(name);
        bool isIntVal = currentValue.runtimeType == double;

        return _createCardDetailIfFound(
          name,
          currMap,
          currentValue,
          details,
          isIntVal,
        );
      },
    );
  }

  Widget buildSearchFound(BuildContext context) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: context.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) =>
          previous != current && current is SearchWidgetSuccess,
      builder: (context, state) {
        if (state is SearchWidgetSuccess && state.items.isNotEmpty) {
          String name = state.items[0].deviceName;
          Map<String, dynamic> currMap = Map<String, dynamic>.from(data
              .where((element) => element.keys.toString() == "($name)")
              .toList()[0]);
          var currentValue = currMap[name]["Value"];
          if (currentValue == null) {
            return Container();
          }
          var details = getDetailOfDevice(name);
          bool isIntVal = currentValue.runtimeType == double;

          return _createCardDetailIfFound(
            name,
            currMap,
            currentValue,
            details,
            isIntVal,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _createCardDetailIfFound(
      name, currMap, currentValue, details, bool isMultiVal) {
    return Card(
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (_) => UserDataStreamBloc(
                client: widget.existedCli,
                device: name,
                location: widget.whichFarm,
              ),
              child: DeviceDetail(
                detail: details,
                serial: name,
                location: widget.whichFarm,
                latestDatePlaceholder: [currMap],
              ),
            ),
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: Stack(
            children: [
              // gauge here!
              if (isMultiVal)
                _gaugeInCard(name, currentValue)
              else
                _multigaugeInCard(name, currentValue),
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: Switch(
                    value: currMap[name]!["State"],
                    onChanged: (value) {
                      widget.existedCli.publishToSetDeviceState(
                        widget.whichFarm,
                        name,
                        value,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gaugeInCard(name, currentValue) {
    print("[CurrentValue] $currentValue , ${currentValue.runtimeType}");
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
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
                value: currentValue.runtimeType == String
                    ? double.parse(currentValue)
                    : currentValue,
                width: 18,
                color: Colors.greenAccent,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  "$currentValue",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _multigaugeInCard(name, currentValue) {
    // print("[NPK] ${currentValue["N"].runtimeType}");
    if (currentValue["N"] == null ||
        currentValue["P"] == null ||
        currentValue["K"] == null) {
      return Container();
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
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
                value: double.parse(currentValue["N"].toString()),
                width: 26,
                color: Colors.greenAccent,
              ),
              RangePointer(
                value: double.parse(currentValue["P"].toString()),
                width: 22,
                color: Colors.yellowAccent,
              ),
              RangePointer(
                value: double.parse(currentValue["K"].toString()),
                width: 18,
                color: Colors.redAccent,
              ),
            ],
            // annotations: [
            //   GaugeAnnotation(
            //     widget: Text(
            //       double.parse(currentValue).toString(),
            //       style: const TextStyle(
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ],
          ),
        ],
      ),
    );
  }

  Widget buildSearchError(BuildContext contextP) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) =>
          previous != current && current is SearchError,
      builder: (context, state) => Container(),
    );
  }
}
