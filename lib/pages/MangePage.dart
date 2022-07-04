import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_iot_app/services/dataManagement.dart';
import 'package:smart_iot_app/services/authentication.dart';

class Manage_Page extends StatefulWidget {
  const Manage_Page(
      {Key? key,
      required this.auth,
      required this.userId,
      required this.device})
      : super(key: key);

  final BaseAuth auth;
  final String userId;
  final String device;

  @override
  State<Manage_Page> createState() => _Manage_PageState();
}

class _Manage_PageState extends State<Manage_Page> {
  bool sensorValue = true;
  late DataPayload dataPayload;
  String status = "Status: Normal";
  double value=0;
  double thresh = 0;

  final scaffKey = GlobalKey<ScaffoldState>();
  TextEditingController _controller = TextEditingController();
  TextEditingController _threshController = TextEditingController();

  Future<Map<String, dynamic>> getFutureUserDataMap() async {
    SmIOTDatabase db = SmIOTDatabase();
    Future<Map<String, dynamic>> dataF = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataF;
    return msg;
  }

  @override
  void init() async {
    super.initState();
    _controller.text = value.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(0, 23, 104, 1.0),
        elevation: 0.0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 50),
        decoration:
            const BoxDecoration(color: Color.fromRGBO(235, 235, 235, 1.0)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            managePageHeader(),
            Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      carouselPlaceholder(),
                      sensorSettings()
                    ],
                  ),
                ),
            ),
          ],
        ),
        /*
        Column(
          children: <Widget>[
            managePageHeader(),
            carouselPlaceholder(),
            sensorSettings()
            //_showForm(),
          ],
        ),*/
      ),
      extendBodyBehindAppBar: true,
    );
  }
