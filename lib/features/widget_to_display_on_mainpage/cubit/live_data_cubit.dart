import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';

part 'live_data_state.dart';

class LiveDataCubit extends Cubit<LiveDataInitial> {
  // First time object created, set first time value
  LiveDataCubit(List<Map> data, [List<ChartData>? chartData])
      : super(LiveDataInitial(data: data, chartData: chartData));

  // void stateChange(Stream<String> incomingData) =>
  //     emit(LiveDataInitial(data: incomingData, chartData: state.chartData));

  // void createChartList() {
  //   var tempChartList = [ChartData(DateTime.now(), 0.0)];
  //   for (var element in state.dataResponse) {
  //     var elm = json.decode(element);
  //     print("Element: $elm");
  //     for (var elsup in elm) {
  //       var subelm = Map<String, dynamic>.from(elsup);
  //       tempChartList.add(ChartData(
  //           DateTime.fromMillisecondsSinceEpoch(subelm["TimeStamp"]),
  //           double.parse(subelm["Value"])));
  //     }
  //   }
  //   emit(LiveDataInitial(data: state.dataResponse, chartData: tempChartList));
  // }

  getNewChartData() => state.chartData;

  // List<String> get liveData {
  //   return state.dataResponse;
  // }
}
