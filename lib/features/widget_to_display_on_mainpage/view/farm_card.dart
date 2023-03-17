import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/farm_card_cubit.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/cubit/screen_index_change_cubit.dart';
import 'package:smart_iot_app/pages/MainPage.dart';
import 'package:smart_iot_app/services/MQTTClientHandler.dart';

import '../bloc/farm_card_re_bloc.dart';
import 'farm_card_view.dart';

class farmCard extends StatelessWidget {
  // String username;
  int? farmIndex;
  MQTTClientWrapper cli = MQTTClientWrapper("farmCard");
  farmCard({Key? key}) : super(key: key);

  farmCard.withIndex({Key? key, required this.farmIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FarmCardReBloc(cli),
      child: BlocProvider(
        create: (_) => ScreenIndexChangeCubit(),
        child: MainPage(cli),
      ),
    );
  }
}
