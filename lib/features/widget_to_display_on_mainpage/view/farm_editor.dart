import 'dart:convert';

import 'package:flutter/material.dart';

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
                title: Text(utf8.decode(base64.decode(farm[index]))),
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
