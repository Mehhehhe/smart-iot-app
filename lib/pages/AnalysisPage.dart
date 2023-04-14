import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/modules/native_call.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

List<Color> palette = [
  const Color.fromRGBO(208, 31, 49, 1.0),
  const Color.fromRGBO(246, 129, 33, 1.0),
  const Color.fromRGBO(251, 221, 11, 1.0),
  const Color.fromRGBO(0, 123, 97, 1.0),
  const Color.fromRGBO(0, 114, 185, 1.0),
];

class AnalysisPage extends StatefulWidget {
  final List devices;

  const AnalysisPage({Key? key, required this.devices}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnalysisPage();
}

class _AnalysisPage extends State<AnalysisPage> {
  // raw data fetcher
  late LocalHistoryDatabase instance;
  String selectDevice = "";

  // Indicators
  static const List<Widget> movingAverageRangeSelector = <Widget>[
    Text("5"),
    Text("10"),
    Text("15"),
    Text("20"),
  ];
  static const List<String> availableIndicators = ["sma", "ema"];
  // TODO: implement each device's own settings of indicator
  // give each one, default setting like in the history page.
  Map<String, dynamic> indicatorsSetMap = {};
  bool enableSma = false;
  bool enableEma = false;

  static const List<Tab> analyzeTab = <Tab>[
    Tab(
      text: "Indicators",
    ),
    Tab(
      text: "Report",
    ),
  ];

  // Function 1: Fetch database of a device
  // Function 2: For each data, transform with toJson(), then List<Map> to List<ChartData>
  Future<List<ChartData>> _addBase({required String deviceName}) async {
    List<LocalHist> base = await instance.getHistoryOf(device: deviceName);
    // create List<ChartData>

    // replace this with device type checker.
    Type baseVal = base[0].device.contains("MOIST")
        ? num
        : base[0].device.contains("NPK")
            ? Map
            : String;
    List<ChartData> temp = [];
    dynamic valueToSet;
    for (var b in base) {
      // print("State: ${b.value}, ${b.value.runtimeType}");
      switch (baseVal) {
        case Map:
          // print("[BaseVal] map case:=> ${b.value}, ${b.value.runtimeType}");
          if (!b.value.contains('"')) {
            final modifiedString = b.value.replaceAllMapped(
              RegExp(r'([A-Za-z]+)(\s*:)', multiLine: true),
              (match) => '"${match.group(1)}"${match.group(2)}',
            );
            valueToSet = jsonDecode(modifiedString);
            // print("Modified and get $valueToSet");
          } else {
            valueToSet = json.decode(b.value);
          }

          break;
        case num:
          // print("[BaseVal] double case:=> ${b.value}, ${b.value.runtimeType}");
          valueToSet = num.parse(b.value == "null" ? "-1.0" : b.value);
          // print("Num parsed and get $valueToSet");
          break;
        default:
          break;
      }
      temp.add(ChartData(
        DateTime.fromMillisecondsSinceEpoch(int.parse(b.dateUnixAsId)),
        [valueToSet],
        b.farm,
        name: baseVal == Map ? "NPK" : null,
      ));
    }
    // print("Cleaned & get $temp");

    return temp;
  }

  // Function 3: Use the same functions with detail's page of graph creation.
  Future<Map<String, dynamic>> _lineSeries(String device) async {
    List<LineSeries<ChartData, DateTime>> temp =
        <LineSeries<ChartData, DateTime>>[];
    List<String> places = [];
    // add base here
    List<ChartData> base = await _addBase(deviceName: device);
    List<ChartData> newDataList = [];
    newDataList.addAll(base);
    // newDataList.addAll(data);
    newDataList.sort(
      (a, b) => b.date.compareTo(a.date),
    );
    // print("[base] $base");
    // Find all devices
    for (var elm in newDataList) {
      // print("Prepare data ${elm.place}, ${elm.values}");
      if (!places.contains(elm.place)) {
        places.add(elm.place);
      }
    }
    // Seperate data for each devices
    for (var plc in places) {
      List<ChartData> tempArr = [];
      for (var chrt in newDataList) {
        if (chrt.place == plc) {
          tempArr.add(chrt);
        }
      }
      if (newDataList[0].name == null) {
        temp.add(_createSeries(tempArr, ""));
      } else if (newDataList[0].name!.contains("NPK")) {
        // single device, multi values
        temp.add(_createSeries(tempArr, "N"));
        temp.add(_createSeries(tempArr, "P"));
        temp.add(_createSeries(tempArr, "K"));
      }

      tempArr = [];
    }

    // print("[AddAll map] $temp");
    // print("[TestEx] ${temp[0].dataSource[0]}");

    return {
      "series": temp,
      "start": newDataList.first.date.toLocal(),
      "end": newDataList.last.date.toLocal(),
    };
  }

