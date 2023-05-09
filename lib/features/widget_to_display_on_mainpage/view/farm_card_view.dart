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

  createNewFarmDataMapForNumCard(List s) {
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
              ss["FromDevice"].contains(value[t]["prefix"])) {
            if (value[t]["data"].isEmpty) {
              // print("is ss string? ${json.decode(ss)["Data"].runtimeType}, ");
              if (ss["Data"].runtimeType == String) {
                ss["Data"] = json.decode(ss["Data"]);
              }
              value[t]["data"].add(ss);
              break;
            }

            // print(
            //     "check condition :=> ${temp.containsKey(ss["FromFarm"])}, ${ss["FromDevice"].contains(value[t]["prefix"])}, ${!value[t]["data"].contains(ss)} , \n\n\nvalue = ${value[t]["data"]}");
            List temp = [];
            for (int i = 0; i < value[t]["data"].length; i++) {
              if (value[t]["data"][i]["FromDevice"] == ss["FromDevice"]) {
                temp.addAll(
                  ss["Data"].runtimeType == String
                      ? json.decode(ss["Data"])
                      : ss["Data"],
                );
              }
            }
            if (temp.isNotEmpty) {
              value[t]["data"].addAll(temp);
            }
          }
        }
      });
    }

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
        child: Column(
          children: [
           //hello world im tired.
            SearchBar(),
            const SizedBox(
              height: 20,
            ),
            SearchBody(),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                analysisWidget(),
                historyWidget(),
              ],
            ),
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
      elevation: 5.0,
      color: Colors.brown.shade100,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
          ),
          BlocBuilder<FarmCardReBloc, FarmCardReState>(
            builder: (context, state) {
              if (state.data != "") {
                if (!dataResponse.contains(state.data)) {
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
                  farmTarget,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
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
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
          ),
          generateNumberCards(searched),
          const Padding(
            padding: EdgeInsets.fromLTRB(0, 25, 0, 0),
          ),
        ],
      ),
    );
  }

// ignore: long-method
  Widget generateNumberCards([List<ResultItem>? searched]) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          if (dataResponse.isNotEmpty)
            BlocBuilder<FarmCardReBloc, FarmCardReState>(
              bloc: context.read<FarmCardReBloc>(),
              builder: (context, stateFarm) {
                // Query by farm
                var selectedResponse = dataResponse
                    .where((element) => element["FromFarm"] == tempLoc)
                    .toList();
                // Query by type
                var splDevByType =
                    createNewFarmDataMapForNumCard(selectedResponse);

                // Main generator
                // Caution: dataResponse, selectedResponse
                if (selectedResponse.isEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Center(
                        widthFactor: 1.8,
                        child: Text(
                          "No data found on this farm.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  );
                }

                return BlocProvider(
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
                );
              },
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
}
