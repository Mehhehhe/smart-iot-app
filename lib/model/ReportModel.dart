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
  // String location;
  // Widget generatedChart;
  // List<Map> dataResponse;

  ReportCard(
    this.farmName,
    this.devicesWithType,
    this.imgPath,
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
          ],
        ),
      ),
    );
    for (var path in imgPath) {
      pf.addPage(pdf.Page(
        build: (context) => _graphImages(path),
      ));
    }

    return pf.save();
  }
}
