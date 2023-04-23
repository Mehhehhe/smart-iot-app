// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/report_in_pdf.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/model/ReportModel.dart';
import 'package:smart_iot_app/pages/AnalysisSub.dart';
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

  // Section for report
  late Uint8List _imageFile;
  ScreenshotController screenshotController = ScreenshotController();
  List<String> graphImgPaths = [];

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
  Future<dynamic> addBase({required String deviceName}) async {
    List<LocalHist> baseUncleaned =
        await instance.getHistoryOf(device: deviceName);
    List<LocalHist> base = cleanNull(h: baseUncleaned);
    // For each indicators enabled by user
    List<ChartData> smaLines = [];
    List<ChartData> emaLines = [];

    if (indicatorsSetMap[selectDevice]["indicators"].contains("sma")) {
      smaLines = await indicatorOnAdd(
        deviceName: deviceName,
        whatIndicator: "sma",
        range: indicatorsSetMap[selectDevice]["sma"]["range"],
        base: base,
      );
    }

    if (indicatorsSetMap[selectDevice]["indicators"].contains("ema")) {
      // print("Activate sma for $deviceName");
      emaLines = await indicatorOnAdd(
        deviceName: deviceName,
        whatIndicator: "ema",
        range: indicatorsSetMap[selectDevice]["sma"]["range"],
        base: base,
      );
    }

    // replace this with device type checker.
    Type baseVal = base[0].device.contains("MOIST")
        ? num
        : base[0].device.contains("NPK")
            ? Map
            : String;
    List<ChartData> temp = [];
    dynamic valueToSet;
    int countNull = 0;
    for (var b in base) {
      switch (baseVal) {
        case Map:
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
          valueToSet = num.parse(b.value);
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

    return {
      "base": temp,
      "sma": smaLines,
      "ema": emaLines,
    };
  }

  // Function 3: Use the same functions with detail's page of graph creation.
  // ignore: long-method
  Future<Map<String, dynamic>> lineSeries(String device) async {
    List<LineSeries<ChartData, DateTime>> temp =
        <LineSeries<ChartData, DateTime>>[];
    List<String> places = [];
    // add base here
    dynamic base = await addBase(deviceName: device);

    List<ChartData> newDataList = [];
    newDataList.addAll(base["base"]);
    newDataList.sort(
      (a, b) => b.date.compareTo(a.date),
    );
    for (var elm in newDataList) {
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
        temp.add(createSeries(tempArr, ""));
      } else if (newDataList[0].name!.contains("NPK")) {
        // single device, multi values
        temp.add(createSeries(tempArr, "N", multiValue: true));
        temp.add(createSeries(tempArr, "P", multiValue: true));
        temp.add(createSeries(tempArr, "K", multiValue: true));
      } else {
        temp.add(createSeries(tempArr, device));
      }

      tempArr = [];
    }
    // print("Adding indicators ... ");
    if (base["sma"].isNotEmpty) {
      // print("Add sma");
      if (newDataList[0].name!.contains("NPK")) {
        temp.add(createSeries(
          base["sma"],
          "N sma",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(createSeries(
          base["sma"],
          "P sma",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(createSeries(
          base["sma"],
          "K sma",
          isIndicator: true,
          multiValue: true,
        ));
      } else {
        temp.add(createSeries(base["sma"], "sma", isIndicator: true));
      }
    }
    if (base["ema"].isNotEmpty) {
      // print("Add sma");
      if (newDataList[0].name!.contains("NPK")) {
        temp.add(createSeries(
          base["ema"],
          "N ema",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(createSeries(
          base["ema"],
          "P ema",
          isIndicator: true,
          multiValue: true,
        ));
        temp.add(createSeries(
          base["ema"],
          "K ema",
          isIndicator: true,
          multiValue: true,
        ));
      } else {
        temp.add(createSeries(base["ema"], "ema", isIndicator: true));
      }
    }

    return {
      "series": temp,
    };
  }

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
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
                if (widget.devices.isEmpty || selectDevice == "") {
                  return const Center(
                    child: Text("No data available"),
                  );
                }
                return Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportPreview(
                              reportCard: ReportCard(
                                widget.devices[0]["Location"],
                                widget.devices,
                                graphImgPaths,
                                // "",
                              ),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Make",
                        ),
                      ),
                    ],
                  ),
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
        if (widget.devices.isNotEmpty)
          TextButton(
            onPressed: () => setState(() {
              indicatorsSetMap[selectDevice]["legend"] =
                  !indicatorsSetMap[selectDevice]["legend"];
            }),
            child: const Text("Toggle Legend"),
          ),
        if (widget.devices.isNotEmpty)
          Container(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () async => await screenshotController
                  .capture(delay: Duration(milliseconds: 10))
                  .then((value) async {
                // print(value);
                if (value != null) {
                  final directory = await getApplicationDocumentsDirectory();
                  final imagePath = await File(
                          '${directory.path}/$selectDevice${DateTime.now().millisecondsSinceEpoch}.jpeg')
                      .create();
                  await imagePath.writeAsBytes(value);

                  graphImgPaths.add(imagePath.path);
                }
              }),
              child: const Text("Export graph as jpeg"),
            ),
          ),
        if (widget.devices.isNotEmpty) deviceAvgSelector(),
        if (widget.devices.isNotEmpty) indicatorsInput(name: selectDevice),
      ],
    );
  }

  Widget graphScreen() {
    return Container(
      height: 300,
      width: MediaQuery.of(context).size.width * 0.8,
      child: FutureBuilder(
        future: lineSeries(selectDevice),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Map<String, dynamic> fetchedMap =
                snapshot.data! as Map<String, dynamic>;
            dynamic ls = fetchedMap["series"];

            // Wrap this in Screenshot
            return Screenshot(
              controller: screenshotController,
              child: _buildLineChart(ls: ls),
            );
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
      height: 100,
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

          return Container(
            height: 50,
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

  Widget indicatorsInput({required String name}) {
    List<Widget> lts = [];
    dynamic temp = {
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
        "legend": true,
      },
    };
    if (!indicatorsSetMap.containsKey(name)) {
      indicatorsSetMap.addEntries(temp.entries);
    }
    for (String i in indicatorsSetMap[name]["indicators"]) {
      switch (i) {
        case "sma":
          if (!indicatorsSetMap[selectDevice]["indicators"].contains("sma")) {
            break;
          }
          lts.add(_indicatorTile(
            whatIndicator: "sma",
            textOnDelete:
                "SMA; Simple Moving Average will disappear from the graph. You can still add it back later.",
            deviceName: name,
            indicatorFullName: "Simple Moving Average",
          ));
          break;
        case "ema":
          if (!indicatorsSetMap[selectDevice]["indicators"].contains("ema")) {
            break;
          }
          lts.add(_indicatorTile(
            whatIndicator: "ema",
            textOnDelete:
                "EMA; Exponential Moving Average will disappear from the graph. You can still add it back later.",
            deviceName: name,
            indicatorFullName: "Exponential Moving Average",
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
              itemBuilder: (context, index) => _indicatorChoose(index),
            ),
          ),
        ),
      ],
    );
  }

  Widget _indicatorChoose(index) {
    return ExpansionTile(
      title: Text(availableIndicators[index].toUpperCase()),
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() {
              indicatorsSetMap[selectDevice]["indicators"]
                  .add(availableIndicators[index]);
              // enableSma = true;
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: const [Icon(Icons.add), Text("Choose")],
          ),
        ),
      ],
    );
  }

  Widget _indicatorTile({
    required String whatIndicator,
    required String textOnDelete,
    required String deviceName,
    required String indicatorFullName,
  }) {
    return ListTile(
      onLongPress: () => showDialog(
        context: context,
        builder: (context) {
          return _indicatorTileDelDialog(
            context: context,
            deviceName: deviceName,
            whatIndicator: whatIndicator,
            textOnDelete: textOnDelete,
          );
        },
      ),
      title: Text(indicatorFullName),
      subtitle: _indicatorTileSettings(
        deviceName: deviceName,
        whatIndicator: whatIndicator,
      ),
    );
  }

  Widget _indicatorTileDelDialog({
    required BuildContext context,
    required String deviceName,
    required String whatIndicator,
    required String textOnDelete,
  }) {
    return AlertDialog(
      title: const Text("Delete"),
      content: Text(textOnDelete),
      actions: [
        TextButton(
          onPressed: () {
            setState(() {
              indicatorsSetMap[deviceName]["indicators"].remove(whatIndicator);
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
  }

  Widget _indicatorTileSettings({
    required String deviceName,
    required String whatIndicator,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Choose a range"),
            ToggleButtons(
              onPressed: (index) {
                setState(() {
                  for (int i = 0;
                      i <
                          indicatorsSetMap[deviceName][whatIndicator]["bools"]
                              .length;
                      i++) {
                    indicatorsSetMap[deviceName][whatIndicator]["bools"][i] =
                        i == index;
                  }
                  indicatorsSetMap[deviceName][whatIndicator]["range"] =
                      movingAverageRangeSelector[index].toString().substring(
                            6,
                            movingAverageRangeSelector[index]
                                    .toString()
                                    .length -
                                2,
                          );
                });
              },
              isSelected: indicatorsSetMap[deviceName][whatIndicator]["bools"],
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.green[700],
              selectedColor: Colors.white,
              fillColor: Colors.green[200],
              color: Colors.green[400],
              children: movingAverageRangeSelector,
            ),
          ],
        ),
        const Text("Press & Hold to remove this indicator"),
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
      legend: Legend(isVisible: indicatorsSetMap[selectDevice]["legend"]),
      primaryXAxis: DateTimeAxis(
        enableAutoIntervalOnZooming: true,
        intervalType: DateTimeIntervalType.days,
      ),
      primaryYAxis: NumericAxis(
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: ls,
      tooltipBehavior: GraphSettings().tooltip(),
      trackballBehavior: GraphSettings().trackball(),
      zoomPanBehavior: GraphSettings().zoom(),
    );
  }
}
