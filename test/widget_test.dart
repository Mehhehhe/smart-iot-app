// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/view/farm_card.dart';

import 'package:smart_iot_app/main.dart' as smr_main;
import 'package:smart_iot_app/modules/pipe.dart';
import 'package:smart_iot_app/pages/MainPage.dart';

void main() {
  test('Test piping was usable', () {
    Iterable a = Iterable.empty();
    add2(x) => x + 2;
    sub2(x) => x - 2;
    expect(a.pipe([add2, sub2])(0), equals(0));
  });
}
