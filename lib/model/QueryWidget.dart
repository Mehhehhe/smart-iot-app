// class QueryWidget {
//   final String deviceName;
//   final String farm;
//   final dynamic rawData;

//   const QueryWidget(
//     this.deviceName,
//     this.farm,
//     this.rawData,
//   );

//   // Status
//   //
// }
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_iot_app/features/widget_to_display_on_mainpage/bloc/user_data_stream_bloc.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class QueryableCard extends StatefulWidget {
  final String serial;
  final String deviceName;
  final dynamic details;
  final Map<String, dynamic> currMap;
  const QueryableCard({
    Key? key,
    required this.serial,
    required this.deviceName,
    this.details,
    required this.currMap,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QueryableCardState();
}

class _QueryableCardState extends State<QueryableCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Widget _createCard() {
  //   return Card(
  //     child: InkWell(
  //       onTap: () => Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => BlocProvider(
  //             create: (_) => UserDataStreamBloc(
  //               client: widget.existedCli,
  //               device: name,
  //               location: widget.whichFarm,
  //             ),
  //             child: DeviceDetail(
  //               detail: details,
  //               serial: name,
  //               location: widget.whichFarm,
  //               latestDatePlaceholder: [currMap],
  //             ),
  //           ),
  //         ),
  //       ),
  //       child: SizedBox(
  //         height: MediaQuery.of(context).size.height * 0.3,
  //         child: Stack(
  //           children: [
  //             // gauge here!
  //             _gaugeInCard(name, currentValue),
  //             Center(
  //               child: Padding(
  //                 padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
  //                 child: Switch(
  //                   value: currMap[name]!["State"],
  //                   onChanged: (value) {
  //                     widget.existedCli.publishToSetDeviceState(
  //                       widget.whichFarm,
  //                       name,
  //                       value,
  //                     );
  //                   },
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _gaugeInCard(name, currentValue) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      child: SfRadialGauge(
        enableLoadingAnimation: true,
        title: GaugeTitle(text: name),
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 100,
            radiusFactor: 0.8,
            showLabels: false,
            showTicks: false,
            pointers: <GaugePointer>[
              RangePointer(
                value: double.parse(currentValue),
                width: 18,
                color: Colors.greenAccent,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  double.parse(currentValue).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
