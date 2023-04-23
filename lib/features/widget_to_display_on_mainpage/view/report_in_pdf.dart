import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:smart_iot_app/model/ReportModel.dart';

class ReportPreview extends StatelessWidget {
  final ReportCard reportCard;
  const ReportPreview({
    Key? key,
    required this.reportCard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview"),
      ),
      body: PdfPreview(build: (context) => reportCard.make()),
    );
  }
}
