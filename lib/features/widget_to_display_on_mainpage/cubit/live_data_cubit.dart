import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';

part 'live_data_state.dart';

class LiveDataCubit extends Cubit<LiveDataInitial> {
  // First time object created, set first time value
  LiveDataCubit(List<Map> data, [List<ChartData>? chartData])
      : super(LiveDataInitial(data: data, chartData: chartData));

  getNewChartData() => state.chartData;
}
