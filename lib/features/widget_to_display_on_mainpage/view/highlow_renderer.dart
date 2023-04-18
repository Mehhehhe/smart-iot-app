import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:syncfusion_flutter_charts/charts.dart';

late List<num> _xValues;
late List<num> _yValues;
List<double> _xPointValues = <double>[];
List<double> _yPointValues = <double>[];

class CustomLineSeriesRenderer extends LineSeriesRenderer {
  CustomLineSeriesRenderer(this.series);

  final LineSeries<dynamic, dynamic> series;
  // final double thresh;
  // static Random randomNumber = Random();

  @override
  LineSegment createSegment() {
    return _LineCustomPainter(series);
  }
}

class _LineCustomPainter extends LineSegment {
  _LineCustomPainter(this.series) {
    //ignore: prefer_initializing_formals
    // index = value;
    _xValues = <num>[];
    _yValues = <num>[];
  }

  final LineSeries<dynamic, dynamic> series;
  late double maximum, minimum;
  // late double index;
  List<Color> colors = <Color>[
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.cyan
  ];

  @override
  Paint getStrokePaint() {
    final Paint customerStrokePaint = Paint();
    customerStrokePaint.color = const Color.fromRGBO(53, 92, 125, 1);
    customerStrokePaint.strokeWidth = 2;
    customerStrokePaint.style = PaintingStyle.stroke;

    return customerStrokePaint;
  }

  void _storeValues() {
    _xPointValues.add(points[0].dx);
    _xPointValues.add(points[1].dx);
    _yPointValues.add(points[0].dy);
    _yPointValues.add(points[1].dy);
    _xValues.add(points[0].dx);
    _xValues.add(points[1].dx);
    _yValues.add(points[0].dy);
    _yValues.add(points[1].dy);
  }

  @override
  // ignore: long-method
  void onPaint(Canvas canvas) {
    final double x1 = points[0].dx,
        y1 = points[0].dy,
        x2 = points[1].dx,
        y2 = points[1].dy;
    _storeValues();
    final Path path = Path();
    path.moveTo(x1, y1);
    path.lineTo(x2, y2);
    canvas.drawPath(path, getStrokePaint());

    if (currentSegmentIndex == series.dataSource.length - 2) {
      const double labelPadding = 10;
      final Paint topLinePaint = Paint()
        ..color = Colors.blue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final Paint bottomLinePaint = Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      maximum = _yPointValues.reduce(max);
      minimum = _yPointValues.reduce(min);
      final Path bottomLinePath = Path();
      final Path topLinePath = Path();
      bottomLinePath.moveTo(_xPointValues[0], maximum);
      bottomLinePath.lineTo(_xPointValues[_xPointValues.length - 1], maximum);
      // print("[MINMAX] $minimum $maximum ${points}");
      topLinePath.moveTo(_xPointValues[0], minimum);
      topLinePath.lineTo(_xPointValues[_xPointValues.length - 1], minimum);
      canvas.drawPath(
          _dashPath(
            bottomLinePath,
            dashArray: _CircularIntervalList<double>(<double>[15, 3, 3, 3]),
          )!,
          bottomLinePaint);

      canvas.drawPath(
          _dashPath(
            topLinePath,
            dashArray: _CircularIntervalList<double>(<double>[15, 3, 3, 3]),
          )!,
          topLinePaint);

      final TextSpan span = TextSpan(
        style: TextStyle(
          color: Colors.orange[800],
          fontSize: 12.0,
        ),
        text: 'Lowest',
      );
      final TextPainter tp =
          TextPainter(text: span, textDirection: prefix0.TextDirection.ltr);
      tp.layout();
      tp.paint(
        canvas,
        Offset(
          _xPointValues[_xPointValues.length - 1] - 25,
          maximum - labelPadding - 10,
        ),
      );

      final TextSpan span1 = TextSpan(
        style: TextStyle(
          color: Colors.blue[800],
          fontSize: 12.0,
        ),
        text: 'Highest',
      );
      final TextPainter tp1 =
          TextPainter(text: span1, textDirection: prefix0.TextDirection.ltr);
      tp1.layout();
      tp1.paint(
        canvas,
        Offset(
          _xPointValues[_xPointValues.length - 1] - 25,
          minimum - labelPadding - tp1.size.height,
        ),
      );
      _yValues.clear();
      _yPointValues.clear();
    }
  }
}

Path? _dashPath(
  Path source, {
  required _CircularIntervalList<double> dashArray,
}) {
  if (source == null) {
    return null;
  }
  const double intialValue = 0.0;
  final Path path = Path();
  for (final PathMetric measurePath in source.computeMetrics()) {
    double distance = intialValue;
    bool draw = true;
    while (distance < measurePath.length) {
      final double length = dashArray.next;
      if (draw) {
        path.addPath(
            measurePath.extractPath(distance, distance + length), Offset.zero);
      }
      distance += length;
      draw = !draw;
    }
  }

  return path;
}

class _CircularIntervalList<T> {
  _CircularIntervalList(this._values);
  final List<T> _values;
  int _index = 0;
  T get next {
    if (_index >= _values.length) {
      _index = 0;
    }
    return _values[_index++];
  }
}
