import 'dart:async';
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

  ReportCard(this.farmName, this.devicesWithType, this.generatedChart,
      this.location, this.whoGenerated);

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
                        pdf.Text(location),
                      ])
                    ]),
              ])),
    );
    return pf.save();
  }
}
