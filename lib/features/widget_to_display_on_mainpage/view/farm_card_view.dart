import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/farm_card_re_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/search_widget_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/history_log.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/numbers_card.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/search_bar.dart';
import 'package:smart_iot_app/model/SearchResult.dart';
import 'package:smart_iot_app/pages/AnalysisPage.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

int farmIndex = 0;
List mainWidgetDisplay = ["graph", "numbers", "report"];
List rearWidgetDisplay = ["state_setting", "hist"];
int defaultMainDisplay = 1;
int displayRearIndex = 0;

class farmCardView extends StatefulWidget {
  String username;
  int? overrideFarmIndex;
  MQTTClientWrapper cli;
  farmCardView({
    Key? key,
    required this.username,
    this.overrideFarmIndex,
    required this.cli,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _farmCardViewState();
}

class _farmCardViewState extends State<farmCardView> {
  late MQTTClientWrapper client;
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

  // FlipCardController _controller = FlipCardController();
  late TextEditingController searchTextController;
  String searchedText = "";

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

  // var devicesToList = (farm) async => await getDevicesByFarmName(farm);
  devicesToList(farm) async {
    var tempDevices = await getDevicesByFarmName(farm);
    devices = tempDevices;
  }

  devicesToTypeMap(List<Map> devs) {
    for (var sub in devs) {
      var temp = {
        "Name": sub["DeviceName"].toString(),
        "Type": sub["Type"].toString(),
      };
      deviceAndType.add(temp);
      temp = {};
    }
  }

  //ignore: long-method
  Future<Map> createNewFarmDataMapForNumCard(List s) async {
    Map temp = {tempLoc: {}};
    for (var d in devices) {
      Map t = {
        d["Type"]: {
          "prefix": d["Type"].toString().substring(0, 2),
          "data": [],
        },
      };
      temp[tempLoc].addEntries(t.entries);
    }
    for (var ss in s) {
      temp.forEach((key, value) {
        // print("check data $ss");
        for (var t in value.keys) {
          if (temp.containsKey(ss["FromFarm"]) &&
              ss["FromDevice"]
                  .contains(value[t]["prefix"].toString().toUpperCase())) {
            if (value[t]["data"].isEmpty) {
              if (ss["Data"].runtimeType == String) {
                ss["Data"] = json.decode(ss["Data"]);
              }
              value[t]["data"].add(ss);
              print(value[t]);
              break;
            }
            List temp2 = [];
            for (int i = 0; i < value[t]["data"].length; i++) {
              if (value[t]["data"][i]["FromDevice"] == ss["FromDevice"]) {
                temp2.addAll(
                  ss["Data"].runtimeType == String
                      ? json.decode(ss["Data"])
                      : ss["Data"],
                );
              }
            }
            if (temp2.isNotEmpty) {
              value[t]["data"].addAll(temp2);
              print("Another cond: ${value[t]}");
            }
          }
        }
      });
    }
    print("[temp] $temp");

    return temp;
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
              "FromDevice": m["FromDevice"],
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
    // client.prepareMqttClient();
    client = widget.cli;
    // setDataListener();
    searchTextController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocProvider(
        create: (_) =>
            SearchWidgetBloc(searchDev: SearchDevice(SearchCache(), devices)),
        child: Stack(
          children: [
            //hello world im tired.

            /*Padding(
              padding: const EdgeInsets.only(top: 120),
              child: SearchBar(),
            ),*/

            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: SearchBody(),
            ),

            /*Padding(
              padding: const EdgeInsets.only(top: 220),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //analysisWidget(),
                  //historyWidget(),
                  analysisWidget_New(),
                  historyWidget_New()
                ],
              ),
            ),*/
          ],
        ),
      ),
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
          // print("Not found: ${state.error}");
          return const Text("Not Found");
        }
        if (state is SearchWidgetSuccess) {
          // print("Searched ${state.items}");
          return state.items.isEmpty ? normalCard() : normalCard(state.items);
        }
        // print("Out of condition");

        return Container();
      },
    );
  }

  Widget normalCard([List<ResultItem>? items]) {
    return ListView.builder(
      // testing fetch new farm
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.overrideFarmIndex != null
          ? 1
          : context.read<FarmCardReBloc>().userFarmList().length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return BlocBuilder<FarmCardReBloc, FarmCardReState>(
          buildWhen: (previous, current) =>
              previous != current && current.farms.isNotEmpty,
          builder: (context, state) {
            // Data is init
            if (state.farms.isNotEmpty) {
              return farmAsCard(context, state.farms, index, items);
            }

            return const Card(
              elevation: 5.0,
              margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
            );
          },
        );
      },
    );
  }

  // ignore: long-method
  Widget farmAsCard(
    BuildContext context,
    dynamic data,
    int farmIndex, [
    List<ResultItem>? searched,
  ]) {
    return Card(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      elevation: 0,
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /*const Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          ),*/
          BlocBuilder<FarmCardReBloc, FarmCardReState>(
            builder: (context, state) {
              if (state.data != "") {
                if (!dataResponse.contains(state.pt)) {
                  dataResponse.add(state.pt);
                }
              }
              // print("[Response] $dataResponse");
              if (widget.overrideFarmIndex != null && state.farms.isNotEmpty) {
                var farmTarget = state.farms[widget.overrideFarmIndex!];
                // print("[SetBase] ${state.devices}");
                context
                    .read<SearchWidgetBloc>()
                    .add(BaseListChanged(state.devices));
                devices = state.devices;
                tempLoc = farmTarget;
                // print("In farm target, [devices] $devices");

                return Text(
                  'Farm : ' + farmTarget,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                    shadows: <Shadow>[
                      Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 5,
                          color: Colors.orange),
                    ],
                  ),
                );
              } else if (widget.overrideFarmIndex == null &&
                  state.farms.isNotEmpty) {
                var farmTarget = state.farms[farmIndex];
                // print("[SetBase] ${state.devices}");
                context
                    .read<SearchWidgetBloc>()
                    .add(BaseListChanged(state.devices));
                devices = state.devices;
                tempLoc = farmTarget;
                // print("In farm target, [devices] $devices");

                return Text(
                  farmTarget,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }

              return const Text(
                "Loading ... ",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          // const Divider(),
          // if (state.widgetIndex == 1)
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
          ),
          Center(child: generateNumberCards(searched)),
        ],
      ),
    );
  }

