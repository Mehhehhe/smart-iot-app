import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';

class DeviceDetail extends StatelessWidget {
  DeviceDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      child: ListView(shrinkWrap: true, children: [
        Text("Title"),
        BlocBuilder<UserDataStreamBloc, UserDataStreamState>(
          builder: (context, state) {
            if (state.data != "" || state.data != null) {
              print("[CheckDetail] ${state.data}");
              return Text(state.data);
            }
            return Text("Fetching data ... ");
          },
        )
      ]),
    )));
  }
}
