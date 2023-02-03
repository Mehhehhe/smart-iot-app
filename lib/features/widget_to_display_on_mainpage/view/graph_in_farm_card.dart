import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

class LiveChart extends StatefulWidget {
  String type;
  List<Map> devices;
  LiveChart({Key? key, required this.type, required this.devices})
      : super(key: key);
  State<StatefulWidget> createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  ChartSeriesController? _chartSeriesController;
  // List<_ChartData> chartData = [_ChartData(DateTime.now(), 0.0)];
  late String chartType;
  late List<Map> dev;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    setState(() {
      chartType = widget.type;
      dev = widget.devices;
    });
  }

  Widget liveChart(String type, List<Map> dev) {
    final bloc = BlocProvider.of<LiveDataCubit>(context);
    return BlocBuilder<LiveDataCubit, LiveDataInitial>(
      builder: (context, state) {
        // state.chartData = context.read<LiveDataCubit>().transformFromRawData();
        // BlocProvider.of<LiveDataCubit>(context).createChartList();
        switch (type) {
          case "line":
            return _buildLineChart(state.chartData!);
          case "bar":
            return _buildBarChart(state.chartData!);
          case "pie":
            return _buildPieChart(state.chartData!);
        }
        return Container();
      },
    );
  }

  SfCartesianChart _buildLineChart(List<ChartData> data) {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      backgroundColor: Colors.white,
      plotAreaBackgroundColor: Colors.white54,
      palette: [
        Color.fromRGBO(208, 31, 49, 1.0),
        Color.fromRGBO(246, 129, 33, 1.0),
        Color.fromRGBO(251, 221, 11, 1.0),
        Color.fromRGBO(0, 123, 97, 1.0),
        Color.fromRGBO(0, 114, 185, 1.0),
      ],
      plotAreaBorderColor: Colors.grey,
      primaryXAxis: DateTimeAxis(
          enableAutoIntervalOnZooming: true,
          autoScrollingDelta: 3,
          autoScrollingDeltaType: DateTimeIntervalType.hours,
          title: AxisTitle(
              text: data.length <= 170
                  ? "Time in minute:seconds"
                  : data.length <= 3000
                      ? "Time in hours:minutes"
                      : "Time in hours"),
          visibleMaximum: null),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      series: _lineSeries(data),
      tooltipBehavior: TooltipBehavior(
          enable: true,
          elevation: 5,
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          shared: true,
          header: "Sensor Value",
          format: 'ณ point.x, ค่า: point.y',
          decimalPlaces: 2,
          textStyle: const TextStyle(fontSize: 16.0)),
      trackballBehavior: TrackballBehavior(
          activationMode: ActivationMode.singleTap,
          enable: true,
          shouldAlwaysShow: true,
          tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
          tooltipSettings: const InteractiveTooltip(enable: false),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.hidden,
          )),
    );
  }

  _lineSeries(List<ChartData> data) {
    List<LineSeries<ChartData, DateTime>> temp =
        <LineSeries<ChartData, DateTime>>[];
    List<String> places = [];
    // Find all devices
    for (var elm in data) {
      print("Prepare data ${elm.place}, ${elm.values}");
      if (!places.contains(elm.place)) {
        places.add(elm.place);
      }
    }
    // Seperate data for each devices
    for (var plc in places) {
      List<ChartData> temp_arr = [];
      for (var chrt in data) {
        if (chrt.place == plc) {
          temp_arr.add(chrt);
        }
      }
      temp.add(LineSeries(
        onRendererCreated: (controller) => _chartSeriesController = controller,
        name: plc,
        dataSource: temp_arr,
        enableTooltip: true,
        xValueMapper: (datum, index) => datum.date,
        yValueMapper: (datum, index) => datum.values,
      ));
      temp_arr = [];
    }
    return temp;
  }

  SfSparkBarChart _buildBarChart(List<ChartData> data) {
    return SfSparkBarChart(
      data: _barSeries(data),
    );
  }

  _barSeries(List<ChartData> data) {
    List<num> newBar = [];
    for (var cd in data) {
      newBar.add(cd.values);
    }
    return newBar;
  }

  SfCircularChart _buildPieChart(List<ChartData> data) {
    return SfCircularChart(
      series: _circularSeries(data),
    );
  }

  _circularSeries(List<ChartData> data) {
    List<CircularSeries<ChartData, dynamic>> temp = [];
    return temp;
  }

  @override
  Widget build(BuildContext context) {
    return liveChart(chartType, dev);
  }
}