  LineSeries<ChartData, DateTime> _createSeries(
    List<ChartData> tempArr,
    String name,
  ) {
    // print("[create] $name");

    return LineSeries(
      name: name,
      dataSource: tempArr,
      enableTooltip: true,
      xValueMapper: (datum, index) => datum.date,
      yValueMapper: (datum, index) {
        // print("datum accesses ${datum.date}, ${datum.values[0].keys}");
        if (name == "") {
          return datum.values[0];
        }

        return datum.values[0][name];
      },
    );
  }

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
    print("[Ana] ${widget.devices}");
    print("[NativeCall] complete!~ get ${RustNativeCall().test_neural}");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: analyzeTab.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(tabs: analyzeTab),
        ),
        body: TabBarView(
          children: analyzeTab.map((e) {
            final String label = e.text!.toLowerCase();
            switch (label) {
              case "indicators":
                return indicatorsTab();
              case "report":
                return FutureBuilder(
                  future: RustNativeCall().test_neural,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List data = snapshot.data! as List;

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(data[index].toString()),
                          );
                        },
                      );
                    }

                    return Container();
                  },
                );
              default:
            }

            return Center(
              child: Text(label),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ListView components

  Widget indicatorsTab() {
    return ListView(
      shrinkWrap: true,
      children: [
        graphScreen(),
        deviceAvgSelector(),
        indicatorsInput(name: selectDevice),
      ],
    );
  }

  Widget graphScreen() {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width * 0.8,
      child: FutureBuilder(
        future: _lineSeries(selectDevice),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> fetchedMap =
                snapshot.data! as Map<String, dynamic>;
            dynamic ls = fetchedMap["series"];

            return _buildLineChart(ls: ls);
          }

          return const Center(
            child: Text("No graph available"),
          );
        },
      ),
    );
  }

  Widget deviceAvgSelector() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      width: MediaQuery.of(context).size.width * 0.8,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        shrinkWrap: true,
        itemCount: widget.devices.length,
        itemBuilder: (context, index) {
          // Build tile with average in it
          String name = widget.devices[index]["DeviceName"];

          return Card(
            child: InkWell(
              child: Text(name),
              onTap: () => setState(() {
                selectDevice = name;
              }),
            ),
          );
        },
      ),
    );
  }

  // ignore: long-method
  Widget indicatorsInput({required String name}) {
    List<Widget> lts = [];
    Map<String, dynamic> temp = {
      name: {
        "indicators": [],
        "sma": {
          "range": [],
          "bools": [false, false, false, false],
        },
        "ema": {
          "range": [],
          "bools": [false, false, false, false],
        },
      },
    };
    if (!indicatorsSetMap.containsKey(name)) {
      indicatorsSetMap.addEntries(temp.entries);
    }
    for (String i in indicatorsSetMap[name]["indicators"]) {
      switch (i) {
        case "sma":
          // Safety >.0
          if (!enableSma) {
            break;
          }
          lts.add(ListTile(
            onLongPress: () => showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Delete"),
                  content: Text(
                      "SMA; Simple Moving Average will disappear from the graph. You can still add it back later."),
                  actions: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          indicatorsSetMap[name]["indicators"].remove("sma");
                          enableSma = false;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("OK"),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                  ],
                );
              },
            ),
            title: Text("Simple Moving Average"),
            subtitle: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Choose a range"),
                    ToggleButtons(
                      onPressed: (index) {
                        setState(() {
                          indicatorsSetMap[name]["sma"]["bools"][index] =
                              !indicatorsSetMap[name]["sma"]["bools"][index];
                        });
                      },
                      isSelected: indicatorsSetMap[name]["sma"]["bools"],
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      selectedBorderColor: Colors.green[700],
                      selectedColor: Colors.white,
                      fillColor: Colors.green[200],
                      color: Colors.green[400],
                      children: movingAverageRangeSelector,
                    ),
                  ],
                ),
                Text("Press & Hold to remove this indicator"),
              ],
            ),
          ));
          break;
        default:
      }
    }

    return ListView(
      shrinkWrap: true,
      children: [
        ...lts,
        ListTile(
          title: const Icon(Icons.add),
          onTap: () => showModalBottomSheet(
            context: context,
            builder: (context) => ListView.builder(
              itemCount: availableIndicators.length,
              itemBuilder: (context, index) => ExpansionTile(
                title: Text(availableIndicators[index]),
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        indicatorsSetMap[selectDevice]["indicators"]
                            .add(availableIndicators[index]);
                        enableSma = true;
                      });
                    },
                    child: Row(
                      children: const [Icon(Icons.add), Text("Choose")],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  SfCartesianChart _buildLineChart({
    required dynamic ls,
  }) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      backgroundColor: Colors.white,
      plotAreaBackgroundColor: Colors.white54,
      palette: palette,
      plotAreaBorderColor: Colors.grey,
      primaryXAxis: DateTimeAxis(
        enableAutoIntervalOnZooming: true,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: ls,
      tooltipBehavior: TooltipBehavior(
        enable: true,
        elevation: 5,
        canShowMarker: false,
        activationMode: ActivationMode.singleTap,
        shared: true,
        header: "Sensor Value",
        format: 'ณ point.x, ค่า: point.y',
        decimalPlaces: 2,
        textStyle: const TextStyle(fontSize: 16.0),
      ),
      trackballBehavior: TrackballBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
        shouldAlwaysShow: true,
        tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
        tooltipSettings: const InteractiveTooltip(enable: false),
        markerSettings: const TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.hidden,
        ),
      ),
    );
  }
}
