import 'package:flutter/material.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';

class historyLog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _historyLog();
}

class _historyLog extends State<historyLog> {
  late LocalHistoryDatabase instance;

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: FutureBuilder(
        future: instance.getAllHistory(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          // read local
          if (snapshot.hasData) {
            List<LocalHist> dataArray = snapshot.data;

            return ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Map<String, dynamic> tileData = dataArray[index].toJson();

                return ListTile(
                  title: Text(tileData["device"]),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tileData["value"],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(DateTime.fromMillisecondsSinceEpoch(
                        int.parse(tileData["_id"]),
                      ).toLocal().toString()),
                    ],
                  ),
                );
              },
            );
          }

          return const Center(
            child: Text("No history"),
          );
        },
      ),
    );
  }
}
