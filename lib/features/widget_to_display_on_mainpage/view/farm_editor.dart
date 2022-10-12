import 'dart:convert';
import 'package:flutter/material.dart';

decodeAndRemovePadding(String encodedFarmName) {
  var dec = utf8.decode(base64.decode(encodedFarmName));
  // Check empty farm
  if (dec.contains("Wait for")) return "Wait for update";
  // Check padding
  int countZero = 0;
  var temp = dec.split('');
  for (int i = 0; i < temp.length; i++) {
    if (temp[i].contains('0')) {
      if (temp[i + 1].contains('0')) {
        countZero = countZero + 1;
      } else if (!temp[i + 1].contains('0')) {
        countZero = countZero + 1;
        break;
      }
    }
  }
  return dec.replaceRange(0, countZero, '');
}

class FarmEditor extends StatelessWidget {
  List farm = [];

  FarmEditor({Key? key, required this.farm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: SafeArea(
          child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            child: const Text(
              "Farm Selector",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: farm.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(decodeAndRemovePadding(farm[index])),
                selected: true,
                onTap: () => Navigator.pop(context, index),
              );
            },
          ),
        ]),
      )),
    );
  }
}
