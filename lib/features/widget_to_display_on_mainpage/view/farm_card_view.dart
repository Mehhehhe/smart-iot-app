import 'dart:async';
import 'dart:convert';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/search_widget_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/widget_in_flip_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/device_selector_for_graph.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/numbers_card.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/report_in_pdf.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/search_bar.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/model/ReportModel.dart';
import 'package:smart_iot_app/model/SearchResult.dart';
import 'package:smart_iot_app/modules/pipe.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

import 'graph_in_farm_card.dart';

int farmIndex = 0;
List mainWidgetDisplay = ["graph", "numbers", "report"];
List rearWidgetDisplay = ["state_setting", "hist"];
int defaultMainDisplay = 1;
int displayRearIndex = 0;

class farmCardView extends StatefulWidget {
  String username;
  int? overrideFarmIndex;
  farmCardView({Key? key, required this.username, this.overrideFarmIndex})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _farmCardViewState();
}

class _farmCardViewState extends State<farmCardView> {
  MQTTClientWrapper client = MQTTClientWrapper();
  List devices = [];
  List devList = [];
  List<Map<String, String>> deviceAndType = [];
  var exposedLoc = "";
  String tempLoc = "";
  // Data stream
  List<Map> dataResponse = [];
  bool enableGraph = false;
  bool isRefreshed = false;
  LocalHistoryDatabase lc = LocalHistoryDatabase.instance;

  // Boolean for control widgets
  bool isDraggable = true;
  late Timer timer;
  ScrollController historyScroll = ScrollController(initialScrollOffset: 0.0);

  FlipCardController _controller = FlipCardController();
  late TextEditingController searchTextController;
  String searchedText = "";

  _farmCardViewState() {
    // Fetch for initialize
    Future.delayed(const Duration(seconds: 10), () => periodicallyFetch());
  }

  void onIndexSelection(dynamic index) {
    setState(() {
      farmIndex = index;
    });
  }

  void onDeviceSelection(List ind) async {
    var loc = devices[0]["Location"];
    setState(() {
      enableGraph = true;
      exposedLoc = loc;
      devList = ind;
    });
  }

