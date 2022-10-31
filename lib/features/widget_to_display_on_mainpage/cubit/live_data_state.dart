part of 'live_data_cubit.dart';

abstract class LiveDataState extends Equatable {
  // Data input as Stream<String>
  Stream<String> dataResponse;
  LiveDataState({required this.dataResponse});

  @override
  List<Object> get props => [];
}

class LiveDataInitial extends LiveDataState {
  LiveDataInitial({required Stream<String> data}) : super(dataResponse: data);
}
