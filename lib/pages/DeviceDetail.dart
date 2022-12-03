import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';

class DeviceDetail extends StatelessWidget {
  Map detail;
  DeviceDetail({Key? key, required this.detail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Container(
      child: ListView(shrinkWrap: true, children: [
        Text("${detail["DeviceName"]}"),
        BlocBuilder<UserDataStreamBloc, UserDataStreamState>(
          builder: (context, state) {
            if (state.data != "" || state.data != null) {
              print("[CheckDetail] ${state.data}");
              return Column(
                children: [
                  Text("Detail"),
                  Text(detail.toString()),
                  Text("Graph"),
                  Text(state.data),
                ],
              );
            }
            return Text("Fetching data ... ");
          },
        )
      ]),
    )));
  }
}
