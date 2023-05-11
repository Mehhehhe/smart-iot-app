import 'dart:async';
import 'dart:convert';
// import 'dart:html';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/db/threshold_settings.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/highlow_renderer.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';
// import 'package:smart_iot_app/services/MQTTClientHandler.dart';

import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_charts/sparkcharts.dart';
// import 'package:syncfusion_flutter_core/core.dart';
// import 'package:syncfusion_flutter_sliders/sliders.dart';

List<Color> palette = [
  const Color.fromRGBO(208, 31, 49, 1.0),
  const Color.fromRGBO(246, 129, 33, 1.0),
  const Color.fromRGBO(251, 221, 11, 1.0),
  const Color.fromRGBO(0, 123, 97, 1.0),
  const Color.fromRGBO(0, 114, 185, 1.0),
];

class LiveChart extends StatefulWidget {
  String type;
  List<Map> devices;
  Map detail;
  LiveChart({
    Key? key,
    required this.type,
    required this.devices,
    required this.detail,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  ChartSeriesController? _chartSeriesController;
  GlobalKey<SfCartesianChartState> _chartKey = GlobalKey();
  // List<_ChartData> chartData = [_ChartData(DateTime.now(), 0.0)];
  late String chartType;
  late List<Map> dev;
  late String devType;
  late Timer timer;
  List<String> typeList = [
    "line",
    "bar",
    "pie",
  ];
  // Range Controller
  // late RangeController _rangeController;
  DateTime _start = DateTime.now().subtract(const Duration(days: 1));
  DateTime _end = DateTime.now();
  // Base data
  late LocalHistoryDatabase instance;
  late dynamic thresholdValue;

  // Graph range config
  //  _days3 = true;
  //  _week = false;
  //  _month = false;
  //  _halfYear = false;
  // 1 day, 3 days, 1 week, 1 month,
  List<bool> selectedInterval = <bool>[
    true,
    false,
    false,
    false,
  ];
  static const List<Widget> intervalTexts = <Widget>[
    Text("1 Hour"),
    Text("3 days"),
    Text("1 week"),
    Text("3 month"),
  ];

  @override
  void initState() {
    super.initState();
    chartType = widget.type;
    dev = widget.devices;
    devType = widget.detail["Type"];
    instance = LocalHistoryDatabase.instance;
  }

  Widget liveChart(String type, List<Map> dev) {
    final bloc = BlocProvider.of<LiveDataCubit>(context);

    return BlocBuilder<LiveDataCubit, LiveDataInitial>(
      builder: (context, state) {
        if (state.chartData == null || !typeList.contains(type)) {
          return Container();
        }

        return _buildWithRangeSelector(
          state.chartData!,
          type,
        );
      },
    );
  }

  Widget _buildWithRangeSelector(List<ChartData> list, String type) {
    late Widget displayGraph;
    late Widget noCallingGraph;
    switch (type) {
      case "line":
        // LineSeries ls = await _lineSeries(list);
        displayGraph = FutureBuilder(
          future: _lineSeries(list),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Map<String, dynamic> l = snapshot.data! as Map<String, dynamic>;
              // print("[FutureMap] $l");
              dynamic ls = l["series"];
              noCallingGraph = _buildLineChart(
                list,
                ls: ls,
              );

              return _buildLineChart(
                list,
                ls: ls,
              );
            }

            return Container();
          },
        );
        // displayGraph = _buildLineChart(list);
        break;
      case "bar":
        // displayGraph = _buildBarChart(list);
        break;
      case "pie":
        // displayGraph = _buildPieChart(list);
        break;
    }

    return Column(
      children: [
        const Padding(padding: EdgeInsets.only(top: 10.0)),
        displayGraph,
        _toggleRangesRow(),
        
      ],
    );
  }

