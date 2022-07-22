import 'dart:convert';
import 'dart:ui';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:smart_iot_app/services/dataManagement.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';
import 'package:smart_iot_app/services/notification.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

class Manage_Page extends StatefulWidget {
  const Manage_Page(
      {Key? key,
      required this.device,
      required this.user,
      required this.userId})
      : super(key: key);

  final String device;
  final MQTTClientWrapper user;
  final String userId;

  @override
  State<Manage_Page> createState() => _Manage_PageState();
}

class _Manage_PageState extends State<Manage_Page> {
  _Manage_PageState() {
    timer = Timer.periodic(const Duration(seconds: 10), updateDataInGraph);
  }

  bool sensorValue = true;
  late DataPayload dataPayload;
  String status = "Status: Normal";
  double value = 0;
  double thresh = 0;
  bool toggle = false;
  late List<bool> switchToggles = <bool>[];

  Timer? timer;
  late List<_ChartData> chartData;
  ChartSeriesController? _chartSeriesController;
  static late MQTTClientWrapper newClient;

  final scaffKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _threshController = TextEditingController();

  Future<Map<String, dynamic>> getFutureUserDataMap() async {
    SmIOTDatabase db = SmIOTDatabase();
    Future<Map<String, dynamic>> dataF = db.getData(widget.userId);
    Map<String, dynamic> msg = await dataF;
    return msg;
  }