// ignore: long-method
  Widget generateNumberCards([List<ResultItem>? searched]) {
    return Container(
      width: MediaQuery.of(context).size.width, //*0.635
      child: Column(
        children: [
          SearchBar(),
          SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //analysisWidget(),
              //historyWidget(),
              analysisWidget_New(),
              historyWidget_New()
            ],
          ),
          SizedBox(
            height: 30,
          ),
          if (dataResponse.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 0),
              child: BlocBuilder<FarmCardReBloc, FarmCardReState>(
                bloc: context.read<FarmCardReBloc>(),
                builder: (context, stateFarm) {
                  // Query by farm
                  var selectedResponse = dataResponse
                      .where((element) => element["FromFarm"] == tempLoc)
                      .toList();
                  // Query by type
                  // Map splDevByType =
                  //     await createNewFarmDataMapForNumCard(selectedResponse);
                  // print(
                  //     "\n\n[Split] ${splDevByType["Farmtest"]["NPKSENSOR"]} \n\n");

                  // Main generator
                  // Caution: dataResponse, selectedResponse
                  if (selectedResponse.isEmpty) {
                    return Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.shade700,
                            blurRadius: 10,
                            offset: Offset(4, 8), // Shadow position
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Center(
                            widthFactor: 1.8,
                            child: Text(
                              "No data found.",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return FutureBuilder(
                    future: Future.delayed(
                      const Duration(
                        milliseconds: 200,
                      ),
                      () {
                        // context.read<FarmCardReBloc>().getDeviceData();

                        return futureCard(
                          selectedResponse,
                          searched,
                        );
                      },
                    ),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Column(
                          children: const [
                            CircularProgressIndicator(),
                            Text("Refreshing ... "),
                          ],
                        ); // Placeholder widget while waiting for the future to complete
                      } else if (snapshot.hasError) {
                        return Text(
                            'Error: ${snapshot.error}'); // Widget to display an error message if the future throws an error
                      } else {
                        return snapshot
                            .data!; // Widget to display when the future completes successfully
                      }
                    },
                  );

                  // return const CircularProgressIndicator();
                },
              ),
            )
          else
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    Text("Loading"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget futureCard(selectedResponse, searched) {
    return FutureBuilder(
      future: createNewFarmDataMapForNumCard(selectedResponse),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          var splDevByType = snapshot.data;

          return Container(
            child: BlocProvider(
              create: (_) => LiveDataCubit(selectedResponse),
              child: BlocBuilder<SearchWidgetBloc, SearchWidgetState>(
                builder: (context, state) {
                  if (state is SearchWidgetSuccess) {
                    return numberCard(
                      inputData: selectedResponse,
                      whichFarm: tempLoc,
                      existedCli: client,
                      devicesData: searched,
                      splByType: splDevByType,
                    );
                  }

                  return numberCard(
                    inputData: selectedResponse,
                    whichFarm: tempLoc,
                    existedCli: client,
                    devicesData: devices,
                    splByType: splDevByType,
                  );
                },
              ),
            ),
          );
        }

        return Container();
      },
    );
  }

  // ignore: long-method
  Widget analysisWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
      // color: Colors.white,
      height: 60,
      // alignment: Alignment.centerLeft,
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.white),
          elevation: MaterialStatePropertyAll(5.0),
        ),
        onPressed: () {
          List deviceCheck = [];

          for (var d in devices) {
            if (d["Location"] == tempLoc) {
              deviceCheck.add(d);
            }
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisPage(
                devices: deviceCheck,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.analytics_outlined, color: Colors.black),
            Text("Analysis", style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget historyWidget() {
    return Container(
      margin: const EdgeInsets.fromLTRB(5.0, 20.0, 5.0, 0.0),
      height: 60,
      width: MediaQuery.of(context).size.width * 0.45,
      child: ElevatedButton(
        style: const ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(Colors.white),
          elevation: MaterialStatePropertyAll(5.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wysiwyg, color: Colors.black),
            Text("History", style: TextStyle(color: Colors.black)),
          ],
        ),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            constraints: const BoxConstraints(),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
            ),
            child: historyLog(farmName: tempLoc),
          ),
        ),
      ),
    );
  }

  Widget analysisWidget_New() {
    return Container(
      height: 50,
      width: 200,
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade600,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade700,
            blurRadius: 10,
            offset: Offset(4, 8), // Shadow position
          ),
        ],
      ),
      child: Center(
          child: TextButton(
        onPressed: () {
          List deviceCheck = [];

          for (var d in devices) {
            if (d["Location"] == tempLoc) {
              deviceCheck.add(d);
            }
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AnalysisPage(
                devices: deviceCheck,
              ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Analysis',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
            SizedBox(
              width: 15,
            ),
            Icon(Icons.auto_graph, size: 22, color: Colors.white),
          ],
        ),
      )),
    );
  }

  Widget historyWidget_New() {
    return Container(
      height: 50,
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade700,
            blurRadius: 10,
            offset: Offset(4, 8), // Shadow position
          ),
        ],
      ),
      child: Center(
          child: TextButton(
              onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(
                      height: MediaQuery.of(context).size.height * 0.85,
                      constraints: const BoxConstraints(),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25),
                        ),
                      ),
                      child: historyLog(farmName: tempLoc),
                    ),
                  ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'History',
                    style: TextStyle(fontSize: 16, color: Colors.orange),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Icon(Icons.history, size: 19, color: Colors.orange),
                ],
              ))),
    );
  }
}
