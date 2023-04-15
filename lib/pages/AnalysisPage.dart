import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/modules/native_call.dart';
import 'package:smart_iot_app/src/native/bridge_definitions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

List<Color> palette = [
  const Color.fromRGBO(208, 31, 49, 1.0),
  const Color.fromRGBO(0, 123, 97, 1.0),
  const Color.fromRGBO(0, 114, 185, 1.0),
  Colors.deepOrange,
  Colors.deepPurple,
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
    Text("25"),
    Text("50"),
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

  List<LocalHist> cleanNull({required List<LocalHist> h}) {
    List<LocalHist> cleaned = [];
    for (var hist in h) {
      if (hist.value != "null") {
        cleaned.add(hist);
      }
    }

    return cleaned;
  }

  // Function 1: Fetch database of a device
  // Function 2: For each data, transform with toJson(), then List<Map> to List<ChartData>
  // ignore: long-method
  Future<dynamic> _addBase({required String deviceName}) async {
    List<LocalHist> baseUncleaned =
        await instance.getHistoryOf(device: deviceName);
    List<LocalHist> base = cleanNull(h: baseUncleaned);
    // For each indicators enabled by user
    List<MaReturnTypes>? sma;
    List? ema;
    DateTime? smaStart;
    DateTime? emaStart;
    int smaDiff = 0;
    int emaDiff = 0;
    List<ChartData> smaLines = [];
    List<ChartData> emaLines = [];

    if (indicatorsSetMap[selectDevice]["indicators"].contains("sma")) {
      print("Activate sma for $deviceName");
      sma = await RustNativeCall().calculateSMA(
        hist: RustNativeCall().generateVec(
          hist: base,
          multiValue: deviceName.contains("NPK") ? true : false,
        ),
        window_size: int.parse(indicatorsSetMap[selectDevice]["sma"]["range"]),
      );
      print("Base length: ${base.length}");
      smaDiff = base.length - sma.length + 1;

      smaStart = DateTime.fromMillisecondsSinceEpoch(int.parse(
        base[base.length -
                int.parse(indicatorsSetMap[selectDevice]["sma"]["range"]) +
                1]
            .dateUnixAsId,
      ));
      print("[SMA] processing on start date $sma");
      int count = 0;
      // int pivot = int.parse(base[smaDiff].dateUnixAsId);
      List smaField0List = [];
      // List smaField0List = sma.map(
      //   single: (value) => value.field0,
      //   triple: (value) => [
      //     {
      //       "N": value.field0.nVec,
      //       "P": value.field0.pVec,
      //       "K": value.field0.kVec,
      //     },
      //   ],
      // ).toList();
      smaField0List = deviceName.contains("NPK")
          ? sma[1].map(
              single: (value) => value.field0,
              triple: (value) => [
                {
                  "N": value.field0.nVec,
                  "P": value.field0.pVec,
                  "K": value.field0.kVec,
                },
              ],
            )
          : sma[0].map(
              single: (value) => value.field0,
              triple: (value) => [
                {
                  "N": value.field0.nVec,
                  "P": value.field0.pVec,
                  "K": value.field0.kVec,
                },
              ],
            );
      // print(smaField0List);
      base.sort(
        (a, b) => DateTime.fromMillisecondsSinceEpoch(int.parse(a.dateUnixAsId))
            .compareTo(
          DateTime.fromMillisecondsSinceEpoch(
            int.parse(b.dateUnixAsId),
          ),
        ),
      );
      int smaLen = deviceName.contains("NPK")
          ? smaField0List[0]["N"].length
          : smaField0List.length;
      print(
          "Diff len ${smaField0List[0].length} , ${smaField0List[0]["N"].length}");
      for (var h in base) {
        int curr = int.parse(h.dateUnixAsId);
        DateTime currDate = DateTime.fromMillisecondsSinceEpoch(curr);
        // print(
        //     "[SMA - Loop] current is @ ${DateTime.fromMillisecondsSinceEpoch(curr)} counting $count, diff: ${smaField0List.length - count}");
        // print(smaField0List[0]["N"][count]);
        if ((currDate == smaStart || currDate.isAfter(smaStart)) &&
            count < smaLen) {
          // print(
          //     "[SMA - LoopPassCond] current is @ ${DateTime.fromMillisecondsSinceEpoch(curr)}, check cond:=> ${DateTime.fromMillisecondsSinceEpoch(curr).isAfter(smaStart)} counting $count, diff: ${smaField0List.length - count}");
          smaLines.add(ChartData(
            DateTime.fromMillisecondsSinceEpoch(curr),
            [
              deviceName.contains("NPK")
                  ? {
                      "N": smaField0List[0]["N"][count],
                      "P": smaField0List[0]["P"][count],
                      "K": smaField0List[0]["K"][count],
                    }
                  : smaField0List[count],
            ],
            "",
          ));
          // print("Counting $count");
          count++;
        }
      }
      print("Done! smaLines = $smaLines");
    }

    // replace this with device type checker.
    Type baseVal = base[0].device.contains("MOIST")
        ? num
        : base[0].device.contains("NPK")
            ? Map
            : String;
    List<ChartData> temp = [];
    dynamic valueToSet;
    // print("Start Loop");
    int countNull = 0;
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
          if (b.value == "null") {
            countNull++;
            break;
          }
          // print("[BaseVal] double case:=> ${b.value}, ${b.value.runtimeType}");
          valueToSet = num.parse(b.value);
          // print("Num parsed and get $valueToSet");
          break;
        default:
          break;
      }
      temp.add(ChartData(
        DateTime.fromMillisecondsSinceEpoch(int.parse(b.dateUnixAsId)),
        [valueToSet],
        b.farm,
        name: deviceName,
      ));
    }
    print("Cleaned & get ${temp.length} , deleted $countNull");
    // print("Before return: check indicator lines $smaLines");

    return {
      "base": temp,
      "sma": smaLines,
      "ema": emaLines,
    };
  }

  // Function 3: Use the same functions with detail's page of graph creation.
  // ignore: long-method
  Future<Map<String, dynamic>> _lineSeries(String device) async {
    List<LineSeries<ChartData, DateTime>> temp =
        <LineSeries<ChartData, DateTime>>[];
    List<String> places = [];
    // add base here
    dynamic base = await _addBase(deviceName: device);

    List<ChartData> newDataList = [];
    newDataList.addAll(base["base"]);
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
        temp.add(_createSeries(tempArr, "N", multiValue: true));
        temp.add(_createSeries(tempArr, "P", multiValue: true));
        temp.add(_createSeries(tempArr, "K", multiValue: true));
      } else {
        temp.add(_createSeries(tempArr, device));
      }

      tempArr = [];
    }
    // print("Adding indicators ... ");
    if (base["sma"].isNotEmpty) {
      // print("Add sma");
      if (newDataList[0].name!.contains("NPK")) {
        temp.add(_createSeries(
          base["sma"],
          "N sma",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(_createSeries(
          base["sma"],
          "P sma",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(_createSeries(
          base["sma"],
          "K sma",
          isIndicator: true,
          multiValue: true,
        ));
      } else {
        temp.add(_createSeries(base["sma"], "sma", isIndicator: true));
      }
    }
    if (base["ema"].isNotEmpty) {
      temp.add(_createSeries(base["ema"], "ema", isIndicator: true));
    }

    // print("[AddAll map] $temp");
    // print("[TestEx] ${temp[0].dataSource[0]}");

    return {
      "series": temp,
    };
  }

  LineSeries<ChartData, DateTime> _createSeries(
    List<ChartData> tempArr,
    String name, {
    bool isIndicator = false,
    bool multiValue = false,
  }) {
    // print("[create] $name");

    return LineSeries(
      name: name,
      dataSource: tempArr,
      opacity: isIndicator ? 0.8 : 1,
      legendIconType: LegendIconType.circle,
      legendItemText: name,
      // enableTooltip: true,
      isVisibleInLegend: true,
      xValueMapper: (datum, index) => datum.date,
      yValueMapper: (datum, index) {
        // print("datum accesses ${datum.date}, ${datum.values[0].keys}");
        if (name == "") {
          return datum.values[0];
        } else if (!multiValue) {
          return datum.values[0];
        } else if (isIndicator && !multiValue) {
          return datum.values[0];
        }
        // print("Return mapper value $name => ${datum.values[0][name]}");

        return datum.values[0][name.characters.first];
      },
      trendlines: !multiValue
          ? [
              Trendline(
                  isVisible: true, opacity: 0.2, isVisibleInLegend: false),
            ]
          : [],
    );
  }

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
    // print("[Ana] ${widget.devices}");
    // print("[NativeCall] complete!~ get ${RustNativeCall().test_neural}");
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
            print("[FetchGraph] ${ls.length}");

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
          "range": "5",
          "bools": [true, false, false, false],
        },
        "ema": {
          "range": "5",
          "bools": [true, false, false, false],
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
          // if (!enableSma) {
          //   break;
          // }
          if (!indicatorsSetMap[selectDevice]["indicators"].contains("sma")) {
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
                          for (int i = 0;
                              i < indicatorsSetMap[name]["sma"]["bools"].length;
                              i++) {
                            indicatorsSetMap[name]["sma"]["bools"][i] =
                                i == index;
                          }
                          indicatorsSetMap[name]["sma"]["range"] =
                              movingAverageRangeSelector[index]
                                  .toString()
                                  .substring(
                                    6,
                                    movingAverageRangeSelector[index]
                                            .toString()
                                            .length -
                                        2,
                                  );
                          // indicatorsSetMap[name]["sma"]["bools"][index] =
                          //     !indicatorsSetMap[name]["sma"]["bools"][index];
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
      legend: Legend(isVisible: true),
      primaryXAxis: DateTimeAxis(
        enableAutoIntervalOnZooming: true,
        intervalType: DateTimeIntervalType.days,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: ls,
      tooltipBehavior: TooltipBehavior(
        enable: true,
        elevation: 5,
        canShowMarker: true,
        activationMode: ActivationMode.singleTap,
        shared: false,
        header: "Sensor Value",
        format: 'ณ point.x, ค่า: point.y',
        decimalPlaces: 2,
        textStyle: const TextStyle(fontSize: 16.0),
      ),
      trackballBehavior: TrackballBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
        shouldAlwaysShow: true,
        tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
        tooltipSettings: const InteractiveTooltip(enable: false),
        markerSettings: const TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.hidden,
        ),
      ),
      zoomPanBehavior: ZoomPanBehavior(
        zoomMode: ZoomMode.x,
        maximumZoomLevel: 0.2,
        enableMouseWheelZooming: true,
        enablePinching: true,
        enablePanning: true,
      ),
    );
  }
}
