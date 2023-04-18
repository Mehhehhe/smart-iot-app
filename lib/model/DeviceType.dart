// ignore: file_names
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

enum DeviceValType {
  temperature,
  humidity,
  npk,
  unknown,
  // HUMIDITY_IN_SOIL
}

class DeviceType {
  final properties = {
    'DeviceValType.temperature': {
      'min': 0.0,
      'max': 100.0,
      'unit': 'celsius',
    },
    'DeviceValType.humidity': {
      'min': 0.0,
      'max': 100.0,
      'unit': 'percent',
      'value_type': num,
    },
    'DeviceValType.npk': {
      'min': 0.0,
      'max': 2000.0,
      'unit': 'mg/kg',
      'value_type': Map,
    },
    'DeviceValType.light': {
      'min': 0.0,
      'max': 100000.0,
      'unit': 'lx',
    },
  };

  Map<String, Object>? getProps(String type) => properties[type];
}

class DeviceWidgetGenerator {
  DeviceWidgetGenerator() {}

  DeviceValType _translate({required String deviceName}) {
    // convert to all lowercase
    String dev_name = deviceName.toLowerCase();
    if (dev_name.contains("moist") || dev_name.contains("humid")) {
      return DeviceValType.humidity;
    } else if (dev_name.contains("npk")) {
      return DeviceValType.npk;
    } else if (dev_name.contains("temp")) {
      return DeviceValType.temperature;
    }

    return DeviceValType.unknown;
  }

  Widget buildMainpageCardDisplay({
    required String deviceSerial,
    required dynamic currentValue,
    BuildContext? context,
    bool state = true,
  }) {
    // fetch props
    // print(
    //     "[Translator: $deviceSerial] ${_translate(deviceName: deviceSerial)}");
    Map props =
        DeviceType().getProps("${_translate(deviceName: deviceSerial)}")!;
    if (props['value_type'] == null) {
      throw Exception(
        "Type not found: value(s) did not exist in the scope or not yet implemented",
      );
    }
    bool isMultiValuesDevice = props['value_type'] == Map;
    // convert current value if a single value
    if (state) {
      if (isMultiValuesDevice) {
        return _multiValueInCard(
          context: context!,
          serial: deviceSerial,
          values: currentValue,
          props: props,
        );
      }

      return _singleValueInCard(
        context: context!,
        serial: deviceSerial,
        value: currentValue,
        props: props,
      );
    }

    return Container(
      height: MediaQuery.of(context!).size.height,
      child: Text("Device is turned off"),
    );
  }

  _singleValueInCard({
    required BuildContext context,
    required String serial,
    required dynamic value,
    required Map props,
  }) {
    double v = value.runtimeType == String ? double.parse(value) : value;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        title: GaugeTitle(text: serial),
        axes: <RadialAxis>[
          RadialAxis(
            minimum: props["min"],
            maximum: props["max"],
            radiusFactor: 0.8,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(
                value: value,
                width: 18,
                color: Colors.greenAccent,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  "$v",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _multiValueInCard({
    required BuildContext context,
    required String serial,
    required Map values,
    required Map props,
  }) {
    // Create data point
    List<_DataPoint> dataPoints = [];
    for (var val in values.entries) {
      // print(
      //     "[AddingDatapoint] ${val.key} ${val.value}, try parse ${val.value.runtimeType} get ${num.parse(val.value.toString())}");
      dataPoints.add(_DataPoint(
        name: val.key,
        value: val.value.runtimeType == num
            ? val.value
            : num.parse(val.value.toString()),
      ));
    }

    return Container(
      width: MediaQuery.of(context).size.width * 0.2,
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
      child: SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        primaryYAxis: NumericAxis(
          axisLine: const AxisLine(
            width: 0,
          ),
          majorTickLines: const MajorTickLines(width: 0),
        ),
        title: ChartTitle(
          text: serial,
          textStyle: const TextStyle(
            fontSize: 14.0,
          ),
        ),
        series: <ChartSeries>[
          BarSeries<_DataPoint, String>(
            dataSource: dataPoints,
            xValueMapper: (datum, index) => datum.name,
            yValueMapper: (datum, index) => datum.value,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
              labelAlignment: ChartDataLabelAlignment.middle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DataPoint {
  final String name;
  final num value;

  _DataPoint({required this.name, required this.value});
}
