import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'user_data_stream_event.dart';
part 'user_data_stream_state.dart';

class UserDataStreamBloc extends Bloc<UserDataStreamEvent, UserDataStreamState> {
  UserDataStreamBloc() : super(UserDataStreamInitial()) {
    on<UserDataStreamEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
