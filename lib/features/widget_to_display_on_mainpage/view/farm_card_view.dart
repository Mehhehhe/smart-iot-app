import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_editor.dart';

int farmIndex = 0;

class farmCardView extends StatefulWidget {
  farmCardView({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _farmCardViewState();
}

class _farmCardViewState extends State<farmCardView> {
  void onIndexSelection(dynamic index) {
    setState(() {
      farmIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
              case ConnectionState.waiting:
                return const CircularProgressIndicator();
              case ConnectionState.done:
                print(snapshot.data);
                Map dataMap = Map.from(snapshot.data as Map);
                return farmAsCard(context, dataMap["OwnedFarm"]);
              default:
                break;
            }
            return const CircularProgressIndicator();
          },
        )
      ],
    );
  }

  Widget farmAsCard(BuildContext context, dynamic data) {
    print(context);
    return Card(
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
                  // return Text(
                  //   utf8
                  //           .decode(base64.decode(data[state.farmIndex]))
                  //           .contains("Wait for")
                  //       ? "Wait for update"
                  //       : utf8.decode(base64.decode(data[state.farmIndex])),
                  //   style: const TextStyle(
                  //       fontSize: 28, fontWeight: FontWeight.bold),
                  // );
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
            ElevatedButton(
                onPressed: () =>
                    context.read<FarmCardCubit>().chooseIndex(1, data),
                child: const Text("Increase by 1"))
          ]),
    );
  }
}
