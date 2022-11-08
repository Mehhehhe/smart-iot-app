part of 'live_data_cubit.dart';

abstract class LiveDataState extends Equatable {
  // Data input as Stream<String>
  List<Map> dataResponse;
  // Chart Data obj
  List<ChartData>? chartData;
  LiveDataState({required this.dataResponse, required this.chartData});

  @override
  List<Object> get props => [dataResponse];
}

class LiveDataInitial extends LiveDataState {
  LiveDataInitial({required List<Map> data, List<ChartData>? chartData})
      : super(dataResponse: data, chartData: chartData);
}
