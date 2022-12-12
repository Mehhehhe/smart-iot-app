import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;

class ReportCard {
  // Top Section requirements
  String farmName;
  final DateTime _generatedTime = DateTime.now().toLocal();
  String whoGenerated;
  // Information
  List<Map<String, String>> devicesWithType;
  String location;
  Widget generatedChart;
  List<Map> dataResponse;

  ReportCard(this.farmName, this.devicesWithType, this.generatedChart,
      this.location, this.whoGenerated, this.dataResponse);

  _mapDevicesToTableRow() {
    List<pdf.TableRow> tb = [];
    // In 1 TableRow has 2 Column and in each column has 1 Text widget.
    for (var element in devicesWithType) {
      var temp = <pdf.Widget>[];
      temp.add(pdf.Column(children: [
        pdf.Padding(
            padding: pdf.EdgeInsets.all(5.0),
            child: pdf.Text(element["Name"].toString()))
      ]));
      temp.add(pdf.Column(children: [
        pdf.Padding(
            padding: pdf.EdgeInsets.all(5.0),
            child: pdf.Text(element["Type"].toString()))
      ]));
      tb.add(pdf.TableRow(
          children: temp,
          decoration: pdf.BoxDecoration(
              border: pdf.Border.all(
                  color: PdfColor.fromHex("000000"), width: 1.0))));
      temp = <pdf.Widget>[];
    }
    return tb;
  }

  FutureOr<Uint8List> make() async {
    final pf = pdf.Document();
    final deviceRow = _mapDevicesToTableRow();
    pf.addPage(
      pdf.Page(
          build: (context) => pdf.Column(children: [
                // Top section
                pdf.Row(
                    mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                    children: [
                      pdf.Text("Report of $farmName",
                          style: const pdf.TextStyle(fontSize: 30)),
                      pdf.Column(
                          mainAxisAlignment: pdf.MainAxisAlignment.end,
                          children: [
                            pdf.Text("${_generatedTime.toString()}"),
                            pdf.Text("By $whoGenerated")
                          ])
                    ]),
                pdf.Divider(),
                pdf.Row(
                    mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
                    children: [
                      pdf.Column(children: [
                        pdf.Padding(
                            child: pdf.Text("Devices Table"),
                            padding: pdf.EdgeInsets.all(5.0)),
                        pdf.Divider(),
                        pdf.Table(children: deviceRow)
                      ]),
                      pdf.Column(children: [
                        pdf.Text("Location",
                            style:
                                pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                        pdf.Text(farmName),
                      ])
                    ]),
                pdf.Divider(),
                pdf.Column(children: [
                  // pdf.Row(
                  //     mainAxisAlignment: pdf.MainAxisAlignment.spaceEvenly,
                  //     children: [
                  //       pdf.Column(children: [
                  //         pdf.Row(
                  //             mainAxisAlignment:
                  //                 pdf.MainAxisAlignment.spaceEvenly,
                  //             children: [
                  //               pdf.Text("Value",
                  //                   style: pdf.TextStyle(fontSize: 16)),
                  //               pdf.Text("Timestamp",
                  //                   style: pdf.TextStyle(fontSize: 16)),
                  //               pdf.Text("State",
                  //                   style: pdf.TextStyle(fontSize: 16)),
                  //             ])
                  //       ]),
                  //       pdf.Text("Device", style: pdf.TextStyle(fontSize: 16))
                  //     ]),
                  pdf.ListView.builder(
                      itemBuilder: (context, index) {
                        var data = dataResponse.elementAt(index)["Data"];
                        // print(
                        //     "${json.decode(data)}, ${json.decode(data).runtimeType}");
                        var dataTrimmed = json.decode(data);
                        // List<Map> dt = [];
                        // for (var strMap in dataTrimmed) {
                        //   dt.add(json.decode(strMap));
                        // }
                        var source =
                            dataResponse.elementAt(index)["FromDevice"];
                        print("Build pdf data: $data, ${data.runtimeType}");
                        return pdf.Column(children: [
                          pdf.Row(
                              mainAxisAlignment:
                                  pdf.MainAxisAlignment.spaceBetween,
                              children: [
                                pdf.ListView.builder(
                                    itemBuilder: (context, index2) {
                                      return pdf.Row(
                                          mainAxisAlignment: pdf
                                              .MainAxisAlignment.spaceBetween,
                                          children: [
                                            pdf.Padding(
                                              padding: pdf.EdgeInsets.fromLTRB(
                                                  5, 5, 70, 0),
                                              child: pdf.Text(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          dataTrimmed[index2]
                                                              ["TimeStamp"])
                                                  .toLocal()
                                                  .toString()),
                                            ),
                                            pdf.Padding(
                                              padding: pdf.EdgeInsets.fromLTRB(
                                                  5, 5, 70, 0),
                                              child: pdf.Text(
                                                  dataTrimmed[index2]["Value"]),
                                            ),
                                            pdf.Padding(
                                              padding: pdf.EdgeInsets.fromLTRB(
                                                  5, 5, 70, 0),
                                              child: pdf.Text(
                                                  dataTrimmed[index2]["State"]
                                                      .toString()),
                                            ),
                                          ]);
                                    },
                                    itemCount: dataTrimmed.length),
                                pdf.Text(source)
                              ]),
                          pdf.Divider()
                        ]);
                      },
                      itemCount: dataResponse.length)
                ])
              ])),
    );
    return pf.save();
  }
}