/*
  Widget _showForm() {
    return Form(
      //key: _formKey,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[deviceName(), deviceImage(), mangeSensor()],
        ),
      ),
    );
  }*/

  Widget managePageHeader() {
    return Container(
      margin: const EdgeInsets.only(top: 35),
      color: const Color.fromRGBO(0, 23, 104, 1.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.15,
      child: Column(
        verticalDirection: VerticalDirection.down,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 42.0),
                child: Text(
                  "Device :",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FutureBuilder(
                future: getFutureUserDataMap(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.none &&
                      snapshot.hasData == false) {
                    return Container();
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting &&
                      snapshot.hasData == false) {
                    return CircularProgressIndicator();
                  } else if (snapshot.connectionState ==
                      ConnectionState.done) {
                    final Map? dataMapped = snapshot.data as Map?;
                    dataPayload = DataPayload.fromJson(dataMapped ?? {});
                    var check = dataPayload.checkDeviceStatus(widget.device);
                    if(check.length == 0){
                      status = "Status: Normal";
                    } else{
                      status = "Status: Error";
                    }

                    return Container(
                      margin: EdgeInsets.only(right: 42),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: status == "Status: Normal"? Color.fromRGBO(5, 255, 0, 1.0):Color.fromRGBO(255, 137, 137, 1.0),
                            width: 2
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(17),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: status == "Status: Normal"? Color.fromRGBO(5, 255, 0, 1.0):Color.fromRGBO(255, 137, 137, 1.0),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(left: 42.0, bottom: 10.0),
            child: Text(
              "${widget.device}",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          const Divider(
            color: Colors.white,
            indent: 36,
            endIndent: 36,
          ),
        ],
      ),
    );
  }

  Widget carouselPlaceholder() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.4,
      color: Colors.grey,
      padding: EdgeInsets.all(50.0),
      child: Text(
        "Placeholder for images and graphs",
        style: TextStyle(fontSize: 16, height: 10),
      ),
    );
  }

  Widget sensorSettings() {

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: [
              Container(
                height: 50,
                padding: EdgeInsets.only(left: 40, top: 20),
                child: Text(
                  "Sensor Settings",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w400),
                ),
              ),
              FutureBuilder(
                  future: getFutureUserDataMap(),
                  builder: (context, snapshot) {

                    if (snapshot.connectionState == ConnectionState.none &&
                        snapshot.hasData == false) {
                      return Container();
                    } else if (snapshot.connectionState ==
                            ConnectionState.waiting &&
                        snapshot.hasData == false) {
                      return CircularProgressIndicator();
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      final Map? dataMapped = snapshot.data as Map?;
                      dataPayload = DataPayload.fromJson(dataMapped ?? {});
                      dataPayload = dataPayload.decode(dataPayload);
                      Map device = dataPayload.toJson();
                      device.removeWhere((key, value) => key != "userDevice");

                      device = device.transformAndLocalize();

                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: dataPayload
                              .userDevice!["${widget.device}"]["userSensor"]
                                  ["sensorName"]
                              .length??1,
                          itemBuilder: (context, index) {
                            return Card(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              margin: EdgeInsets.only(left: 25, right: 25, bottom: 10),
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(left: 10, top: 10),
                                    child: Text(
                                      "${dataPayload.userDevice!["${widget.device}"]["userSensor"]["sensorName"][index]}",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding:
                                        EdgeInsets.only(left: 10, top: 10),
                                        child: Text(
                                          "Turn on notification",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                        EdgeInsets.only(right: 10, top: 10),
                                        child: CupertinoSwitch(
                                          value: true,
                                          onChanged: (bool value) {

                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: TextButton(
                                              onPressed: () {
                                                Scaffold.of(context).showBottomSheet<void>((context){
                                                  return BackdropFilter(
                                                      filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.decal),
                                                      child: Container(
                                                      height: 200,
                                                      color: Colors.indigo,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                                "${dataPayload.userDevice!["${widget.device}"]["userSensor"]["sensorName"][index]}",
                                                              style: TextStyle(
                                                                fontSize: 24,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 30),
                                                              child: Text(
                                                                  "Status: ${dataPayload.userDevice!["${widget.device}"]["userSensor"]["sensorStatus"][dataPayload.userDevice!["${widget.device}"]["userSensor"]["sensorName"][index].toString()] == true ? "Normal":"Error"}",
                                                                style: TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 16
                                                                ),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets.only(top: 10,bottom: 30),
                                                              child: Text(
                                                                "Actuator ${dataPayload.userDevice!["${widget.device}"]["actuator"]["actuatorId"][index]}: ${dataPayload.userDevice!["${widget.device}"]["actuator"]["state"][dataPayload.userDevice!["${widget.device}"]["actuator"]["actuatorId"][index].toString()]== "normal" ? "Normal":"Error"}",
                                                                style: TextStyle(
                                                                  color: Colors.amber,
                                                                  fontSize: 16
                                                                ),
                                                              ),
                                                            ),
                                                            TextButton(
                                                                onPressed: (){
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Text(
                                                                  "Close",
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 19
                                                                  ),
                                                                )
                                                            )

                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                    elevation: 10.0,
                                                );
                                              },
                                              child: Text(
                                                "More detail",
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        0, 26, 255, 1.0),
                                                    fontSize: 15),
                                              ))),
                                      Padding(
                                          padding: EdgeInsets.only(right: 10),
                                          child: TextButton(
                                              onPressed: () {
                                                value = double.parse(device["userDevice.${widget.device}.actuator.value.${dataPayload.userDevice!["${widget.device}"]["actuator"]["actuatorId"][index].toString()}"]);
                                                _controller.text = value.toStringAsFixed(1);
                                                Scaffold.of(context).showBottomSheet<void>((context){
                                                  return BackdropFilter(
                                                    filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3, tileMode: TileMode.decal),
                                                    child: Container(
                                                      height: 400,
                                                      color: Colors.indigo,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: Padding(
                                                                padding: EdgeInsets.only(left: 20, bottom: 50),
                                                                child: Text(
                                                                  "${dataPayload.userDevice!["${widget.device}"]["userSensor"]["sensorName"][index]}",
                                                                  style: TextStyle(
                                                                    fontSize: 24,
                                                                    color: Colors.white,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            StatefulBuilder(
                                                                builder: (context, setState) {
                                                                  return Container(
                                                                    child: Column(
                                                                      children: [
                                                                        Slider(
                                                                          value: value,
                                                                          min: 0.0,
                                                                          max: 200.0,
                                                                          divisions: 2000,
                                                                          label: value.toStringAsFixed(1),
                                                                          onChanged: (double newValue) {
                                                                            setState(() {
                                                                              value = double.parse(newValue.toStringAsFixed(1));
                                                                              _controller.text = value.toStringAsFixed(1);
                                                                            });
                                                                          },
                                                                          activeColor: Colors.green,
                                                                          inactiveColor: Colors.grey,
                                                                        ),
                                                                        Padding(
                                                                            padding:EdgeInsets.only(top:50, bottom: 20),
                                                                            child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              Container(
                                                                                  child: InkWell(
                                                                                    child: Icon(
                                                                                      Icons.remove,
                                                                                      size: 18,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    onTap: (){
                                                                                      value -= 0.1;
                                                                                      _controller.text = (value > 0 ? value:0).toStringAsFixed(1);
                                                                                    },
                                                                                  )
                                                                              ),
                                                                              Container(
                                                                                  width: 100,
                                                                                  color: Colors.white,
                                                                                  child: TextFormField(
                                                                                textAlign: TextAlign.center,
                                                                                decoration: InputDecoration(
                                                                                    contentPadding: EdgeInsets.all(8),
                                                                                    border: OutlineInputBorder(
                                                                                        borderRadius: BorderRadius.circular(5)
                                                                                    )
                                                                                ),
                                                                                    controller: _controller,
                                                                                    keyboardType: TextInputType.numberWithOptions(
                                                                                      decimal: true,
                                                                                      signed: true
                                                                                    ),
                                                                                      inputFormatters: [LengthLimitingTextInputFormatter(6)]
                                                                              )
                                                                              ),
                                                                              Container(
                                                                                  child: InkWell(
                                                                                    child: Icon(
                                                                                      Icons.add,
                                                                                      size: 18,
                                                                                      color: Colors.white,
                                                                                    ),
                                                                                    onTap: (){
                                                                                      setState((){
                                                                                        value += 0.1;
                                                                                        if(value > 200.0){
                                                                                          value=200;
                                                                                        }
                                                                                        _controller.text = value.toStringAsFixed(1);
                                                                                      });
                                                                                    },
                                                                                  )
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Padding(
                                                                          padding: EdgeInsets.only(top:20, bottom:20),
                                                                          child: Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              Text(
                                                                                  "Threshold : ",
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontSize: 16
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                width: 75,
                                                                                color: Colors.grey,
                                                                                child: TextFormField(
                                                                                  textAlign: TextAlign.center,
                                                                                  controller: _threshController,
                                                                                  keyboardType: TextInputType.number,
                                                                                  decoration: InputDecoration(
                                                                                      contentPadding: EdgeInsets.all(8),
                                                                                      border: OutlineInputBorder(
                                                                                          borderRadius: BorderRadius.circular(5)
                                                                                      )
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  );
                                                                },
                                                            ),
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                TextButton(
                                                                    onPressed: (){
                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Close",
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 19
                                                                      ),
                                                                    )
                                                                ),
                                                                TextButton(
                                                                    onPressed: (){
                                                                      print("Thresh set to ${_threshController.text}");
                                                                      dataPayload.userDevice![widget.device]["userSensor"]["sensorThresh"][dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index].toString()] = _threshController.text;
                                                                      dataPayload.userDevice![widget.device]["actuator"]["value"][dataPayload.userDevice![widget.device]["actuator"]["actuatorId"][index].toString()] = _controller.text;
                                                                      Map device = dataPayload.toJson();
                                                                      Map<String, dynamic> data = <String,dynamic>{};

                                                                      // Remove unused data
                                                                      device.removeWhere((key, value) => key != "userDevice");
                                                                      device["userDevice"][widget.device]["userSensor"].remove('sensorName');
                                                                      device["userDevice"][widget.device]["userSensor"].remove('sensorType');
                                                                      device["userDevice"][widget.device]["userSensor"].remove('sensorValue');

                                                                      device["userDevice"][widget.device]["actuator"].remove('actuatorId');
                                                                      device["userDevice"][widget.device]["actuator"].remove('type');
                                                                      device["userDevice"][widget.device]["actuator"].remove('state');

                                                                      // Building a block process

                                                                      ActuatorDataBlock act = ActuatorDataBlock.createForSending(device["userDevice"][widget.device]["actuator"]["value"]);
                                                                      var encryptedAct = ActuatorDataBlock.createEncryptedModelWithOnlyValue(act);

                                                                      SensorDataBlock sen = SensorDataBlock.createForSending(
                                                                          Map<String,bool>.from(device["userDevice"][widget.device]["userSensor"]["sensorStatus"]),
                                                                          device["userDevice"][widget.device]["userSensor"]["sensorTiming"],
                                                                          device["userDevice"][widget.device]["userSensor"]["calibrateValue"],
                                                                          device["userDevice"][widget.device]["userSensor"]["sensorThresh"]
                                                                      );
                                                                      //print(sen.toJsonForSending());
                                                                      DeviceBlock dev = DeviceBlock.createPartialEncryptedModel(sen, encryptedAct);
                                                                      //print(dev.toJsonForSending());
                                                                      DataPayload dataP = DataPayload.createForSending({widget.device:dev.toJsonForSending()});
                                                                      //print("Json: ${dataP.toJsonForSending()}");
                                                                      device = dataP.toJsonForSending().transformAndLocalize();
                                                                      data = Map<String, dynamic>.from(device);
                                                                      //print(data);
                                                                      //device = device.transformAndLocalize();
                                                                      //data = Map<String, dynamic>.from(device);
                                                                      SmIOTDatabase db = SmIOTDatabase();

                                                                      db.sendData(widget.userId, data);
                                                                      print("Send successfully!");

                                                                      Navigator.pop(context);
                                                                    },
                                                                    child: Text(
                                                                      "Save Setting",
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontSize: 19
                                                                      ),
                                                                    )
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                  elevation: 10.0,
                                                );
                                              },
                                              child: Text(
                                                "Configure",
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        0, 26, 255, 1.0),
                                                    fontSize: 15),
                                              )))
                                    ],
                                  ),
                                ],
                              ),
                            );
                          });
                    } else {
                      return CircularProgressIndicator();
                    }
                  })
            ],
          ),
        ],
      ),
    );
  }
}

