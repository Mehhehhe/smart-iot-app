import 'package:flutter/animation.dart';

class ChartData {
  ChartData(this.date, this.values, this.place);
  final DateTime date;
  final double values;
  final String place;
  final List<Color> palette = [
    Color.fromRGBO(208, 31, 49, 1.0),
    Color.fromRGBO(246, 129, 33, 1.0),
    Color.fromRGBO(251, 221, 11, 1.0),
    Color.fromRGBO(0, 123, 97, 1.0),
    Color.fromRGBO(0, 114, 185, 1.0),
  ];
}
