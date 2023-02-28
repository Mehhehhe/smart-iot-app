import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/db/threshold_settings.dart';

class DeviceEditor extends StatefulWidget {
  final String deviceName;

  const DeviceEditor({Key? key, required this.deviceName}) : super(key: key);

  @override
  State createState() => _DeviceEditor();
}

class _DeviceEditor extends State<DeviceEditor> {
  TextEditingController thresholdController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Center(
    //     child: Column(
    //       children: [
    //         const Text("Threshold"),
    //         TextFormField(
    //           controller: thresholdController,
    //           enabled: true,
    //         ),
    //         TextButton(
    //           onPressed: () async {
    //             SharedPreferences instance =
    //                 await SharedPreferences.getInstance();
    //             instance.setString(
    //               "${widget.deviceName}.thresh",
    //               thresholdController.text,
    //             );
    //           },
    //           child: const Text("Save"),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
    return ExpansionTile(
      title: const Text("Settings"),
      initiallyExpanded: false,
      children: [
        Container(
          width: 300,
          height: 100,
          child: Row(
            children: [
              const Text("Threshold"),
              Expanded(
                child: TextFormField(
                  maxLines: 1,
                  controller: thresholdController,
                  enabled: true,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          child: Text("Save"),
          onPressed: () async {
            // save threshold to thresh table.
            ThresholdDatabase thd = ThresholdDatabase.instance;
            thd.add({
              "_id":
                  "${sha1.convert(utf8.encode(widget.deviceName)).toString()}",
              "_threshVal": num.parse(
                thresholdController.text,
              ),
            });
            print(await thd.getAllAvailableThresh());
          },
        ),
      ],
    );
  }
}
