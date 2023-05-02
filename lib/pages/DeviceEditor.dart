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

  // Threshold setting
  // Return 1 if single value and >1 if multiple
  // ignore: long-method
  thresholdConfig() {
    // Input: deviceName

    ThresholdDatabase thd = ThresholdDatabase.instance;
    // String id = sha1.convert(utf8.encode(widget.deviceName)).toString();

    threshTextField(topicName, controller) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(topicName.toString()),
            Container(
              width: 50.0,
              child: TextFormField(
                maxLines: 1,
                keyboardType: TextInputType.number,
                enabled: true,
                controller: controller,
              ),
            ),
          ],
        );

    combineForSave(nSlot, pSlot, kSlot) => [nSlot, pSlot, kSlot];

    saveButton(texts) => TextButton(
          onPressed: () async {
            bool isMulti = texts.runtimeType == List;
            // print("[Press&Save] ${texts[2].text}");
            String val = isMulti
                ? "${texts[0].text}/${texts[1].text}/${texts[2].text}"
                : texts.text;

            thd.add({
              "_id": sha1.convert(utf8.encode(widget.deviceName)).toString(),
              "_threshVal": isMulti ? val : texts.text,
            });
          },
          child: const Text("Save"),
        );

    // ignore: long-method
    placeTextInForm() => FutureBuilder(
          future: thd.getThresh(widget.deviceName),
          builder: (context, snapshot) {
            // check
            List<Widget> widgetList = [];
            if (widget.deviceName.contains("NPK")) {
              // multi
              print("fetch get ${snapshot.data}");
              Map value = snapshot.data as Map? ??
                  {
                    "N": 0.0,
                    "P": 0.0,
                    "K": 0.0,
                  };

              TextEditingController nSlot =
                  TextEditingController(text: value["N"].toString());
              TextEditingController pSlot =
                  TextEditingController(text: value["P"].toString());
              TextEditingController kSlot =
                  TextEditingController(text: value["K"].toString());

              widgetList.addAll([
                threshTextField("N", nSlot),
                threshTextField("P", pSlot),
                threshTextField("K", kSlot),
                saveButton(combineForSave(
                  nSlot,
                  pSlot,
                  kSlot,
                )),
              ]);
            } else {
              // single
              TextEditingController defaultController =
                  TextEditingController(text: snapshot.data.toString());
              widgetList.addAll([
                threshTextField("Threshold", defaultController),
                saveButton(defaultController),
              ]);
            }

            return Container(
              color: Colors.orange.shade100,
              child: ListView(
                shrinkWrap: true,
                children: [...widgetList],
              ),
            );
          },
        );

    return placeTextInForm();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        "Threshold Notifications",
        style: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      initiallyExpanded: false,
      backgroundColor: Colors.orange.shade300,
      collapsedBackgroundColor: Colors.orange.shade500,
      textColor: Colors.black,
      children: [
        thresholdConfig(),
      ],
    );
  }
}
