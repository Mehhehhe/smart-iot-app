part of 'user_data_stream_bloc.dart';

abstract class UserDataStreamEvent extends Equatable {
  const UserDataStreamEvent();

  @override
  List<Object> get props => [];
}

class _OnUserDataStreaming extends UserDataStreamEvent {
  final String data;
  final String pos;

  const _OnUserDataStreaming({required this.data, required this.pos});
}

class OnUserStreamingEnds {}
