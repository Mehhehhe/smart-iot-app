import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/search_widget_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
// import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/model/DeviceType.dart';
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
    print("[LatestLoop] $target");
    for (var data_map in target) {
      var tempMap = {};
      final cardName = data_map["FromDevice"];
      final latestData = json.decode(data_map["Data"]);
      final lat = latestData[0];
      print(
          "set latest loop:= $cardName: ${latestData[latestData.length - 1]}");
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

    print("[NumbCard] $data");
  }

  getDetailOfDevice(String serial) {
    Map target = {};
    if (widget.devicesData == null) {
      return target;
    }
    // print("[getDetailOfDevice] ${widget.devicesData!} , serial = $serial");
    if (widget.devicesData.runtimeType.toString() == "List<ResultItem>") {
      return widget.devicesData![0].details;
    }
    for (Map i in widget.devicesData!) {
      // print("[InDetailLoop] $i , ${i["SerialNumber"] == serial}");
      if (i["SerialNumber"] == serial) {
        target = i;
        break;
      }
    }
    // print("[DetailFetched] $target");

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

  // @override
  // void dispose() {
  //   data.clear();
  //   super.dispose();
  // }

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
    return Container(
      height: 150,
      width: double.infinity,
      child: BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
        builder: (context, state) {
          print("[SearchState] $state");
          if (state is SearchWidgetSuccess) {
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return buildSearchFound(context);
              },
            );
          } else if (state is SearchWidgetError) {
            return buildSearchError(context);
          }

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: (data.isEmpty) ? 1 : data.length,
            itemBuilder: (context, index) {
              return buildSearchEmpty(context, index);
            },
          );
        },
      ),
    );
  }

  // Default
  Widget buildSearchEmpty(BuildContext contextP, index) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) => current is SearchStateEmpty,
      builder: (context, state) {
        // print("[BuildBloc] $data");
        Map<String, dynamic> currMap = Map<String, dynamic>.from(data[index]);
        String name = currMap.keys.first;
        // print("[CheckBuildCard] $name");
        var currentValue = data[index][name]["Value"];
        var details = getDetailOfDevice(name);

        return _createCardDetailIfFound(
          name,
          currMap,
          currentValue,
          details,
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

          return _createCardDetailIfFound(
            name,
            currMap,
            currentValue,
            details,
          );
        } else {
          return Container();
        }
      },
    );
  }

  Widget _createCardDetailIfFound(
    name,
    currMap,
    currentValue,
    details,
  ) {
    return SizedBox(
      width: 250,
      child: Card(
        elevation: 5.0,
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
          onLongPress: () => showModalBottomSheet(
            context: context,
            builder: (context) =>
                _MainpageCardModal(currMap: currMap, name: name),
          ),
          child: SizedBox(
            // margin: const EdgeInsets.fromLTRB(50, 0.0, 0.0, 0.0),
            height: 100,
            child: DeviceWidgetGenerator().buildMainpageCardDisplay(
              deviceSerial: name,
              currentValue: currentValue,
              context: context,
              state: currMap[name]!["State"],
            ),
          ),
        ),
      ),
    );
  }

// ignore: long-method
  Widget _MainpageCardModal(
      {required Map<String, dynamic> currMap, required String name}) {
    return Container(
      height: 200,
      color: Colors.greenAccent,
      child: ListView(shrinkWrap: true, children: [
        // Padding(
        //   padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
        //   child: Column(
        //     children: [
        //       const Text("Toggle state"),
        //       Switch(
        //         value: currMap[name]!["State"],
        //         onChanged: (value) {
        //           widget.existedCli.publishToSetDeviceState(
        //             widget.whichFarm,
        //             name,
        //             value,
        //           );
        //           showDialog(
        //             context: context,
        //             builder: (context) => AlertDialog(
        //               title: Text("Device Status"),
        //               content: Text(
        //                 "This device will not received value from $name in the next time. You may open this again to reactivate.",
        //               ),
        //               actions: [
        //                 TextButton(
        //                   onPressed: () => Navigator.pop(context),
        //                   child: const Text("OK"),
        //                 ),
        //               ],
        //             ),
        //           );
        //           Navigator.pop(context);
        //         },
        //       ),
        //     ],
        //   ),
        // ),
        ListTile(
          tileColor: Colors.white,
          title: Text("Toggle device on/off"),
          subtitle: Row(
            children: [
              const Text("Toggle state"),
              Switch(
                value: currMap[name]!["State"],
                onChanged: (value) {
                  widget.existedCli.publishToSetDeviceState(
                    widget.whichFarm,
                    name,
                    value,
                  );
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Device Status"),
                      content: Text(
                        "This device will not received value from $name in the next time. You may open this again to reactivate.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ]),
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
