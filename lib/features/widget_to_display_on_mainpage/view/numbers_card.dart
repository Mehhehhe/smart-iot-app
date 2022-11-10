import 'dart:convert';

import 'package:flutter/material.dart';

class numberCard extends StatefulWidget {
  List<Map> inputData;

  numberCard({Key? key, required this.inputData}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _numberCardState();
}

class _numberCardState extends State<numberCard> {
  late List<Map> data;

  void _setLatest(List<Map> target) {
    var latestList = <Map>[];
    for (var data_map in target) {
      var tempMap = {};
      final cardName = data_map["FromDevice"];
      final latestData = json.decode(data_map["Data"]);
      final lat = latestData[0];
      print("{$cardName: ${latestData[latestData.length - 1]}}");
      tempMap = {cardName: latestData[latestData.length - 1]};
      latestList.add(tempMap);
      tempMap = {};
    }
    setState(() {
      data = latestList;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      data = widget.inputData;
      _setLatest(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return GridView.builder(
      shrinkWrap: true,
      itemCount: data.length,
      itemBuilder: (context, index) =>
          Card(child: Text(data[index].toString())),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    );
  }
}
