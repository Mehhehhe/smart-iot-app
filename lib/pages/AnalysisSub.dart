// ignore: file_names
import 'package:flutter/material.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
import 'package:smart_iot_app/modules/native_call.dart';
import 'package:smart_iot_app/src/native/bridge_definitions.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

Map<String, dynamic> getIndicatorTemplate(name) => {
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

LineSeries<ChartData, DateTime> createSeries(
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
    trendlines: (!multiValue && !isIndicator)
        ? [
            Trendline(
              isVisible: true,
              opacity: 0.2,
              isVisibleInLegend: false,
            ),
          ]
        : [],
  );
}

List<LocalHist> cleanNull({required List<LocalHist> h}) {
  List<LocalHist> cleaned = [];
  for (var hist in h) {
    if (hist.value != "null") {
      cleaned.add(hist);
    }
  }

  return cleaned;
}

indicatorOnAdd({
  required String deviceName,
  required String whatIndicator,
  required String range,
  required List<LocalHist> base,
}) async {
  List<MaReturnTypes>? ind = whatIndicator == "sma"
      ? await RustNativeCall().calculateSMA(
          hist: RustNativeCall().generateVec(
            hist: base,
            multiValue: deviceName.contains("NPK") ? true : false,
          ),
          window_size: int.parse(range),
        )
      : whatIndicator == "ema"
          ? await RustNativeCall().calculateEMA(
              hist: RustNativeCall().generateVec(
                hist: base,
                multiValue: deviceName.contains("NPK") ? true : false,
              ),
              period: int.parse(range),
            )
          : [];

  DateTime indStart = DateTime.fromMillisecondsSinceEpoch(int.parse(
    base[base.length - int.parse(range) + 1].dateUnixAsId,
  ));
  List indField0List = deviceName.contains("NPK")
      ? ind[1].map(
          single: (value) => value.field0,
          triple: (value) => [
            {
              "N": value.field0.nVec,
              "P": value.field0.pVec,
              "K": value.field0.kVec,
            },
          ],
        )
      : ind[0].map(
          single: (value) => value.field0,
          triple: (value) => [
            {
              "N": value.field0.nVec,
              "P": value.field0.pVec,
              "K": value.field0.kVec,
            },
          ],
        );

  base.sort(
    (a, b) => DateTime.fromMillisecondsSinceEpoch(int.parse(a.dateUnixAsId))
        .compareTo(
      DateTime.fromMillisecondsSinceEpoch(
        int.parse(b.dateUnixAsId),
      ),
    ),
  );

  return _addingLoop(base, indStart, deviceName, indField0List);
}

_addingLoop(base, indStart, deviceName, indField0List) {
  int count = 0;
  List<ChartData> indLines = [];
  int indLen = deviceName.contains("NPK")
      ? indField0List[0]["N"].length
      : indField0List.length;
  for (var h in base) {
    int curr = int.parse(h.dateUnixAsId);
    DateTime currDate = DateTime.fromMillisecondsSinceEpoch(curr);
    if ((currDate == indStart || currDate.isAfter(indStart)) &&
        count < indLen) {
      indLines.add(ChartData(
        DateTime.fromMillisecondsSinceEpoch(curr),
        [
          deviceName.contains("NPK")
              ? {
                  "N": indField0List[0]["N"][count],
                  "P": indField0List[0]["P"][count],
                  "K": indField0List[0]["K"][count],
                }
              : indField0List[count],
        ],
        "",
      ));
      count++;
    }
  }

  return indLines;
}

getAvgDisplay(instance, deviceName) async {
  List<LocalHist> baseUncleaned =
      await instance.getHistoryOf(device: deviceName);
  List<LocalHist> base = cleanNull(h: baseUncleaned);
  List<MaReturnTypes>? avgMa = await RustNativeCall().staticAvg(
    hist: RustNativeCall().generateVec(
      hist: base,
      multiValue: deviceName.contains("NPK") ? true : false,
    ),
  );

  List avgField0List = deviceName.contains("NPK")
      ? avgMa[1].map(
          single: (value) => value.field0,
          triple: (value) => [
            {
              "N": value.field0.nVec[0].toStringAsPrecision(2),
              "P": value.field0.pVec[0].toStringAsPrecision(2),
              "K": value.field0.pVec[0].toStringAsPrecision(2),
            },
          ],
        )
      : avgMa[0].map(
          single: (value) => value.field0,
          triple: (value) => [
            {
              "N": value.field0.nVec[0].toStringAsPrecision(2),
              "P": value.field0.pVec[0].toStringAsPrecision(2),
              "K": value.field0.pVec[0].toStringAsPrecision(2),
            },
          ],
        );
  print("[getAVG] $avgField0List");

  if (deviceName.contains("NPK")) {
    return [
      avgField0List[0]["N"],
      avgField0List[0]["P"],
      avgField0List[0]["K"],
    ];
  }

  return avgField0List;
}

class GraphSettings {
  tooltip() => TooltipBehavior(
        enable: true,
        elevation: 5,
        canShowMarker: true,
        activationMode: ActivationMode.singleTap,
        shared: false,
        header: "Sensor Value",
        format: 'ณ point.x, ค่า: point.y',
        decimalPlaces: 2,
        textStyle: const TextStyle(fontSize: 16.0),
      );

  trackball() => TrackballBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
        shouldAlwaysShow: true,
        tooltipDisplayMode: TrackballDisplayMode.nearestPoint,
        tooltipSettings: const InteractiveTooltip(enable: false),
        markerSettings: const TrackballMarkerSettings(
          markerVisibility: TrackballVisibilityMode.hidden,
        ),
      );
  zoom() => ZoomPanBehavior(
        zoomMode: ZoomMode.x,
        maximumZoomLevel: 0.2,
        enableMouseWheelZooming: true,
        enablePinching: true,
        enablePanning: true,
      );
}

List<Widget> reportTabInstructions = const [
  Text(
    "Report",
    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
  ),
  Padding(padding: EdgeInsets.all(20.0)),
  Text(
    "The report is included some of the information such as farm name, devices and their types. \n\nTo include graph in the pdf, you have to press `Export graph as jpeg` first and it will appear on this tab. \n\nYou can check the path of the screenshot and also type in some notes. \n\nTo create pdf file, press `Make` button",
    style: TextStyle(
      fontSize: 14.0,
    ),
    overflow: TextOverflow.clip,
  ),
];

IndicatorDescriptions(String ind) {
  switch (ind) {
    case "sma":
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          "Simple Moving Average (SMA); calculate a moving average for past data in the selected range. \n * Slowly react to data \n * No weight added to the data",
          overflow: TextOverflow.clip,
        ),
      );
    case "ema":
      return const Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          "Exponential Moving Average (EMA); calculate a moving average for past data in the selected range. \n * Quickly react to the recent data \n * Adds weight to the data \n * May not works with some devices",
          overflow: TextOverflow.clip,
        ),
      );
    default:
  }
}
