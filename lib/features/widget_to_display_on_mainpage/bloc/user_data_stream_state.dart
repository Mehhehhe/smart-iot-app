part of 'user_data_stream_bloc.dart';

abstract class UserDataStreamState extends Equatable {
  const UserDataStreamState();
  
  @override
  List<Object> get props => [];
}

class UserDataStreamInitial extends UserDataStreamState {}
