import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;

class ReportCard {
  // Top Section requirements
  String farmName;
  final DateTime _generatedTime = DateTime.now().toLocal();
  // String whoGenerated;
  // Information
  List devicesWithType;
  List<String> imgPath;
  Map<String, dynamic>? commentOnPdf;
  Map<String, dynamic>? averageToDisplayInPdf;
  // String location;
  // Widget generatedChart;
  // List<Map> dataResponse;

  ReportCard(
    this.farmName,
    this.devicesWithType,
    this.imgPath, [
    this.commentOnPdf,
    this.averageToDisplayInPdf,
  ]
      // this.generatedChart,
      // this.location,
      // this.whoGenerated,
      // this.dataResponse,
      );

  _mapDevicesToTableRow() {
    return pdf.Table.fromTextArray(
      data: List<List<dynamic>>.generate(
        devicesWithType.length,
        (index) => [
          devicesWithType[index]["DeviceName"],
          devicesWithType[index]["Type"],
        ],
      ),
      headers: ["Name", "Type"],
      headerStyle: pdf.TextStyle(
        color: PdfColors.white,
        fontWeight: pdf.FontWeight.bold,
      ),
      headerDecoration: const pdf.BoxDecoration(
        color: PdfColors.orange,
      ),
      cellAlignment: pdf.Alignment.centerRight,
      cellAlignments: {0: pdf.Alignment.centerLeft},
    );
  }

  _mapDeviceAvg() {
    List tables = [];
    List data = [];
    averageToDisplayInPdf!.forEach((key, value) {
      data.add([
        key,
        value.runtimeType == String ? [value] : [value[0], value[1], value[2]],
      ]);
    });
    for (var a in data) {
      tables.add(
          pdf.Padding(padding: pdf.EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 0.0)));
      tables.add(
        pdf.Table.fromTextArray(
          data: List<List<dynamic>>.generate(
            1,
            (index) => [
              a[0],
              a[1].length > 1
                  ? "N:${a[1][0]}, P:${a[1][1]}, K:${a[1][2]},"
                  : "${a[1][0]}",
            ],
          ),
          headers: ["Name", "Average"],
          headerStyle: pdf.TextStyle(
            color: PdfColors.white,
            fontWeight: pdf.FontWeight.bold,
          ),
          headerDecoration: const pdf.BoxDecoration(
            color: PdfColors.amberAccent,
          ),
          cellAlignment: pdf.Alignment.centerRight,
          cellAlignments: {0: pdf.Alignment.centerLeft},
        ),
      );
    }

    return tables;
  }

  _graphImages(path) {
    return pdf.Image(
      pdf.MemoryImage(File(path).readAsBytesSync()),
    );
  }

  // ignore: long-method
  FutureOr<Uint8List> make() async {
    final pf = pdf.Document();
    final deviceRow = _mapDevicesToTableRow();
    // print(devicesWithType);
    pf.addPage(
      pdf.Page(
        build: (context) => pdf.Column(
          children: [
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
                    // pdf.Text("By $whoGenerated"),
                  ],
                ),
              ],
            ),
            pdf.Divider(),
            pdf.Row(
              mainAxisAlignment: pdf.MainAxisAlignment.spaceBetween,
              children: [
                pdf.Column(children: [
                  pdf.Padding(
                    child: pdf.Text("Devices Table"),
                    padding: const pdf.EdgeInsets.all(5.0),
                  ),
                  pdf.Divider(),
                  deviceRow,
                ]),
                pdf.Column(
                  children: [
                    pdf.Text("Location",
                        style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
                    pdf.Text(farmName),
                  ],
                ),
              ],
            ),
            pdf.Divider(),
            // Analyze section
            pdf.Text("Device Value Average"),
            pdf.Column(children: [..._mapDeviceAvg()]),
          ],
        ),
      ),
    );
    for (var path in imgPath) {
      pf.addPage(pdf.Page(
        build: (context) => pdf.Column(children: [
          _graphImages(path),
          pdf.Text(commentOnPdf != null ? commentOnPdf![path] : "")
        ]),
      ));
    }

    return pf.save();
  }
}
