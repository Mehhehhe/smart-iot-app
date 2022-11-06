import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class LiveChart extends StatefulWidget {
  String type;
  List<String> devices;
  LiveChart({Key? key, required this.type, required this.devices})
      : super(key: key);
  State<StatefulWidget> createState() => _LiveChartState();
}

class _LiveChartState extends State<LiveChart> {
  ChartSeriesController? _chartSeriesController;
  // List<_ChartData> chartData = [_ChartData(DateTime.now(), 0.0)];
  late String chartType;
  late List<String> dev;
  late Timer timer;

  // void setDataStreamToChartList(Timer timer) async {
  //   if (mounted) {
  //     setState(() {
  //       dev.forEach((element) {
  //         var elm = json.decode(element);
  //         for (var subElement in elm) {
  //           var subMap = Map<String, dynamic>.from(subElement);
  //           print("Read submap $subMap");
  //           chartData.add(_ChartData(
  //               DateTime.fromMillisecondsSinceEpoch(subMap["TimeStamp"])
  //                   .toLocal(),
  //               double.parse(subMap["Value"])));
  //         }
  //       });
  //     });
  //     updateData();
  //   }
  // }

  // void updateData() {
  //   _chartSeriesController!.updateDataSource(
  //       addedDataIndexes: <int>[chartData.length - 1],
  //       removedDataIndexes: <int>[0]);
  // }

  @override
  void initState() {
    super.initState();

    setState(() {
      chartType = widget.type;
      dev = widget.devices;
    });
  }

  // @override
  // void dispose() {
  //   chartType = "";
  //   dev = const Stream<String>.empty();
  //   _chartSeriesController = null;
  //   chartData.clear();
  //   super.dispose();
  // }

  Widget liveChart(String type, List<String> dev) {
    final bloc = BlocProvider.of<LiveDataCubit>(context);
    return BlocBuilder<LiveDataCubit, LiveDataInitial>(
      builder: (context, state) {
        // state.chartData = context.read<LiveDataCubit>().transformFromRawData();
        // BlocProvider.of<LiveDataCubit>(context).createChartList();
        switch (type) {
          case "line":
            return _buildLineChart(state.chartData!);
          case "bar":
            return Container();
        }
        return Container();
      },
    );
    // return StreamBuilder(
    //   stream: bloc.liveData,
    //   builder: (context, snapshot) {
    //     if (!snapshot.hasData) return CircularProgressIndicator();
    //     return _buildLineChart(context.read<LiveDataCubit>().getNewChartData());
    //   },
    // );
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
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          onRendererCreated: (ChartSeriesController controller) {
            _chartSeriesController = controller;
          },
          dataSource: data,
          enableTooltip: true,
          xValueMapper: (ChartData datum, index) => datum.date,
          yValueMapper: (ChartData datum, index) => datum.values,
        )
      ],
      tooltipBehavior: TooltipBehavior(
          enable: true,
          elevation: 5,
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          shared: true,
          header: "Sensor Value",
          format: '@ point.x, point.y',
          decimalPlaces: 2,
          textStyle: const TextStyle(fontSize: 20.0)),
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

  @override
  Widget build(BuildContext context) {
    return liveChart(chartType, dev);
  }
}
