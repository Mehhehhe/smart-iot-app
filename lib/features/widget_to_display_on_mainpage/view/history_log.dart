import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/db/local_history.dart';
import 'package:smart_iot_app/model/LocalHistory.dart';

class historyLog extends StatefulWidget {
  final String farmName;

  const historyLog({Key? key, required this.farmName}) : super(key: key);

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
  String selectHistFilterRange = "days";
  static const List<Widget> filterHistory = [
    Text("Days"),
    Text("Months"),
    Text("Years"),
  ];
  List<bool> selectedHistFilter = [
    true,
    false,
    false,
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
        // Query button
        Padding(
          padding: EdgeInsets.all(10.0),
          child: ToggleButtons(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            constraints: const BoxConstraints(
              minHeight: 40.0,
              minWidth: 80.0,
            ),
            onPressed: (index) {
              for (int i = 0; i < selectedHistFilter.length; i++) {
                selectedHistFilter[i] = i == index;
              }
              switch (index) {
                case 0:
                  setState(() {
                    selectHistFilterRange = "days";
                  });
                  break;
                case 1:
                  setState(() {
                    selectHistFilterRange = "months";
                  });
                  break;
                case 2:
                  setState(() {
                    selectHistFilterRange = "years";
                  });
                  break;
                default:
              }
            },
            isSelected: selectedHistFilter,
            children: const [...filterHistory],
          ),
        ),

        Expanded(
          child: Container(
            color: Colors.white,
            child: FutureBuilder(
              future: instance.getAllHistory(),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                // read local
                if (snapshot.hasData) {
                  List<LocalHist> fetchedDataArray = snapshot.data;
                  // query only active selected farm
                  List<LocalHist> dataArray = [];
                  for (var f in fetchedDataArray) {
                    if (f.farm == widget.farmName) {
                      dataArray.add(f);
                    }
                  }

                  if (dataArray.isEmpty) {
                    return const Center(
                      child: Text("No history of this device"),
                    );
                  }

                  Map<DateTime, List<LocalHist>> groupedData = groupBy(
                    dataArray,
                    (LocalHist p0) {
                      DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        int.parse(p0.dateUnixAsId),
                      );
                      // Query here!
                      switch (selectHistFilterRange) {
                        case "days":
                          return DateTime(date.year, date.month, date.day);
                        // break;
                        case "months":
                          return DateTime(date.year, date.month);
                        case "years":
                          return DateTime(date.year);
                        default:
                      }
                      // default: days

                      return DateTime(date.year, date.month, date.day);
                    },
                  );

                  List<ExpansionTile> dayTile = [];
                  // print("Group of farm ${widget.farmName}");
                  groupedData.forEach((key, value) {
                    List<ListTile> subTile = [];
                    // is sorting enabled?
                    List<LocalHist> val = value.takeWhile((value) {
                      String tempName = selectHistFilterRange == "days"
                          ? "${key.day}/${key.month}/${key.year}"
                          : selectHistFilterRange == "months"
                              ? "${key.month}/${key.year}"
                              : "${key.year}";
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
                        title: Text("No data"),
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
                            if (selectHistFilterRange == "days")
                              Text(
                                "${temp.hour}:${temp.minute}:${temp.second < 10 ? "0${temp.second}" : temp.second}.${temp.millisecond}",
                              ),
                            if (selectHistFilterRange == "months" ||
                                selectHistFilterRange == "years")
                              Text(
                                "${temp.day}/${temp.month}/${temp.year} ${temp.hour}:${temp.minute}:${temp.second < 10 ? "0${temp.second}" : temp.second}",
                              ),
                          ],
                        ),
                      ));
                    });
                    dayTile.add(ExpansionTile(
                      title: Text(selectHistFilterRange == "days"
                          ? "${key.day}/${key.month}/${key.year}"
                          : selectHistFilterRange == "months"
                              ? "${key.month}/${key.year}"
                              : "${key.year}"),
                      onExpansionChanged: (value) {
                        setState(() {
                          expIndex = value
                              ? selectHistFilterRange == "days"
                                  ? "${key.day}/${key.month}/${key.year}"
                                  : selectHistFilterRange == "months"
                                      ? "${key.month}/${key.year}"
                                      : selectHistFilterRange == "years"
                                          ? "${key.year}"
                                          : "History"
                              : "History";
                          // exposedFilter = value ? exposedFilter : "Default";
                        });
                      },
                      children: [
                        _filterLogs(
                          name: selectHistFilterRange == "days"
                              ? "${key.day}/${key.month}/${key.year}"
                              : selectHistFilterRange == "months"
                                  ? "${key.month}/${key.year}"
                                  : "${key.year}",
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
        String filter = filterTexts[index]
            .toString()
            .substring(6, filterTexts[index].toString().length - 2);

        for (int i = 0; i < exposedFilterMap[name]["bool_list"].length; i++) {
          exposedFilterMap[name]["bool_list"][i] = i == index;
        }

        switch (filter) {
          case "Default":
            setState(() => exposedFilterMap[name]["filter"] = "Default");
            break;
          case "Info":
            setState(() => exposedFilterMap[name]["filter"] = "Info");
            break;
          case "Warning":
            setState(() => exposedFilterMap[name]["filter"] = "Warning");
            break;
          case "Error":
            setState(() => exposedFilterMap[name]["filter"] = "Error");
            break;
          default:
        }
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
