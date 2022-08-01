import 'dart:async';
import 'dart:convert';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_iot_app/services/dataManagement.dart';
import 'package:smart_iot_app/main.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:intl/intl.dart';

class History_Page extends StatefulWidget {
  const History_Page({Key? key, required this.liveData}) : super(key: key);
  final Stream<String> liveData;
  @override
  State<History_Page> createState() => _History_PageState();
}

class _History_PageState extends State<History_Page> {
  late Stream<String> liveData;
  late Map<String, dynamic>? log = {};
  Timer? timer;

  late List<String> historyLog;

  _History_PageState() {
    timer = Timer.periodic(const Duration(seconds: 10), trackData);
  }

  @override
  void initState() {
    setState(() {
      liveData = widget.liveData;
    });
    super.initState();
  }

  @override
  void dispose() {
    _saveHistory();
    super.dispose();
  }

  void trackData(Timer timer) async {
    print("[Track] $liveData");

    liveData.listen(
      (event) {
        print("[Tracking] listen to $event");
      },
    );
    setState(() {
      print(liveData);
      liveData.forEach((element) {
        print("[Track each=>LiveData] : $element");
        Map elementToJson = Map<String, dynamic>.from(json.decode(element));
        // Transform key and value to preferrable type
        var transformed = elementToJson.map((key, value) {
          key = DateTime.parse(key);
          value = Map<String, dynamic>.from(value);
          print("track $value");
          // Set initial message (depend on flag value)
          value["message"] = fp.Option.of(value)
              .filter((t) => t["flag"] == "flag{normal}")
              .andThen(() => fp.Option.of("This device is working normally."))
              .getOrElse(() => "Something went wrong ...");
          // Checking again if flag is not normal, do chain function
          value["message"] != "This device is working normally."
              ? fp.Option.of(value["message"])
                  .filter(
                    (t) => t != "flag{normal}",
                  )
                  .flatMap(
                    (t) {
                      return t == "flag{threshNotSet}"
                          ? fp.Option.of("Thresh was not set.")
                          : t == "flag{warning}"
                              ? fp.Option.of("Warning. Device at risk")
                              : fp.Option.of(
                                  "Error. Something went wrong with this device");
                    },
                  )
                  .getOrElse(() => "Message was not generated")
                  .toString()
              : value["message"];
          return MapEntry(key, value);
        });
        print("[Track] transformed:=> $transformed");
        log!.addAll(Map<String, dynamic>.from(transformed));
        print(log);
      });
    });
  }

  Future<Map<String, dynamic>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs
          .getStringList(DateFormat.yMMMM().format(DateTime.now()))
          ?.asMap()
          .forEach((key, value) {
        Map valueDecoded = json.decode(value);
        log = Map<String, dynamic>.from(valueDecoded);
      });
    });
    return log!;
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setStringList(DateFormat.yMMMM().format(DateTime.now()),
          log!.entries.map((e) => "{${e.key}:${e.value}}").toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(241, 241, 241, 1.0),
        ),
        child: Stack(
          children: [
            _showForm(),
          ],
        ),
      ),
    );
  }

  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[sortHistory(), _buildHistoryCard()],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    return FutureBuilder(
      future: _loadHistory(),
      builder: (context, snapshot) {
        Map? cardData = fp.Option.of(snapshot)
            .filterMap((t) => fp.Option.of(t)
                .filter((t) => t.connectionState == ConnectionState.done)
                .filter((t) => t.hasData))
            .flatMap((t) => fp.Option.of(t.data))
            .toJson((p0) => p0) as Map?;
        //print(cardData);

        return ListView.builder(
          itemCount: cardData?.length ?? 0,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return history_cardPreset(cardData!);
          },
        );
      },
    );
  }

  Widget history_cardPreset(Map log) {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shadowColor: Colors.black,
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      //color : Color.fromRGBO(255, 255, 255, 0.75),
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log!["id"] != null
                  ? log!["id"].toString().split(".").join(" ")
                  : 'Device ',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log!
                            .transformAndLocalize()
                            .entries
                            .filter((t) => t.key
                                .toString()
                                .endsWith("message")
                                .match(() => false, () => t.value != null))
                            .isNotEmpty
                        ? log!
                            .transformAndLocalize()
                            .entries
                            .where((element) =>
                                element.key.toString().endsWith("message"))
                            .first
                            .value
                        : "No message",
                    style: TextStyle(fontSize: 12),
                  ),
                  Text(
                    log!.entries.isNotEmpty
                        ? log!.entries.first.key.split(".")[0]
                        : "Unknown time",
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget sortHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 400,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: const BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        child: ThemeSwitcher(
          builder: (context) => OutlinedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Sort History',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Roboto Slab",
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.0,
                color: Color.fromRGBO(70, 70, 70, 0.80196078431372547),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
