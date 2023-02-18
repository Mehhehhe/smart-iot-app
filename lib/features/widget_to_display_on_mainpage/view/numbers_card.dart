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
      itemCount: (widget.devicesData == null || data.isEmpty)
          ? 1
          : widget.devicesData!.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            buildSearchError(contextP),
            buildSearchFound(contextP),
            buildSearchEmpty(contextP, index),
          ],
        );
      },
    );
  }

  // Default
  Widget buildSearchEmpty(BuildContext contextP, index) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) =>
          previous != current && current is SearchStateEmpty,
      builder: (context, state) {
        Map<String, dynamic> currMap = Map<String, dynamic>.from(data[index]);
        String name = currMap.keys.first;
        var currentValue = data[index][name]["Value"];
        var details = getDetailOfDevice(name);

        return _createCardDetailIfFound(name, currMap, currentValue, details);
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
          var details = getDetailOfDevice(name);

          return _createCardDetailIfFound(name, currMap, currentValue, details);
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }

  Widget _createCardDetailIfFound(name, currMap, currentValue, details) {
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
              _gaugeInCard(name, currentValue),
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
                value: double.parse(currentValue),
                width: 18,
                color: Colors.greenAccent,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  double.parse(currentValue).toString(),
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

  Widget buildSearchError(BuildContext contextP) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) =>
          previous != current && current is SearchError,
      builder: (context, state) => Container(),
    );
  }
}