  @override
  void initState() {
    _controller.text = value.toString();
    chartData = <_ChartData>[
      _ChartData(DateTime.now(), 0.0),
    ];
    print(chartData.toString());
    setState(() {
      newClient = widget.user;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    chartData?.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  void updateInChartData(
      [bool? removeZeroInd, int? maxRange, List<int>? range]) {
    if (maxRange == null) {
      if (removeZeroInd == true) chartData.removeAt(0);
      _chartSeriesController!.updateDataSource(
          addedDataIndexes: <int>[chartData.length - 1],
          removedDataIndexes: <int>[0]);
      return;
    }
    if (chartData.length >= maxRange) {
      chartData.removeRange(range![0], range[1] - 1);
      updateInChartData(true);
    } else {
      _chartSeriesController!
          .updateDataSource(addedDataIndexes: <int>[chartData!.length - 1]);
    }
  }

  void updateDataInGraph(Timer timer) async {
    Stream<String> response = await newClient.subscribeToResponse();

    setState(() {
      response.forEach((element) {
        var sv = json.decode(element);
        Map jsonSV = Map<String, dynamic>.from(sv);
        jsonSV.map((key, value) {
          key = DateTime.parse(key).toLocal();
          value = Map<String, dynamic>.from(value);
          //updateInChartData(true);
          chartData.add(_ChartData(key, value["sensorVal"]));
          if (value["sensorVal"] >=
              double.parse(dataPayload.toJson()["userDevice"][widget.device]
                  ["userSensor"]["sensorThresh"]["sensor1"])) {
            NotifyUser notifyUser = NotifyUser();
            notifyUser.initialize();
            notifyUser.pushNotification(
                Importance.high,
                Priority.high,
                "Warning",
                "Value touched threshold",
                "Sensor's value reached the threshold value from your setting. Please check the timeline.");
          }
          return MapEntry(key, value);
        });
      });
      print(chartData.length);
      updateInChartData(null, 600, [0, 9]);
    });
  }

  void setBoolSwitches(int num) {
    if (switchToggles.isEmpty) {
      switchToggles = List.filled(num, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    updateDataInGraph;
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
                  children: <Widget>[carouselPlaceholder(), sensorSettings()],
                ),
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

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
              const Padding(
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
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    final Map? dataMapped = snapshot.data as Map?;
                    dataPayload = DataPayload.fromJson(dataMapped ?? {});
                    var check = dataPayload.checkDeviceStatus(widget.device);
                    if (check.length == 0) {
                      status = "Status: Normal";
                    } else {
                      status = "Status: Error";
                    }
                    return Container(
                      margin: const EdgeInsets.only(right: 42),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: status == "Status: Normal"
                                ? const Color.fromRGBO(5, 255, 0, 1.0)
                                : const Color.fromRGBO(255, 137, 137, 1.0),
                            width: 2),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(17),
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: status == "Status: Normal"
                              ? const Color.fromRGBO(5, 255, 0, 1.0)
                              : const Color.fromRGBO(255, 137, 137, 1.0),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 42.0, bottom: 10.0),
            child: Text(
              widget.device,
              style: const TextStyle(color: Colors.white, fontSize: 20),
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
      //padding: EdgeInsets.all(50.0),
      child: buildLiveChart(),
    );
  }

  SfCartesianChart buildLiveChart() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      backgroundColor: Colors.white,
      plotAreaBackgroundColor: Colors.white54,
      palette: const [
        Color.fromRGBO(208, 31, 49, 1.0),
        Color.fromRGBO(246, 129, 33, 1.0),
        Color.fromRGBO(251, 221, 11, 1.0),
        Color.fromRGBO(0, 123, 97, 1.0),
        Color.fromRGBO(0, 114, 185, 1.0),
      ],
      plotAreaBorderColor: Colors.grey,
      primaryXAxis: DateTimeAxis(
          enableAutoIntervalOnZooming: true,
          autoScrollingDelta: 3,
          autoScrollingDeltaType: DateTimeIntervalType.hours,
          title: AxisTitle(
              text: chartData.length <= 170
                  ? "Time in minute:seconds"
                  : chartData.length <= 3000
                      ? "Time in hours:minutes"
                      : "Time in hours"),
          intervalType: chartData.length <= 170
              ? DateTimeIntervalType.auto
              : chartData.length <= 3000
                  ? DateTimeIntervalType.minutes
                  : DateTimeIntervalType.hours,
          visibleMaximum: null),
      primaryYAxis: NumericAxis(
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(size: 0)),
      //enableAxisAnimation: true,
      series: <LineSeries<_ChartData, DateTime>>[
        LineSeries<_ChartData, DateTime>(
            onRendererCreated: (ChartSeriesController controller) {
              _chartSeriesController = controller;
            },
            enableTooltip: true,
            dataSource: chartData!,
            xValueMapper: (_ChartData inf, _) => inf.date,
            yValueMapper: (_ChartData inf, _) => inf.values)
      ],
      tooltipBehavior: TooltipBehavior(
          enable: true,
          elevation: 5,
          canShowMarker: false,
          activationMode: ActivationMode.singleTap,
          shared: true,
          header: "Sensor Value",
          format: '@ point.x, point.y',
          decimalPlaces: 2,
          textStyle: const TextStyle(fontSize: 20.0)),
      trackballBehavior: TrackballBehavior(
          activationMode: ActivationMode.singleTap,
          enable: true,
          shouldAlwaysShow: true,
          tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
          tooltipSettings: const InteractiveTooltip(enable: false),
          markerSettings: const TrackballMarkerSettings(
            markerVisibility: TrackballVisibilityMode.hidden,
          )),
    );
  }

  Widget sensorSettings() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Stack(
          children: [
            Container(
              height: 50,
              padding: const EdgeInsets.only(left: 40, top: 20),
              child: const Text(
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
                    return const CircularProgressIndicator();
                  } else if (snapshot.connectionState == ConnectionState.done) {
                    final Map? dataMapped = snapshot.data as Map?;
                    dataPayload = DataPayload.fromJson(dataMapped ?? {});
                    dataPayload = dataPayload.decode(dataPayload);
                    Map device = dataPayload.toJson();
                    device.removeWhere((key, value) => key != "userDevice");

                    device = device.transformAndLocalize();
                    setBoolSwitches(dataPayload
                        .userDevice![widget.device]["userSensor"]["sensorName"]
                        .length);

                    return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: dataPayload
                                .userDevice![widget.device]["userSensor"]
                                    ["sensorName"]
                                .length ??
                            1,
                        itemBuilder: (context, index) {
                          return Card(
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            margin: const EdgeInsets.only(
                                left: 25, right: 25, bottom: 10),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 10, top: 10),
                                  child: Text(
                                    "${dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index]}",
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Padding(
                                      padding:
                                          EdgeInsets.only(left: 10, top: 10),
                                      child: Text(
                                        "Turn on notification",
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          right: 10, top: 10),
                                      child: CupertinoSwitch(
                                        value: switchToggles[index],
                                        onChanged: (bool value) {
                                          setState(() {
                                            switchToggles[index] = value;
                                          });
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
                                        padding:
                                            const EdgeInsets.only(left: 10),
                                        child: TextButton(
                                            onPressed: () {
                                              Scaffold.of(context)
                                                  .showBottomSheet<void>(
                                                (context) {
                                                  return BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 3,
                                                        sigmaY: 3,
                                                        tileMode:
                                                            TileMode.decal),
                                                    child: Container(
                                                      height: 200,
                                                      color: Colors.indigo,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Text(
                                                              "${dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index]}",
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 24,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 30),
                                                              child: Text(
                                                                "Status: ${dataPayload.userDevice![widget.device]["userSensor"]["sensorStatus"][dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index].toString()] == true ? "Normal" : "Error"}",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          30),
                                                              child: Text(
                                                                "Actuator ${dataPayload.userDevice![widget.device]["actuator"]["actuatorId"][index]}: ${dataPayload.userDevice![widget.device]["actuator"]["state"][dataPayload.userDevice![widget.device]["actuator"]["actuatorId"][index].toString()] == "normal" ? "Normal" : "Error"}",
                                                                style: const TextStyle(
                                                                    color: Colors
                                                                        .amber,
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  "Close",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize:
                                                                          19),
                                                                ))
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                elevation: 10.0,
                                              );
                                            },
                                            child: const Text(
                                              "More detail",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 26, 255, 1.0),
                                                  fontSize: 15),
                                            ))),
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(right: 10),
                                        child: TextButton(
                                            onPressed: () {
                                              value = double.parse(device[
                                                  "userDevice.${widget.device}.actuator.value.${dataPayload.userDevice![widget.device]["actuator"]["actuatorId"][index].toString()}"]);
                                              _controller.text =
                                                  value.toStringAsFixed(1);
                                              Scaffold.of(context)
                                                  .showBottomSheet<void>(
                                                (context) {
                                                  return BackdropFilter(
                                                    filter: ImageFilter.blur(
                                                        sigmaX: 3,
                                                        sigmaY: 3,
                                                        tileMode:
                                                            TileMode.decal),
                                                    child: Container(
                                                      height: 400,
                                                      color: Colors.indigo,
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .only(
                                                                        left:
                                                                            20,
                                                                        bottom:
                                                                            50),
                                                                child: Text(
                                                                  "${dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index]}",
                                                                  style:
                                                                      const TextStyle(
                                                                    fontSize:
                                                                        24,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            StatefulBuilder(
                                                              builder: (context,
                                                                  setState) {
                                                                return Container(
                                                                  child: Column(
                                                                    children: [
                                                                      Slider(
                                                                        value:
                                                                            value,
                                                                        min:
                                                                            0.0,
                                                                        max:
                                                                            200.0,
                                                                        divisions:
                                                                            2000,
                                                                        label: value
                                                                            .toStringAsFixed(1),
                                                                        onChanged:
                                                                            (double
                                                                                newValue) {
                                                                          setState(
                                                                              () {
                                                                            value =
                                                                                double.parse(newValue.toStringAsFixed(1));
                                                                            _controller.text =
                                                                                value.toStringAsFixed(1);
                                                                          });
                                                                        },
                                                                        activeColor:
                                                                            Colors.green,
                                                                        inactiveColor:
                                                                            Colors.grey,
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                50,
                                                                            bottom:
                                                                                20),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                                child: InkWell(
                                                                              child: const Icon(
                                                                                Icons.remove,
                                                                                size: 18,
                                                                                color: Colors.white,
                                                                              ),
                                                                              onTap: () {
                                                                                value -= 0.1;
                                                                                _controller.text = (value > 0 ? value : 0).toStringAsFixed(1);
                                                                              },
                                                                            )),
                                                                            Container(
                                                                                width:
                                                                                    100,
                                                                                color: Colors
                                                                                    .white,
                                                                                child: TextFormField(textAlign: TextAlign.center, decoration: InputDecoration(contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))), controller: _controller, keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true), inputFormatters: [
                                                                                  LengthLimitingTextInputFormatter(6)
                                                                                ])),
                                                                            Container(
                                                                                child: InkWell(
                                                                              child: const Icon(
                                                                                Icons.add,
                                                                                size: 18,
                                                                                color: Colors.white,
                                                                              ),
                                                                              onTap: () {
                                                                                setState(() {
                                                                                  value += 0.1;
                                                                                  if (value > 200.0) {
                                                                                    value = 200;
                                                                                  }
                                                                                  _controller.text = value.toStringAsFixed(1);
                                                                                });
                                                                              },
                                                                            )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                20,
                                                                            bottom:
                                                                                20),
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            const Text(
                                                                              "Threshold : ",
                                                                              style: TextStyle(color: Colors.white, fontSize: 16),
                                                                            ),
                                                                            Container(
                                                                              width: 75,
                                                                              color: Colors.grey,
                                                                              child: TextFormField(
                                                                                textAlign: TextAlign.center,
                                                                                controller: _threshController,
                                                                                keyboardType: TextInputType.number,
                                                                                decoration: InputDecoration(contentPadding: const EdgeInsets.all(8), border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
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
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Close",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              19),
                                                                    )),
                                                                TextButton(
                                                                    onPressed:
                                                                        () async {
                                                                      // Localized thresh and actuator setting
                                                                      // - Send to MQTT to set threshold (topic:=device_name/threshold/set)
                                                                      // - Send to MQTT to set actuator (topic:=device_name/actuator/value/set)
                                                                      Map payload =
                                                                          {
                                                                        "id":
                                                                            "",
                                                                        "actuator_value":
                                                                            _controller.text,
                                                                        "threshold":
                                                                            _threshController.text
                                                                      };
                                                                      payload["id"] =
                                                                          "${widget.device.toString()}.${dataPayload.userDevice![widget.device]["userSensor"]["sensorName"][index]}";

                                                                      String
                                                                          pubStateCheck =
                                                                          await newClient
                                                                              .publishSettings(payload);

                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      "Save Setting",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              19),
                                                                    )),
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
                                            child: const Text(
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
                    return const CircularProgressIndicator();
                  }
                })
          ],
        ),
      ],
    );
  }
}

class _ChartData {
  _ChartData(this.date, this.values);
  final DateTime date;
  final double values;
}
