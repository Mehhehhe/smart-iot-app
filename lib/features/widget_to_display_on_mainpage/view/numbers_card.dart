import 'dart:convert';

import 'package:flutter/cupertino.dart';
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

class numberCard extends StatefulWidget {
  List<Map> inputData;
  String whichFarm;
  MQTTClientWrapper existedCli;
  List? devicesData;
  dynamic splByType;

  numberCard({
    Key? key,
    required this.inputData,
    required this.whichFarm,
    required this.existedCli,
    required this.devicesData,
    required this.splByType,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _numberCardState();
}

class _numberCardState extends State<numberCard> {
  late List<Map> data;
  double valueToSet = 1.0;
  double max = 500.0;
  double min = 0.0;
  TextEditingController valueController = TextEditingController();

  void _setLatest(List<Map> target) {
    var latestList = <Map>[];
    // print("[LatestLoop] $target");
    for (var data_map in target) {
      var tempMap = {};
      final cardName = data_map["FromDevice"];
      final latestData = data_map["Data"];
      print("\n\nset latest loop:= $cardName: ${latestData.runtimeType}\n\n");
      tempMap = {cardName: latestData[latestData.length - 1]};
      if (!latestList.contains(tempMap)) {
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
    print("[LatestListLength] ${latestList.length}");

    setState(() {
      data = latestList;
    });

    // print("[NumbCard] $data");
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
      print("[Ongoing] $data");
      _setLatest(data);
    });
  }

  @override
  Widget build(BuildContext context) {
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

  //ignore: long-method
  Widget buildSearchable(BuildContext contextP) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      width: double.infinity,
      child: BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
        builder: (context, state) {
          // print("[SearchState] ${state.}");
          if (state is SearchWidgetSuccess) {
            return Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: state.items.length,
                itemBuilder: (context, index) {
                  return buildSearchFound(context, index);
                },
              ),
            );
          } else if (state is SearchWidgetError) {
            return buildSearchError(context);
          }

          return ListView.builder(
            // scrollDirection: Axis.horizontal,
            primary: false,
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: (widget.splByType[widget.whichFarm].keys.length == 0)
                ? 1
                : widget.splByType[widget.whichFarm].keys.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.shade800,
                        blurRadius: 15,
                        offset: Offset(5, 5), // Shadow position
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      buildSearchEmpty(context, index),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Default
  // ignore: long-method
  Widget buildSearchEmpty(BuildContext contextP, index) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: contextP.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) => current is SearchStateEmpty,
      builder: (context, state) {
        print("[BuildBloc] $data");
        if (data.isEmpty) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Center(
                widthFactor: 1.8,
                child: Text(
                  "No devices found on this farm.",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        }
        print("\n\n[Index] ${data[index]}\n\n");
        Map<String, dynamic> currMap = Map<String, dynamic>.from(
          index <= data.length - 1 ? data[index] : {},
        );
        bool defaultPlaceholder = false;
        if (currMap.isEmpty) {
          // return default place holder of that device
          defaultPlaceholder = true;

          return Container(
            child: const Text("Incompleted device data."),
          );
        }

        String name = currMap.keys.first;
        String pname = name.substring(0, 2);
        // print("[pname] $pname");
        List byTypeList = [];
        for (var t in widget.splByType[widget.whichFarm].keys) {
          // print("[tloop] $t");
          if (t.contains(pname)) {
            byTypeList = widget.splByType[widget.whichFarm][t]["data"];
          }
        }
        print("byTypeList $byTypeList");

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          primary: false,
          itemCount: byTypeList.length,
          itemBuilder: (context, index) {
            var ss = byTypeList[index];
            // print("\n\n[ss] $ss\n\n");
            var data = ss["Data"].runtimeType == String
                ? json.decode(ss["Data"])
                : ss["Data"];
            if (ss["Data"] == null) {
              return Container();
            }
            int lastIndex = data.length - 1;
            var currentVal = data[lastIndex]["Value"];
            // print("Type: ${ss["FromDevice"].runtimeType}");
            var currName = ss["FromDevice"];
            var details = getDetailOfDevice(currName);
            print("\n\n[CheckLatestLength] ${data.length}\n\n");
            Map currMap = {
              currName: data[lastIndex],
            };
            print("CurrentMap $currMap");

            return _createCardDetailIfFound(
              currName,
              currMap,
              currentVal,
              details,
            );
          },
        );
      },
    );
  }