  void setDataListener() {
    client
        .getMessageStream()!
        .listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      // print("PAYLOAD INSPECT: ${c[0].topic}");
      final splitTop = c[0].topic.split("/");
      final originFarm = splitTop.elementAt(0);
      final originalPos = splitTop.elementAt(1);
      // print("Topic type:${originalPos.runtimeType}.$originalPos.");
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        // print("Fetch pt := $pt, base data array := $dataResponse");
        if (!dataResponse.contains(pt)) {
          dataResponse.add(
            {"Data": pt, "FromDevice": originalPos, "FromFarm": originFarm},
          );
          autoSaveLocal(pt, originalPos, originFarm);
        }
      });
    });
  }

  Future<void> autoSaveLocal(histVals, dev, farm) async {
    var h = json.decode(histVals).cast().toList();
    for (var v = 0; v < h.length; v++) {
      LocalHist tempForSav = LocalHist(
        h[v]["TimeStamp"].toString(),
        dev,
        farm,
        h[v]["Value"],
        "",
      );
      // print("[ID] ${h[v]["TimeStamp"].toString()}");
      var res = await lc.add(tempForSav);
      // print(res.toJson());
      // var allHist = await lc.getAllHistory();
      // print("[Hist] ${}");
    }
  }

  void periodicallyFetch() {
    // print("\nStatusperiodicallyFetch sub: $tempLoc, $devices\n");
    setState(() {
      if (mounted) {
        dataResponse.clear();
        client.subscribeToOneResponse(exposedLoc == "" ? tempLoc : exposedLoc,
            devList.isEmpty ? devices : devList, false);
        devicesToTypeMap(List<Map>.from(devices));
      }
      isRefreshed = false;
    });
  }

  // var devicesToList = (farm) async => await getDevicesByFarmName(farm);
  devicesToList(farm) async {
    var temp_devices = await getDevicesByFarmName(farm);
    devices = temp_devices;
  }

  devicesToTypeMap(List<Map> devs) {
    for (var sub in devs) {
      var temp = {
        "Name": sub["DeviceName"].toString(),
        "Type": sub["Type"].toString()
      };
      deviceAndType.add(temp);
      temp = {};
    }
  }

  List localizedResponse() {
    var newDataArray = [];
    for (var m in dataResponse) {
      m.forEach((key, value) {
        if (key == "Data") {
          var tr = json.decode(value).cast().toList();
          for (var element in tr) {
            var temp = {
              "Value": element["Value"],
              "State": element["State"],
              "TimeStamp":
                  DateTime.fromMillisecondsSinceEpoch(element["TimeStamp"])
                      .toLocal()
                      .toString(),
              "FromDevice": m["FromDevice"]
            };
            newDataArray.add(temp);
            temp = {};
          }
        }
      });
    }

    return newDataArray;
  }

  @override
  void initState() {
    client.prepareMqttClient();
    setDataListener();
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    client.disconnect();
    devices.clear();
    enableGraph = false;
    dataResponse.clear();
    devList.clear();
    tempLoc = "";
    exposedLoc = "";
    // timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: BlocProvider(
          create: (_) =>
              SearchWidgetBloc(searchDev: SearchDevice(SearchCache(), devices)),
          child: Column(
            children: [
              // Search bar\
              SearchBar(),
              SearchBody()
            ],
          )),
    );
  }

  Widget SearchBody() {
    return BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
      builder: (context, state) {
        if (state is SearchStateEmpty) {
          return normalCard();
        }
        if (state is SearchStateLoading) {
          return const CircularProgressIndicator();
        }
        if (state is SearchWidgetError) {
          print("Not found: ${state.error}");
          return Container(
            child: const Text("Not Found"),
          );
        }
        if (state is SearchWidgetSuccess) {
          print("Searched ${state.items}");
          return state.items.isEmpty ? normalCard() : normalCard(state.items);
        }
        print("Out of condition");
        return Container();
      },
    );
  }

  Widget normalCard([List? items]) {
    return ListView.builder(
      itemCount: 1,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: FutureBuilder(
            future: context.read<FarmCardCubit>().getOwnedFarmsList(),
            builder: (context, snapshot) {
              var connectionState = snapshot.connectionState;
              // print(connectionState);
              switch (connectionState) {
                case ConnectionState.done:
                  // print(snapshot.data);
                  Map dataMap = Map.from(snapshot.data as Map);
                  return FlipCard(
                      controller: _controller,
                      flipOnTouch: false,
                      onFlipDone: (isFront) => print(isFront),
                      front: BlocProvider(
                        create: (_) => FrontOfCardCubit(),
                        child: farmAsCard(context, dataMap["OwnedFarm"], items),
                      ),
                      back: BlocProvider(
                        create: (_) => BackOfCardCubit(),
                        child: farmCardRear(),
                      ));
                default:
                  break;
              }
              return Container();
            },
          ),
        );
      },
    );
  }

  Widget farmAsCard(BuildContext context, dynamic data, [List? searched]) {
    return BlocBuilder<FrontOfCardCubit, CardState>(
      builder: (context, state) {
        print("[Device] $devices");
        return Card(
          key: const ValueKey(true),
          margin: const EdgeInsets.all(20),
          elevation: 5.0,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BlocBuilder<FarmCardCubit, FarmCardInitial>(
                  builder: (context, state) {
                    print(
                        "state index: ${state.farmIndex} , farm index: $farmIndex");
                    print("[Response] $dataResponse");
                    print("Get search list ${searched?[0].deviceName}");
                    if (widget.overrideFarmIndex != null) {
                      // onIndexSelection(widget.overrideFarmIndex);
                      var farmTarget = context
                          .read<FarmCardCubit>()
                          .decodeAndRemovePadding(
                              data[widget.overrideFarmIndex]);
                      devicesToList(farmTarget);
                      context
                          .read<SearchWidgetBloc>()
                          .add(BaseListChanged(devices));
                      // if (state.farmIndex != widget.overrideFarmIndex) {
                      //   dataResponse.removeWhere(
                      //       (element) => !devices.contains(element));
                      // }
                      tempLoc = farmTarget;

                      return Text(farmTarget,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold));
                    }
                    if (state.farmIndex == farmIndex) {
                      // print("Created within condition");
                      devicesToList(context
                          .read<FarmCardCubit>()
                          .decodeAndRemovePadding(data[state.farmIndex]));
                      // print(devices);
                      tempLoc = FarmCardCubit()
                          .decodeAndRemovePadding(data[state.farmIndex]);
                      context
                          .read<SearchWidgetBloc>()
                          .searchDev
                          .addDeviceList(devices);
                      return Text(
                          context
                              .read<FarmCardCubit>()
                              .decodeAndRemovePadding(data[state.farmIndex]),
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold));
                    }
                    // print("Created out of condition");
                    devicesToList(context
                        .read<FarmCardCubit>()
                        .decodeAndRemovePadding(data[farmIndex]));
                    // print(devices);
                    tempLoc =
                        FarmCardCubit().decodeAndRemovePadding(data[farmIndex]);
                    context
                        .read<SearchWidgetBloc>()
                        .searchDev
                        .addDeviceList(devices);
                    return Text(
                        context
                            .read<FarmCardCubit>()
                            .decodeAndRemovePadding(data[farmIndex]),
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold));
                  },
                ),
                // TextButton(
                //     onPressed: () async {
                //       // _displayFarmEditor(context, data);
                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) => FarmEditor(farm: data),
                //           )).then((value) => onIndexSelection(value));
                //     },
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: const [
                //         Icon(Icons.edit),
                //         Text("Change to another farm")
                //       ],
                //     )),
                // if (state.widgetIndex == 0)
                //   Container(
                //     height: 300,
                //     width: MediaQuery.of(context).size.width,
                //     margin: const EdgeInsets.all(10),
                //     child: Stack(children: [
                //       if (dataResponse.isEmpty)
                //         const Center(
                //           child: CircularProgressIndicator(),
                //         )
                //       else
                //         BlocProvider(
                //           create: (_) => LiveDataCubit(
                //               dataResponse, transformFromRawData(dataResponse)),
                //           child: LiveChart(
                //             devices: dataResponse,
                //             type: 'line',
                //           ),
                //         )
                //     ]),
                //   )
                const Divider(),
                if (state.widgetIndex == 1)
                  Container(
                    height: 400,
                    width: MediaQuery.of(context).size.width,
                    child: Stack(
                      children: [
                        if (dataResponse.isEmpty)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else
                          BlocBuilder<FarmCardCubit, FarmCardInitial>(
                            bloc: context.read<FarmCardCubit>(),
                            builder: (context, state) {
                              print("Respond To Change: ${state.farmIndex}");
                              var selectedResponse = dataResponse
                                  .where((element) =>
                                      element["FromFarm"] == tempLoc)
                                  .toList();
                              print("Select $selectedResponse");
                              return BlocProvider(
                                create: (_) => LiveDataCubit(selectedResponse),
                                child: BlocBuilder<SearchWidgetBloc,
                                    SearchWidgetState>(
                                  builder: (context, state) {
                                    if (state is SearchWidgetSuccess) {
                                      return numberCard(
                                          inputData: selectedResponse,
                                          whichFarm: tempLoc,
                                          existedCli: client,
                                          devicesData: searched);
                                    }
                                    return numberCard(
                                        inputData: selectedResponse,
                                        whichFarm: tempLoc,
                                        existedCli: client,
                                        devicesData: devices);
                                  },
                                ),
                              );
                            },
                          )
                      ],
                    ),
                  ),
                // const Text("What to be display ?"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Column(
                    //   children: [
                    //     IconButton(
                    //         onPressed: () =>
                    //             context.read<FrontOfCardCubit>().chooseIndex(0),
                    //         icon: const Icon(Icons.auto_graph)),
                    //     const Text("Graph"),
                    //   ],
                    // ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () =>
                                context.read<FrontOfCardCubit>().chooseIndex(1),
                            icon: const Icon(Icons.numbers)),
                        const Text("Numbers"),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ReportPreview(
                                      reportCard: ReportCard(
                                          exposedLoc == ""
                                              ? tempLoc
                                              : exposedLoc,
                                          deviceAndType,
                                          const Text(""),
                                          "-",
                                          widget.username,
                                          dataResponse)),
                                )),
                            icon: const Icon(Icons.description_outlined)),
                        const Text("Status Report"),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                            onPressed: () => _controller.toggleCard(),
                            icon:
                                const Icon(Icons.keyboard_double_arrow_right)),
                        const Text("More"),
                      ],
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 25, 0, 0))
                // TextButton(
                //     onPressed: () async {
                //       await Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) =>
                //                 DeviceSelector(devices: devices),
                //           )).then((value) => onDeviceSelection(value));
                //     },
                //     child: const Text("Choose devices ..."))
              ]),
        );
        ;
      },
    );
  }

  Widget farmCardRear() {
    return BlocBuilder<BackOfCardCubit, CardState>(
        builder: (context, state) => Card(
              key: const ValueKey(false),
              margin: const EdgeInsets.all(20),
              elevation: 5.0,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const Text("Rear"),
                    // Container(
                    //   width: MediaQuery.of(context).size.width,
                    //   child: const Text("Value History"),
                    // ),
                    const Divider(),
                    if (state.widgetIndex == 0)
                      Builder(
                        builder: (context) {
                          var tempArr = <Map>[];
                          for (var data in dataResponse) {
                            var tempMap = {};
                            final t_device = data["FromDevice"];
                            final lt_data = json.decode(data["Data"]);
                            tempMap = {
                              t_device.toString(): lt_data[lt_data.length - 1]
                            };
                            tempArr.add(tempMap);
                            tempMap = {};
                          }

                          return Container(
                            child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2),
                                itemBuilder: (context, index) {
                                  var currMap =
                                      Map<String, dynamic>.from(tempArr[index]);
                                  var currName = currMap.keys.first;
                                  print(
                                      "$currMap State Check: ${currMap[currName]["State"]}");
                                  Iterable chainCode = const Iterable.empty();
                                  return Column(
                                    children: [
                                      Text(currName),
                                      // Text(tempArr[index][""]),
                                      Switch(
                                        value: currMap[currName]["State"],
                                        onChanged: (value) {
                                          client.publishToSetDeviceState(
                                              exposedLoc == ""
                                                  ? tempLoc
                                                  : exposedLoc,
                                              currName,
                                              value);
                                          Future.delayed(
                                              const Duration(seconds: 5),
                                              periodicallyFetch);
                                        },
                                      )
                                    ],
                                  );
                                },
                                shrinkWrap: true,
                                itemCount: tempArr.length),
                          );
                        },
                      )
                    else if (state.widgetIndex == 1)
                      Container(
                        height: 400,
                        child: Builder(
                          builder: (context) {
                            // Transform into single array
                            var newDataArray = localizedResponse();
                            newDataArray.sort((a, b) =>
                                DateTime.parse(b["TimeStamp"])
                                    .millisecondsSinceEpoch -
                                DateTime.parse(a["TimeStamp"])
                                    .millisecondsSinceEpoch);
                            return Scrollbar(
                                thumbVisibility: true,
                                controller: historyScroll,
                                thickness: 8.0,
                                interactive: true,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: newDataArray.length,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      decoration: BoxDecoration(
                                        color:
                                            newDataArray[index]["State"] == true
                                                ? Colors.lightGreen
                                                : Colors.redAccent,
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(5)),
                                      ),
                                      child: ListTile(
                                          title: Text(
                                            newDataArray[index]["FromDevice"],
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    newDataArray[index]
                                                        ["Value"],
                                                    style: const TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(newDataArray[index]
                                                    ["TimeStamp"])
                                              ])),
                                    );
                                  },
                                ));
                          },
                        ),
                      ),
                    // TextButton(
                    //     onPressed: () => getFarmExmaple(), child: Text("Test Example")),
                    // Bottom buttons for choosing widget
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              IconButton(
                                  onPressed: () => _controller.toggleCard(),
                                  icon: const Icon(Icons.keyboard_return)),
                              const Text("Return"),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(20),
                        //   child: Column(
                        //     children: [
                        //       IconButton(
                        //           onPressed: () => context
                        //               .read<BackOfCardCubit>()
                        //               .chooseIndex(0),
                        //           icon: const Icon(Icons.settings)),
                        //       const Text("Device State Settings"),
                        //     ],
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.all(20),
                        //   child: Column(
                        //     children: [
                        //       IconButton(
                        //           onPressed: () => context
                        //               .read<BackOfCardCubit>()
                        //               .chooseIndex(1),
                        //           icon: const Icon(Icons.history)),
                        //       const Text("Logs"),
                        //     ],
                        //   ),
                        // ),
                      ],
                    )
                  ]),
            ));
  }
}
