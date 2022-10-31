// Subscribe to topics
// Select devices to sub and immidiately fetch
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DeviceSelector extends StatelessWidget {
  List devices = [];
  List devicesName = [];

  List targetDevices = [];
  DeviceSelector({Key? key, required this.devices}) : super(key: key) {
    _getOnlyNameOfDevice(devices);
  }

  _getOnlyNameOfDevice(List dev) {
    dev.forEach((element) {
      devicesName.add(element["SerialNumber"]);
    });
  }

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
          // Container(
          //   child: const Text(
          //     "Device Selector",
          //     style: TextStyle(fontSize: 20),
          //   ),
          // ),
          Row(children: [
            Text(
              "Device Selector",
              style: TextStyle(fontSize: 20),
            ),
            IconButton(
                onPressed: () => Navigator.pop(context, targetDevices),
                icon: Icon(Icons.add_box))
          ]),
          Divider(),
          ListView.builder(
            shrinkWrap: true,
            itemCount: devicesName.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(devicesName[index]),
                selected: true,
                onTap: () => showCupertinoDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) {
                    targetDevices.add(devicesName[index]);
                    return CupertinoAlertDialog(
                      title: Text("Added ${devicesName[index]} to list"),
                      content: Text(
                          "Content will start to load after went back to the main page."),
                    );
                  },
                ),
              );
            },
          ),
        ]),
      )),
    );
  }
}
