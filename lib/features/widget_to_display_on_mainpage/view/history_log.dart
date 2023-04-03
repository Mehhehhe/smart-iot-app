import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';

class historyLog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _historyLog();
}

class _historyLog extends State<historyLog> {
  late LocalHistoryDatabase instance;
  String expIndex = "History";

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // const Padding(
        //   padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
        //   child: Text(
        //     "History",
        //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        //   ),
        // ),
        Expanded(
          child: Container(
            color: Colors.white,
            child: FutureBuilder(
              future: instance.getAllHistory(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                // read local
                if (snapshot.hasData) {
                  List<LocalHist> dataArray = snapshot.data;
                  Map<DateTime, List<LocalHist>> groupedData = groupBy(
                    dataArray,
                    (LocalHist p0) {
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(p0.dateUnixAsId),
                      );

                      return DateTime(date.year, date.month, date.day);
                    },
                  );

                  List<ExpansionTile> dayTile = [];
                  groupedData.forEach((key, value) {
                    List<ListTile> subTile = [];
                    value.forEach((element) {
                      Map tileData = element.toJson();
                      subTile.add(ListTile(
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
                      ));
                    });
                    dayTile.add(ExpansionTile(
                      title: Text("${key.day}/${key.month}/${key.year}"),
                      onExpansionChanged: (value) {
                        setState(() {
                          expIndex = value == true
                              ? "${key.day}/${key.month}/${key.year}"
                              : "History";
                        });
                      },
                      children: [
                        ...subTile,
                      ],
                    ));
                  });

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return <Widget>[
                        SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                            context,
                          ),
                          sliver: SliverAppBar(
                            title: Text(expIndex),
                            pinned: true,
                            forceElevated: innerBoxIsScrolled,
                            centerTitle: true,
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ];
                    },
                    body: SafeArea(child: Builder(
                      builder: (context) {
                        return CustomScrollView(
                          slivers: [
                            SliverOverlapInjector(
                              handle: NestedScrollView
                                  .sliverOverlapAbsorberHandleFor(context),
                            ),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => dayTile[index],
                                childCount: dayTile.length,
                              ),
                            ),
                          ],
                        );
                      },
                    )),
                  );
                }

                return const Center(
                  child: Text("No history"),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
