import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/device_selector_for_graph.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/lambdaCaller.dart';

import 'graph_in_farm_card.dart';

int farmIndex = 0;
List mainWidgetDisplay = ["graph", "numbers", "report"];
int defaultMainDisplay = 0;

class farmCardView extends StatefulWidget {
  farmCardView({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _farmCardViewState();
}

class _farmCardViewState extends State<farmCardView> {
  MQTTClientWrapper client = MQTTClientWrapper();
  List devices = [];
  List devList = [];
  var exposedLoc = "";
  String tempLoc = "";
  // Data stream
  List<String> dataResponse = [];
  bool enableGraph = false;
  bool isLoaded = false;
  late Timer timer;

  FlipCardController _controller = FlipCardController();

  _farmCardViewState() {
    print("Start timer");
    if (isLoaded) {
      Timer.run(() => periodicallyFetch);
    }
    timer = Timer.periodic(const Duration(seconds: 15), periodicallyFetch);
  }

  void onIndexSelection(dynamic index) {
    setState(() {
      farmIndex = index;
    });
  }

  void onDeviceSelection(List ind) async {
    var loc = devices[0]["Location"];
    setState(() {
      enableGraph = true;
      exposedLoc = loc;
      devList = ind;
    });
  }

  void setDataListener() {
    client
        .getMessageStream()!
        .listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      setState(() {
        if (!dataResponse.contains(pt)) {
          dataResponse.add(pt);
        }
      });
    });
  }

  void periodicallyFetch(Timer timer) async {
    print("\nStatus sub: $tempLoc, $devices\n");
    setState(() {
      client.subscribeToOneResponse(exposedLoc == "" ? tempLoc : exposedLoc,
          devList.isEmpty ? devices : devList);
    });
  }

  // var devicesToList = (farm) async => await getDevicesByFarmName(farm);
  devicesToList(farm) async {
    var temp_devices = await getDevicesByFarmName(farm);
    devices = temp_devices;
  }

  List<ChartData> transformFromRawData(List<String> inputData) {
    var tempChartList = [ChartData(DateTime.now(), 0.0)];
    for (var element in inputData) {
      var elm = json.decode(element);
      print("Element: $elm");
      for (var elsup in elm) {
        var subelm = Map<String, dynamic>.from(elsup);
        tempChartList.add(ChartData(
            DateTime.fromMillisecondsSinceEpoch(subelm["TimeStamp"]),
            double.parse(subelm["Value"])));
      }
    }
    tempChartList.removeAt(0);
    return tempChartList;
  }

  @override
  void initState() {
    client.prepareMqttClient();
    setDataListener();
    super.initState();
    setState(() {
      isLoaded = true;
    });
  }

  @override
  void dispose() {
    super.dispose();
    client.disconnect();
    devices.clear();
    enableGraph = false;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(
      children: [
        FutureBuilder(
          future: context.read<FarmCardCubit>().getOwnedFarmsList(),
          builder: (context, snapshot) {
            var connectionState = snapshot.connectionState;
            print(connectionState);
            switch (connectionState) {
              case ConnectionState.done:
                print(snapshot.data);
                Map dataMap = Map.from(snapshot.data as Map);
                return FlipCard(
                    controller: _controller,
                    flipOnTouch: false,
                    onFlipDone: (isFront) => print(isFront),
                    front: farmAsCard(context, dataMap["OwnedFarm"]),
                    back: farmCardRear());
              default:
                break;
            }
            return Container();
          },
        )
      ],
    );
  }

  Widget farmAsCard(BuildContext context, dynamic data) {
    print(context);
    return Card(
      key: ValueKey(true),
      margin: EdgeInsets.all(20),
      elevation: 5.0,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BlocBuilder<FarmCardCubit, FarmCardInitial>(
              builder: (context, state) {
                print(
                    "state index: ${state.farmIndex} , farm index: $farmIndex");

                if (state.farmIndex == farmIndex) {
                  // print("Created within condition");
                  devicesToList(context
                      .read<FarmCardCubit>()
                      .decodeAndRemovePadding(data[state.farmIndex]));
                  // print(devices);
                  tempLoc = FarmCardCubit()
                      .decodeAndRemovePadding(data[state.farmIndex]);
                  return Text(
                      context
                          .read<FarmCardCubit>()
                          .decodeAndRemovePadding(data[state.farmIndex]),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold));
                }
                // print("Created out of condition");
                devicesToList(context
                    .read<FarmCardCubit>()
                    .decodeAndRemovePadding(data[farmIndex]));
                // print(devices);
                tempLoc =
                    FarmCardCubit().decodeAndRemovePadding(data[farmIndex]);
                return Text(
                    context
                        .read<FarmCardCubit>()
                        .decodeAndRemovePadding(data[farmIndex]),
                    style: const TextStyle(
                        fontSize: 28, fontWeight: FontWeight.bold));
              },
            ),
            TextButton(
                onPressed: () async {
                  // _displayFarmEditor(context, data);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FarmEditor(farm: data),
                      )).then((value) => onIndexSelection(value));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.edit),
                    Text("Change to another farm")
                  ],
                )),
            if (defaultMainDisplay > 2 || defaultMainDisplay < 0)
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width - 10,
                margin: EdgeInsets.all(10),
              ),
            // Chart
            if (defaultMainDisplay == 0)
              Container(
                height: 300,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(10),
                child: BlocProvider(
                  create: (_) => LiveDataCubit(
                      dataResponse, transformFromRawData(dataResponse)),
                  child: LiveChart(
                    devices: dataResponse,
                    type: 'line',
                  ),
                ),
              ),
            Text("What to be display ?"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            defaultMainDisplay = 0;
                          });
                        },
                        icon: Icon(Icons.auto_graph)),
                    Text("Graph"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            defaultMainDisplay = 1;
                          });
                        },
                        icon: Icon(Icons.numbers)),
                    Text("Numbers"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {
                          setState(() {
                            defaultMainDisplay = 2;
                          });
                        },
                        icon: Icon(Icons.description_outlined)),
                    Text("Status Report"),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () => _controller.toggleCard(),
                        icon: Icon(Icons.keyboard_double_arrow_right)),
                    Text("More"),
                  ],
                ),
              ],
            ),
            TextButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceSelector(devices: devices),
                      )).then((value) => onDeviceSelection(value));
                },
                child: Text("Choose devices ..."))
          ]),
    );
  }

  Widget farmCardRear() {
    return Card(
      key: ValueKey(false),
      margin: EdgeInsets.all(20),
      elevation: 5.0,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Rear"),
            Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              child: Text("Display sensor's value here"),
            ),
            Container(
              child: Builder(
                builder: (context) {
                  print(dataResponse);
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataResponse.length,
                    itemBuilder: (context, index) {
                      return Text(dataResponse[index]);
                    },
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () => _controller.toggleCard(),
                          icon: Icon(Icons.keyboard_return)),
                      Text("Return"),
                    ],
                  ),
                ),
              ],
            )
          ]),
    );
  }
}