  Widget buildSearchFound(BuildContext context, int index) {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      bloc: context.read<SearchWidgetBloc>(),
      buildWhen: (previous, current) =>
          previous != current && current is SearchWidgetSuccess,
      builder: (context, state) {
        if (state is SearchWidgetSuccess && state.items.isNotEmpty) {
          String name = state.items[index].deviceName;
          List tempList = data
              .where((element) => element.keys.toString() == "($name)")
              .toList();
          // print();
          Map<String, dynamic> currMap =
              Map<String, dynamic>.from(tempList[tempList.length - 1]);
          // print(currMap);
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
        //elevation: 5.0,
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
            builder: (context) => _MainpageCardModal(
              currMap: Map<String, dynamic>.from(currMap),
              name: name,
            ),
          ),
          child: SizedBox(
            // margin: const EdgeInsets.fromLTRB(50, 0.0, 0.0, 0.0),
            height: 100,
            child: DeviceWidgetGenerator(
              deviceSerial: name,
              currentValue: currentValue,
              context: context,
              state: currMap[name]!["State"],
              client: widget.existedCli,
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
      height: 500,
      color: Colors.white,
      padding: const EdgeInsets.all(20.0),
      child: ListView(shrinkWrap: true, children: [
        const Text(
          "Quick Settings",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        ListTile(
          tileColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Toggle device on/off"),
              CupertinoSwitch(
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
                      title: const Text("Device Status"),
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
        ListTile(
          title: Text("Value Control"),
          subtitle: const Text(
              "Set the device's controller value. Tap to start set the value."),
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              // For control only 2 values
              print("Dialog of $name");
              if (name.contains("FAN")) {
                return AlertDialog(
                  title: Text("Toggle Control"),
                  content: Container(
                    height: 200,
                    child: Column(
                      children: [
                        Text(
                            "The current state is ${currMap[name]["Value"] ? "on" : "off"}"),
                        Text(
                          "\nThis device will be updated in the next time. You may have to restart the application to see new value.",
                        ),
                        ElevatedButton(
                            onPressed: () {
                              widget.existedCli.publishToControlValue(
                                widget.whichFarm,
                                name,
                                "true",
                              );
                              Navigator.pop(context);
                            },
                            child: Text("On")),
                        ElevatedButton(
                            onPressed: () {
                              widget.existedCli.publishToControlValue(
                                widget.whichFarm,
                                name,
                                "false",
                              );
                              Navigator.pop(context);
                            },
                            child: Text("Off")),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("Cancel")),
                  ],
                );
              }

              return AlertDialog(
                title: Text("Value Control"),
                content: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 170,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // minus
                              TextButton.icon(
                                  onPressed: () {
                                    if (valueToSet > min) {
                                      setState(() {
                                        valueToSet = valueToSet - 0.1;
                                        valueController.text =
                                            valueToSet.toStringAsPrecision(5);
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.remove),
                                  label: Text("")),
                              // textfield
                              Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: TextFormField(
                                  controller: valueController,
                                  enabled: true,
                                  textAlign: TextAlign.center,
                                  // initialValue: "0.0",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              // plus
                              TextButton.icon(
                                  onPressed: () {
                                    if (valueToSet < max) {
                                      setState(() {
                                        valueToSet = valueToSet + 0.1;
                                        valueController.text =
                                            valueToSet.toStringAsPrecision(5);
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.add),
                                  label: Text("")),
                            ],
                          ),
                          Slider.adaptive(
                            min: 0.0,
                            max: 500.0,
                            value: valueToSet,
                            divisions: 100,
                            label: valueToSet.toStringAsPrecision(5),
                            onChanged: (double value) => setState(() {
                              valueToSet = value;
                              valueController.text = valueToSet.toString();
                            }),
                          ),
                          const Text(
                            "Note: press buttons for increase/decrease by 0.1. You may use slider to move value by 5.",
                            softWrap: true,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () => widget.existedCli.publishToControlValue(
                            widget.whichFarm,
                            name,
                            valueToSet,
                          ),
                      child: Text("Send")),
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel")),
                ],
              );
            },
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
