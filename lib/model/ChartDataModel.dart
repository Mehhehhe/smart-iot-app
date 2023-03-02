import 'package:flutter/animation.dart';

class ChartData {
  ChartData(this.date, this.values, this.place, {this.name});
  final DateTime date;
  final dynamic values;
  final String place;

  final String? name;
}

// class ChartDataNPK {
//   ChartDataNPK(this.date, this.place, this.valueN, this.valueP, this.valueK);
//   final DateTime date;
//   final double valueN;
//   final double valueP;
//   final double valueK;
//   final String place;
// }
