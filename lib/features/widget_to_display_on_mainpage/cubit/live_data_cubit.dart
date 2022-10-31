import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'live_data_state.dart';

class LiveDataCubit extends Cubit<LiveDataInitial> {
  // First time object created, set first time value
  LiveDataCubit() : super(LiveDataInitial(data: const Stream<String>.empty()));

  void stateChange(Stream<String> incomingData) =>
      emit(LiveDataInitial(data: incomingData));
}
