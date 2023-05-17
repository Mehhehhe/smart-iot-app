// ignore: file_names
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

enum DeviceValType {
  temperature,
  humidity,
  npk,
  unknown,
  fan,
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
    'DeviceValType.fan': {
      'min': 0,
      'max': 1,
      'unit': '-',
      'value_type': bool,
      'control': true,
    },
  };

  Map<String, Object>? getProps(String type) => properties[type];
}

class DeviceWidgetGenerator {
  DeviceWidgetGenerator() {}

  DeviceValType _translate({required String deviceName}) {
    // convert to all lowercase
    String dev_name = deviceName.toLowerCase();
    print(dev_name.contains("fan"));
    if (dev_name.contains("moist") || dev_name.contains("humid")) {
      return DeviceValType.humidity;
    } else if (dev_name.contains("npk")) {
      return DeviceValType.npk;
    } else if (dev_name.contains("temp")) {
      return DeviceValType.temperature;
    } else if (dev_name.contains("fan")) {
      return DeviceValType.fan;
    }

    return DeviceValType.unknown;
  }

  //ignore: long-parameter-list
  Widget buildMainpageCardDisplay({
    required String deviceSerial,
    required dynamic currentValue,
    BuildContext? context,
    bool state = true,
    required MQTTClientWrapper client,
  }) {
    // fetch props
    print("Building display for $deviceSerial");
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
    print("Properties: $props");
    // convert current value if a single value
    if (state) {
      if (isMultiValuesDevice) {
        return _multiValueInCard(
          context: context!,
          serial: deviceSerial,
          values: currentValue,
          props: props,
        );
      } else if (props.containsKey("control") && props["control"]) {
        return _controlStateLike(
          cli: client,
          serial: deviceSerial,
          controlMap: currentValue,
          context: context!,
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
    print("Display value $value , ${value.runtimeType}");
    double v = double.parse(value.toString());

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
                value: v,
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

  // sub widget for control
  _controlStateLike({
    required MQTTClientWrapper cli,
    required String serial,
    required dynamic controlMap,
    context,
  }) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(serial),
        SizedBox(
          height: 10.0,
        ),
        CupertinoSwitch(
          value: controlMap == 1.0 ? true : false,
          onChanged: (value) {},
        ),
      ]),
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