  // Ensure that only one button is green, others must be grey
  Widget _toggleRangesRow() {
    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (int index) {
        setState(() {
          // print(intervalTexts[index].hashCode);
          for (int i = 0; i < selectedInterval.length; i++) {
            selectedInterval[i] = i == index;
          }
          print(intervalTexts[index]
              .toString()
              .substring(6, intervalTexts[index].toString().length - 2));
          switch (intervalTexts[index]
              .toString()
              .substring(6, intervalTexts[index].toString().length - 2)) {
            // today
            case "1 Hour":
              _start = _end.subtract(const Duration(hours: 1));
              break;
            // 3 days
            case "3 days":
              _start = _end.subtract(const Duration(days: 3));
              break;
            // 1 week
            case "1 week":
              _start = _end.subtract(const Duration(days: 7));
              break;
            // 1 month
            case "3 month":
              _start = _end.subtract(const Duration(days: 90));
              break;
            default:
              break;
          }
        });
      },
      isSelected: selectedInterval,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      //selectedBorderColor: Colors.green[700],
      selectedColor: Colors.white,
      fillColor: Colors.deepOrange,
      color: Colors.orange[400],
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 80.0,
      ),
      children: intervalTexts,
    );
  }

  // ignore: long-method
  SfCartesianChart _buildLineChart(
    List<ChartData> data, {
    required dynamic ls,
  }) {
    return SfCartesianChart(
      key: _chartKey,
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      backgroundColor: Colors.white,
      plotAreaBackgroundColor: Colors.white54,
      palette: palette,
      plotAreaBorderColor: Colors.grey,
      annotations: [...getThreshLine()],
      primaryXAxis: DateTimeAxis(
        enableAutoIntervalOnZooming: true,
        // intervalType: DateTimeIntervalType.hours,
        // autoScrollingDelta: 3,
        // autoScrollingDeltaType: DateTimeIntervalType.hours,
        minimum: _start,
        maximum: _end,
        // visibleMaximum: endDateForDEbug!,
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
      zoomPanBehavior: ZoomPanBehavior(
        zoomMode: ZoomMode.x,
        enablePinching: true,
        maximumZoomLevel: 1,
        enableDoubleTapZooming: true,
      ),
    );
  }

  Future<Map<String, dynamic>> _lineSeries(List<ChartData> data) async {
    thresholdValue = await getThreshold();
    List<LineSeries<ChartData, DateTime>> temp =
        <LineSeries<ChartData, DateTime>>[];
    List<String> places = [];
    // add base here
    List<ChartData> base = await _addBase();
    List<ChartData> newDataList = [];
    newDataList.addAll(base);
    newDataList.addAll(data);
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

    return {
      "series": temp,
      "end": newDataList[1].date.toLocal(),
      "start": newDataList.last.date.toLocal(),
    };
  }

  LineSeries<ChartData, DateTime> _createSeries(
    List<ChartData> tempArr,
    String name,
  ) {
    // print("[create] $name");

    return LineSeries(
      onCreateRenderer: (series) => CustomLineSeriesRenderer(
        series as LineSeries<ChartData, DateTime>,
      ),
      emptyPointSettings: EmptyPointSettings(mode: EmptyPointMode.zero),
      onRendererCreated: (controller) => _chartSeriesController = controller,
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

  Future<List<ChartData>> _addBase() async {
    List<LocalHist> base =
        await instance.getHistoryOf(device: widget.detail["SerialNumber"]);
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

  Future<dynamic> getThreshold() async {
    ThresholdDatabase thd = ThresholdDatabase.instance;
    // "${sha1.convert(utf8.encode(widget.detail["SerialNumber"])).toString()}"

    return thd.getThresh(
      sha1.convert(utf8.encode(widget.detail["SerialNumber"])).toString(),
    );
  }

  getThreshLine() {
    // Check threshold type Map | double
    bool isMulti = thresholdValue.runtimeType.toString() == "_Map<String, num>";
    List threshLine(String? key) {
      return [
        CartesianChartAnnotation(
          widget: Container(
            height: 1,
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.5),
            ),
          ),
          horizontalAlignment: ChartAlignment.near,
          verticalAlignment: ChartAlignment.near,
          coordinateUnit: CoordinateUnit.point,
          region: AnnotationRegion.plotArea,
          // xAxisName: "Threshold",
          x: _start,
          y: key != null ? thresholdValue[key] : thresholdValue,
        ),
        CartesianChartAnnotation(
          widget: const Text(
            "Threshold",
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          horizontalAlignment: ChartAlignment.near,
          verticalAlignment: ChartAlignment.near,
          coordinateUnit: CoordinateUnit.point,
          region: AnnotationRegion.plotArea,
          // xAxisName: "Threshold",
          x: _start,
          y: key != null ? thresholdValue[key] + 15 : thresholdValue + 3,
        ),
      ];
    }

    if (isMulti) {
      return [
        ...threshLine("N"),
        ...threshLine("P"),
        ...threshLine("K"),
      ];
    }

    return threshLine(null);
  }

  @override
  Widget build(BuildContext context) {
    return liveChart(chartType, dev);
  }

  // Range & Query
}
