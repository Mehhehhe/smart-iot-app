part of 'user_data_stream_bloc.dart';

class UserDataStreamState extends Equatable {
  final String device;
  final String location;

  final String data;

  const UserDataStreamState._(
      {this.device = "", this.location = "", this.data = ""});

  const UserDataStreamState.unknown() : this._();

  const UserDataStreamState.init(String device, String location, String data)
      : this._(device: device, location: location, data: data);

  @override
  List<Object> get props => [data];
}
