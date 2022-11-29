import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/pages/MainPage.dart';

import 'farm_card_view.dart';

class farmCard extends StatelessWidget {
  // String username;
  int? farmIndex;
  farmCard({Key? key}) : super(key: key);

  farmCard.withIndex({Key? key, required this.farmIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FarmCardCubit(),
      child: MainPage(),
    );
  }
}
