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
            Text(topicName.toString() + '    : ',style: TextStyle(fontSize: 16, color: Colors.black,fontWeight: FontWeight.w500)),
            Padding(
              padding: const EdgeInsets.fromLTRB(20,5,0,2),
              child: Container(
                height: 35,
                width: 150.0,
                decoration: BoxDecoration(
                      border: Border.all(
      width: 0.8,color: Colors.black
    ),
                      color: Colors.white60,
                      borderRadius: BorderRadius.all(Radius.circular(10) ),
                     
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 15,bottom: 2),
                  child: TextFormField(
                    decoration: InputDecoration(
        border: InputBorder.none,
      ),
                    maxLines: 1,
                    keyboardType: TextInputType.number,
                    enabled: true,
                    controller: controller,
                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 6, 57, 145),fontWeight: FontWeight.w500),
                    
                  ),
                ),
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
                threshTextField("Nitrogen       (N) ", nSlot),
                threshTextField("Phosphorus (P)", pSlot),
                threshTextField("Potassium  (K)", kSlot),
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
              //height: 200,
              decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0), bottomRight: Radius.circular(30)),
         
        ),
              //color: Colors.white,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0), bottomRight: Radius.circular(30)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade400,
              blurRadius: 5,
              offset: Offset(5, 5), // Shadow position
            ),
          ],
        ),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(30))),
          child: ExpansionTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(30))),
            title: const Text(
              "Threshold Notifications",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: false,
            collapsedBackgroundColor: Colors.orange.shade600,
            collapsedTextColor: Colors.white,
            textColor: Colors.orange.shade600,
            backgroundColor: Colors.white,
            collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(30))),
            children: [
              thresholdConfig(),
            ],
          ),
        ),
      ),
    );
  }
}
