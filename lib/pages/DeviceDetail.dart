import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/live_data_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/graph_in_farm_card.dart';
import 'package:smart_iot_app/model/ChartDataModel.dart';
import 'package:smart_iot_app/pages/DeviceEditor.dart';

class DeviceDetail extends StatelessWidget {
  Map detail;
  List<Map> liveData = [];
  List<Map> latestDatePlaceholder = [];
  List<ChartData> dataToPlot = [];
  List<ChartData> multiDataToPlot = [];

  String serial;
  String location;

  List graphTypes = ["line", "bar", "pie"];

  DeviceDetail({
    Key? key,
    required this.detail,
    required this.serial,
    required this.location,
    required this.latestDatePlaceholder,
  }) : super(key: key);

  // Handle adding new data from the active device
  // ignore: todo
  // - TODO: add base data from the database,
  //    so the plot is not empty and still can display some data.
  void insertChartData(String data) {
    var temp = json.decode(data);
    bool deviceState = temp["State"];
    DateTime deviceTimeStamp =
        DateTime.fromMillisecondsSinceEpoch(temp["TimeStamp"]).toUtc();
    // print("[ValueCheckType] ${temp} ${temp["Value"].runtimeType}");
    // print("\n\n[Debug] ${temp["Value"].runtimeType}, ${temp["Value"]}\n\n");
    if (temp["Value"].runtimeType == double ||
        temp["Value"].runtimeType == int) {
      // double
      double v = double.parse(temp["Value"].toString());
      // Although the value is single, the value must still pass on as List.
      List value = [v];

      dataToPlot.add(ChartData(
        deviceTimeStamp,
        value,
        detail["Location"] ?? location,
      ));
    } else {
      if (temp["Value"] == null || temp["Value"].runtimeType == bool) {
        return;
      }
      // print("${temp["Value"]["N"]} ${temp["Value"]["N"].runtimeType}");
      // Loop through the values of nested Map
      Map<String, dynamic> subMap = Map.castFrom(temp["Value"]);

      multiDataToPlot.add(
        ChartData(
          deviceTimeStamp,
          [subMap],
          detail["Location"] ?? location,
          name: "NPK",
        ),
      );
    }
    // dataToPlot
    //     .add(ChartData(deviceTimeStamp, value, detail["Location"] ?? location));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            //color: Colors.grey.shade200
            image: DecorationImage(
                //opacity: 100,
                image: NetworkImage(
                    "https://t4.ftcdn.net/jpg/05/42/77/55/360_F_542775509_kukwGVyxAEiLtbWF54xIHtQzil8QAwLC.jpg"),
                fit: BoxFit.cover),
          ),
        ),
        elevation: 5,
        centerTitle: true,
        title: Text(
          "${detail["DeviceName"] ?? serial}",
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(0),
            child: ListView(
              shrinkWrap: true,
              children: [
                BlocBuilder<UserDataStreamBloc, UserDataStreamState>(
                  builder: (context, state) {
                    bool isFan =
                        !detail["SerialNumber"].toString().contains("FAN") ||
                            !serial.contains("FAN");
                    if (state.data != "" || state.data != null) {
                      if (state.data.isEmpty) {
                        liveData.add(latestDatePlaceholder[0]
                            [detail["SerialNumber"] ?? serial]);
                        if (isFan) {
                          if (latestDatePlaceholder[0]
                                      [detail["SerialNumber"] ?? serial]
                                  .runtimeType !=
                              bool) {
                            insertChartData(
                              json.encode(
                                latestDatePlaceholder[0]
                                    [detail["SerialNumber"] ?? serial],
                              ),
                            );
                          } else {
                            String trimmedData =
                                state.data.substring(1, state.data.length - 1);
                            liveData.add(json.decode(trimmedData));
                            insertChartData(trimmedData);
                          }
                        }
                      }

                      return Column(
                        children: [
                          Device_Detail(),
                          // DropdownButton(
                          //   items: graphTypes
                          //       .map((e) => DropdownMenuItem(
                          //             value: e,
                          //             child: Text(e),
                          //           ))
                          //       .toList(),
                          //   onChanged: (value) => print(value),
                          // ),
                          if (detail["Type"].contains("MOISTURE") &&
                              liveData != null)
                            //Moi_Graph()
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(30)),
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
                                    title: Text(
                                      "Moisture Graph",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    initiallyExpanded: false,
                                    collapsedBackgroundColor:
                                        Colors.orange.shade800,
                                    collapsedTextColor: Colors.white,
                                    textColor: Colors.orange.shade800,
                                    //backgroundColor: Colors.red,
                                    collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(30))),
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(30)),
                                        ),
                                        height: 370,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //color: Colors.white,
                                        child: BlocProvider(
                                          create: (_) => LiveDataCubit(
                                              liveData, dataToPlot),
                                          child: LiveChart(
                                            type: 'line',
                                            devices: liveData,
                                            detail: detail,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (detail["Type"].contains("LIGHT") &&
                              liveData != null)
                            //Moi_Graph()
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(30)),
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
                                    title: Text(
                                      "Light Graph",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    initiallyExpanded: false,
                                    collapsedBackgroundColor:
                                        Colors.orange.shade800,
                                    collapsedTextColor: Colors.white,
                                    textColor: Colors.orange.shade800,
                                    //backgroundColor: Colors.red,
                                    collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(30))),
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(30)),
                                        ),
                                        height: 370,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //color: Colors.white,
                                        child: BlocProvider(
                                          create: (_) => LiveDataCubit(
                                              liveData, dataToPlot),
                                          child: LiveChart(
                                            type: 'line',
                                            devices: liveData,
                                            detail: detail,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (detail["Type"].contains("NPK") &&
                              liveData != null)
                            //NPK_Graph()
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(0),
                                      bottomRight: Radius.circular(30)),
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
                                      'NPK Graph',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    initiallyExpanded: false,
                                    collapsedBackgroundColor:
                                        Colors.orange.shade800,
                                    collapsedTextColor: Colors.white,
                                    textColor: Colors.orange.shade800,
                                    //backgroundColor: Colors.red,
                                    collapsedShape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(0),
                                            bottomRight: Radius.circular(30))),
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(0),
                                              bottomRight: Radius.circular(30)),
                                        ),
                                        height: 370,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        //color: Colors.white,
                                        child: BlocProvider(
                                          create: (_) => LiveDataCubit(
                                            liveData,
                                            multiDataToPlot,
                                          ),
                                          child: LiveChart(
                                            type: 'line',
                                            devices: liveData,
                                            detail: detail,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else if (isFan)
                            const CircularProgressIndicator(),
                          if (isFan)
                            DeviceEditor(
                              deviceName: detail["SerialNumber"] ?? serial,
                            ),
                        ],
                      );
                    }

                    return const Text("Fetching data ... ");
                  },
                ),
                // Redirect to device editor page.
              ],
            ),
          ),
        ),
      ),
    );
  }

  //ignore: long-method
  Widget Device_Detail() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
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
                    bottomRight: Radius.circular(0))),
            title: const Text(
              'Details',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: false,
            collapsedBackgroundColor: Colors.orange.shade900,
            collapsedTextColor: Colors.white,
            textColor: Colors.orange.shade900,
            //backgroundColor: Colors.red,
            collapsedShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(0),
                    bottomRight: Radius.circular(30))),
            children: [
              Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
                  child: Container(
                    // width: MediaQuery.of(context).size.width * 0.9,
                    height: 170,

                    child: ListView.builder(
                      itemCount: detail.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        var dateCreate = "";
                        if (detail.entries.elementAt(index).key == "CreateAt") {
                          dateCreate = DateTime.fromMillisecondsSinceEpoch(
                            detail.entries.elementAt(index).value,
                          ).toLocal().toString();
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                              child: Text(
                                detail.entries.elementAt(index).key.toString(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
                              child: Text(
                                dateCreate == ""
                                    ? detail.entries
                                        .elementAt(index)
                                        .value
                                        .toString()
                                    : dateCreate,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
