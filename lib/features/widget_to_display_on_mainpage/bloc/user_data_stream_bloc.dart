import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';

part 'user_data_stream_event.dart';
part 'user_data_stream_state.dart';

class UserDataStreamBloc
    extends Bloc<UserDataStreamEvent, UserDataStreamState> {
  final MQTTClientWrapper _client;
  final String _device;
  final String _location;

  late String data;

  UserDataStreamBloc({
    required MQTTClientWrapper client,
    required String device,
    required String location,
  })  : _client = client,
        _device = device,
        _location = location,
        super(const UserDataStreamState.unknown()) {
    // Client not existed; uncomment below!
    // client.prepareMqttClient();
    client.subscribeToOneResponse(location, device, true);
    on<_OnUserDataStreaming>((event, emit) async {
      return emit(UserDataStreamState.init(device, location, event.data));
    });
    on<OnUserStreamingEnds>(
      (event, emit) async {
        client.disconnect();
      },
    );
    client
        .getMessageStream()!
        .listen((List<MqttReceivedMessage<MqttMessage>>? event) {
      final recMsg = event![0].payload as MqttPublishMessage;
      final originalPos = event[0].topic.split("/").elementAt(1);
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMsg.payload.message);
      data = pt;
      print("[FindPt] $pt");
      if (data.isNotEmpty &&
          client.connectionState != MqttConnectionState.disconnected) {
        add(_OnUserDataStreaming(data: data, pos: location));
      }
    });
  }
}
