import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
// import 'package:fpdart/fpdart.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';

class historyLog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _historyLog();
}

class _historyLog extends State<historyLog> {
  late LocalHistoryDatabase instance;
  String expIndex = "History";
  // Filter range config
  // List<bool> selectedFilter = [
  //   true,
  //   false,
  //   false,
  //   false,
  // ];
  static const List<Widget> filterTexts = <Widget>[
    Text("Default"),
    Text("Info"),
    Text("Warning"),
    Text("Error"),
  ];
  // String exposedFilter = "Default";
  Map<String, dynamic> exposedFilterMap = {};

  @override
  void initState() {
    instance = LocalHistoryDatabase.instance;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    // is sorting enabled?
                    List<LocalHist> val = value.takeWhile((value) {
                      String tempName = "${key.day}/${key.month}/${key.year}";
                      if (exposedFilterMap.containsKey(tempName)) {
                        if (exposedFilterMap[tempName]["filter"] == "Info") {
                          return !(value.comment.contains("Warning") ||
                              value.comment.contains("Error"));
                        } else if (exposedFilterMap[tempName]["filter"] ==
                            "Warning") {
                          return value.comment.contains("Warning");
                        } else if (exposedFilterMap[tempName]["filter"] ==
                            "Error") {
                          return value.comment.contains("Error");
                        }
                      }

                      return value != null;
                    }).toList();
                    if (val.isEmpty) {
                      subTile.add(const ListTile(
                        title: Text("No data matched the filter"),
                      ));
                    }
                    val.forEach((element) {
                      Map tileData = element.toJson();
                      DateTime temp = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(tileData["_id"]),
                      ).toLocal();

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
                            Text(
                              "${temp.hour}:${temp.minute}:${temp.second < 10 ? "0${temp.second}" : temp.second}  ${temp.millisecond},${temp.microsecond}",
                            ),
                          ],
                        ),
                      ));
                    });
                    dayTile.add(ExpansionTile(
                      title: Text("${key.day}/${key.month}/${key.year}"),
                      onExpansionChanged: (value) {
                        setState(() {
                          expIndex = value
                              ? "${key.day}/${key.month}/${key.year}"
                              : "History";
                          // exposedFilter = value ? exposedFilter : "Default";
                        });
                      },
                      children: [
                        _filterLogs(
                          name: "${key.day}/${key.month}/${key.year}",
                        ),
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
                            automaticallyImplyLeading: false,
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

  Widget _filterLogs({required String name}) {
    Map<String, dynamic> temp = {
      name: {
        "filter": "Default",
        "bool_list": [true, false, false, false],
      },
    };
    if (!exposedFilterMap.keys.contains(name)) {
      exposedFilterMap.addEntries(temp.entries);
    }

    return ToggleButtons(
      direction: Axis.horizontal,
      onPressed: (index) {
        setState(() {
          String filter = filterTexts[index]
              .toString()
              .substring(6, filterTexts[index].toString().length - 2);

          for (int i = 0; i < exposedFilterMap[name]["bool_list"].length; i++) {
            exposedFilterMap[name]["bool_list"][i] = i == index;
          }

          switch (filter) {
            case "Default":
              exposedFilterMap[name]["filter"] = "Default";
              break;
            case "Info":
              exposedFilterMap[name]["filter"] = "Info";
              break;
            case "Warning":
              exposedFilterMap[name]["filter"] = "Warning";
              break;
            case "Error":
              exposedFilterMap[name]["filter"] = "Error";
              break;
            default:
          }
        });
      },
      isSelected: exposedFilterMap.containsKey(name)
          ? exposedFilterMap[name]["bool_list"]
          : temp[name]["bool_list"],
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      selectedBorderColor: Colors.green[700],
      selectedColor: Colors.white,
      fillColor: Colors.green[200],
      color: Colors.green[400],
      constraints: const BoxConstraints(
        minHeight: 40.0,
        minWidth: 80.0,
      ),
      children: filterTexts,
    );
  }
}
