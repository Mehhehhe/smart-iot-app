import 'dart:convert';
import 'dart:math';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flip_card/flip_card.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';

int farmIndex = 0;
List mainWidgetDisplay = ["graph", "numbers", "report"];
int defaultMainDisplay = 0;

class farmCardView extends StatefulWidget {
  farmCardView({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _farmCardViewState();
}

class _farmCardViewState extends State<farmCardView> {
  static late MQTTClientWrapper client;

  // bool _showFrontCard = true;
  // GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();
  late FlipCardController _controller;

  void onIndexSelection(dynamic index) {
    setState(() {
      farmIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      client = MQTTClientWrapper();
      client.prepareMqttClient();
    });
    _controller = FlipCardController();
    _controller.hint(
        duration: Duration(milliseconds: 500),
        total: Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    super.dispose();
    client.client.disconnect();
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
                    front: farmAsCard(context, dataMap["OwnedFarm"]),
                    back: farmCardRear());
              // return GestureDetector(
              //   onTap: () => setState(() {
              //     _showFrontCard = !_showFrontCard;
              //   }),
              //   child: AnimatedSwitcher(
              //       duration: Duration(milliseconds: 200),
              //       transitionBuilder: __transitionBuilder,
              //       layoutBuilder: (currentChild, previousChildren) => Stack(
              //             children: [currentChild!, ...previousChildren],
              //           ),
              //       switchInCurve: Curves.easeInBack,
              //       switchOutCurve: Curves.easeInBack.flipped,
              //       child: _showFrontCard
              //           ? farmAsCard(context, dataMap["OwnedFarm"])
              //           : farmCardRear()),
              // );
              // return farmAsCard(context, dataMap["OwnedFarm"]);
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
                  print("Created within condition");
                  return Text(
                      context
                          .read<FarmCardCubit>()
                          .decodeAndRemovePadding(data[state.farmIndex]),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold));
                }
                print("Created out of condition");
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
            Container(
                height: 300,
                width: MediaQuery.of(context).size.width - 10,
                margin: EdgeInsets.all(10),
                color: Colors.blueGrey,
                child: Text("Display builder here based on buttons")),
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
                        onPressed: () => setState(() {
                              // _showFrontCard = !_showFrontCard;
                              _controller.toggleCard();
                            }),
                        icon: Icon(Icons.keyboard_double_arrow_right)),
                    Text("More"),
                  ],
                ),
              ],
            )
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
              child: Text("Test"),
            )
          ]),
    );
  }
}
