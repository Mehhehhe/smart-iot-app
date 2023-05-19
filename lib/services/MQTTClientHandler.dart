// import 'dart:async';
// import 'dart:io';
import 'dart:convert';
import 'dart:io';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// // connection states for easy identification
enum MqttCurrentConnectionState {
  IDLE,
  CONNECTING,
  CONNECTED,
  DISCONNECTED,
  ERROR_WHEN_CONNECTING
}

enum MqttSubscriptionState { IDLE, SUBSCRIBED }

class MQTTClientWrapper {
  late MqttServerClient client;

  MqttCurrentConnectionState connectionState = MqttCurrentConnectionState.IDLE;
  MqttSubscriptionState subscriptionState = MqttSubscriptionState.IDLE;

  late Stream<List<MqttReceivedMessage<MqttMessage>>> subscription;

  MQTTClientWrapper(String from) {
    print("[Activate] from $from");
    prepareMqttClient();
  }

  // using async tasks, so the connection won't hinder the code flow
  void prepareMqttClient() async {
    _setupMqttClient();
    await _connectClient();
    // _subscribeToTopic('Dart/Mqtt_client/testtopic');
    // _publishMessage('Hello');
  }

  //ignore:long-method
  void subscribeToOneResponse(
    String farmName,
    dynamic deviceName, [
    bool? isOnlySubscribe,
  ]) async {
    String msgToReturn = "";
    Type typeCheck = deviceName.runtimeType;
    print("$farmName, $deviceName, $isOnlySubscribe");
    switch (typeCheck) {
      case String:
        client.subscribe(
            "$farmName/$deviceName/data/live", MqttQos.atLeastOnce);
        if (!isOnlySubscribe!) {
          _publishMessage(json.encode({"RequestConfirm": "true"}),
              "$farmName/$deviceName/data/request");
        }

        break;
      case List:
        if (deviceName.length > 1) {
          // Fetch by target
          client.subscribe(
            '$farmName/for_init/data/liveOnce',
            MqttQos.atLeastOnce,
          );
          if (!isOnlySubscribe!) {
            _publishMessage(
              json.encode({
                "Devices": (deviceName as List)
                    .map((e) => e["DeviceName"])
                    .toList()
                    .join(','),
              }),
              '$farmName/for_init/data/requestInit',
            );
          }
        }
        deviceName.forEach((device) {
          if (device.runtimeType == Map) {
            client.subscribe(
              "$farmName/${device["DeviceName"]}/data/live",
              MqttQos.atLeastOnce,
            );
          } else if (device.runtimeType == String) {
            client.subscribe(
              "$farmName/${device}/data/live",
              MqttQos.atLeastOnce,
            );
          } else {
            final map = Map<String, dynamic>.from(device);
            client.subscribe(
              "$farmName/${map["SerialNumber"]}/data/live",
              MqttQos.atLeastOnce,
            );
          }
        });
        break;
      default:
        break;
    }
  }

  Future<bool> publishToSetDeviceState(
      String farmName, String device, bool stateToSet) async {
    _publishMessage(json.encode({"requestedState": stateToSet}),
        "$farmName/$device/change_state");

    return true;
  }

  Future<bool> publishToControlValue(
      String farmName, String device, dynamic value) async {
    _publishMessage(
        json.encode({"controlValue": value}), "$farmName/$device/controlValue");

    return true;
  }

  // waiting for the connection, if an error occurs, print it and disconnect
  Future<void> _connectClient() async {
    try {
      print('client connecting....');
      connectionState = MqttCurrentConnectionState.CONNECTING;
      await client.connect();
    } on Exception catch (e) {
      print('client exception - $e');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }

    // when connected, print a confirmation, else print an error
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      connectionState = MqttCurrentConnectionState.CONNECTED;
      print('client connected');
    } else {
      print(
          'ERROR client connection failed - disconnecting, status is ${client.connectionStatus}');
      connectionState = MqttCurrentConnectionState.ERROR_WHEN_CONNECTING;
      client.disconnect();
    }
  }

  Future<void> _setupMqttClient() async {
    String randomUser = UUID.getUUID();
    client = MqttServerClient.withPort(
        'a2ym69b60cuwbt-ats.iot.ap-southeast-1.amazonaws.com', randomUser, 8883)
      // the next 2 lines are necessary to connect with tls, which is used by HiveMQ Cloud
      ..secure = true
      ..setProtocolV311()
      ..logging(on: false)
      ..autoReconnect = true
      // ..securityContext = SecurityContext.defaultContext
      ..keepAlivePeriod = 60
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed;

    // import certs
    final List<int> trustedCertificateBytes =
        (await rootBundle.load('assets/certificates/AmazonRootCA1.pem'))
            .buffer
            .asInt8List();
    final List<int> certificateChainBytes =
        (await rootBundle.load('assets/certificates/certificate.pem.crt'))
            .buffer
            .asInt8List();
    final List<int> privateKeyBytes =
        (await rootBundle.load('assets/certificates/private.pem.key'))
            .buffer
            .asInt8List();

    final securityContext = SecurityContext.defaultContext;
    securityContext.setTrustedCertificatesBytes(trustedCertificateBytes);
    securityContext.useCertificateChainBytes(certificateChainBytes);
    securityContext.usePrivateKeyBytes(privateKeyBytes);
    client.securityContext = securityContext;

    final MqttConnectMessage conMsg =
        MqttConnectMessage().withClientIdentifier(randomUser).startClean();
    client.connectionMessage = conMsg;
    print("Initializing: Mqtt client connecting ... ");
  }

  void _subscribeToTopic(String topicName) {
    print('Subscribing to the $topicName topic');
    client.subscribe(topicName, MqttQos.atLeastOnce);

    // print the message when it is received
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      var message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      print('YOU GOT A NEW MESSAGE:');
      print(message);
    });
  }

  void _publishMessage(String message, String topic) {
    final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(message);
    // topic = topic ?? 'Dart/Mqtt_client/testtopic';
    print('Publishing message "$message" to topic $topic');
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    print("published ... ");
  }

  // callbacks for different events
  void _onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
    subscriptionState = MqttSubscriptionState.SUBSCRIBED;
  }

  void _onDisconnected() {
    print('OnDisconnected client callback - Client disconnection');
    connectionState = MqttCurrentConnectionState.DISCONNECTED;
  }

  void _onConnected() {
    connectionState = MqttCurrentConnectionState.CONNECTED;
    print('OnConnected client callback - Client connection was successful');
  }

  void disconnect() {
    client.disconnect();
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessageStream() {
    return client.updates;
  }
}
