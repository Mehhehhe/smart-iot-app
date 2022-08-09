import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';

import 'package:smart_iot_app/services/dataManagement.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fpdart/fpdart.dart' as fp;
import 'package:intl/intl.dart';
import 'package:flutter/services.dart' show rootBundle;

class History_Page extends StatefulWidget {
  const History_Page({Key? key, required this.liveData}) : super(key: key);
  final Stream<String> liveData;
  @override
  State<History_Page> createState() => _History_PageState();
}

class _History_PageState extends State<History_Page> {
  _History_PageState() {
    timer = Timer.periodic(const Duration(seconds: 10), trackData);
  }

  late Stream<String> liveData;
  late Map<String, dynamic>? log = {};
  Timer? timer;

  late Map<String, dynamic>? historyLog = {};

  final ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    setState(() {
      liveData = widget.liveData;
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void trackData(Timer timer) async {
    setState(() {
      liveData.forEach((element) {
        var sv = json.decode(element);
        Map jsonSv = Map<String, dynamic>.from(sv);
        jsonSv.map((key, value) {
          key = DateTime.parse(key).toLocal().toString();
          value = Map<String, dynamic>.from(value);

          // Set initial message (depend on flag value)
          value["message"] = fp.Option.of(value)
              .filter((t) => t["flag"] == "flag{normal}")
              .andThen(() => fp.Option.of("This device is working normally."))
              .getOrElse(() => "Something went wrong ...");
          // Checking again if flag is not normal, do chain function
          value["message"] =
              value["message"] != "This device is working normally."
                  ? value["flag"] == "flag{threshNotSet}"
                      ? "Threshold is not set yet. Please set a threshold"
                      : value["flag"] == "flag{warning}"
                          ? "Warning. Device at risk."
                          : "Error occured!"
                  : value["message"];
          log!.addAll(Map<String, dynamic>.from({key: value}));
          writeHistory(
              "${json.encode(Map<String, dynamic>.from({key: value}))}\n");
          //print("wrote!");
          return MapEntry(key, value);
        });
      });
    });
  }

  /*
  Future<Map<String, dynamic>> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.reload();
      prefs.containsKey(DateFormat.yMMMM().format(DateTime.now()).toString());
      prefs
          .getStringList(DateFormat.yMMMM().format(DateTime.now()).toString())
          ?.asMap()
          .forEach((key, value) {
        print("$key $value");
        Map valueDecoded = json.decode(value);
        historyLog = Map<String, dynamic>.from(valueDecoded);
      });
    });
    return log!;
  }
  */
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    //print("path => $path");
    return File("$path/history.txt");
  }

  Future<File> writeHistory(String content) async {
    final file = await _localFile;
    bool fileCheck = await file.exists();
    //print("File exists? $fileCheck");
    //print("Write $content, type: ${content.runtimeType}");

    return file.writeAsString(content, mode: FileMode.append);
  }

  Future<String> readHistory() async {
    final file = await _localFile;
    var contents = await file.readAsString();
    return contents;
  }

  void clearHistory() async {
    final file = await _localFile;
    file.delete();
  }

  _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
  }

  /*
  Future<void> _saveHistory() async {
    //write to file

    final prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.reload();
      prefs.setStringList(DateFormat.yMMMM().format(DateTime.now()).toString(),
          log!.entries.map((e) => "{${e.key}:${e.value}}").toList());
      print("saved history ${prefs}");
    });
  }
  */
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
          children: <Widget>[
            sortHistory(),
            clearHistoryButton(),
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: _buildHistoryCard()),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
    return FutureBuilder(
      future: readHistory(),
      builder: (context, snapshot) {
        print("type: ${snapshot.data.runtimeType}, GET DATA: ${snapshot.data}");
        //var temp = snapshot.data as String;
        //Map data = json.decode(temp);
        //print("Mapped: $data");

        if (snapshot.data == null) {
          return Container();
        }

        var data = snapshot.data as String;
        List<dynamic> dataList = data.split("\n");
        List<Map<dynamic, dynamic>> newDataList = [];
        print("data len: ${dataList.length}");
        for (var element in dataList) {
          if (element == "" || element == " ") {
            dataList.remove(dataList.last);
            break;
          }
          //element = Map.from(json.decode(element.trim()));
          newDataList.add(Map<dynamic, dynamic>.from(
              json.decode(element) as Map<dynamic, dynamic>));
        }
        //print("Conclude data : ${newDataList[0]}, ${newDataList.runtimeType}");
        //print(cardData);
        //newDataList = newDataList.reversed.toList();
        return ListView.builder(
          itemCount: newDataList.length ?? 0,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          reverse: true,
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return history_cardPreset(
                json.decode(json.encode(newDataList[index])));
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
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    log!["id"] != null
                        ? log!["id"].toString().split(".").join(" ")
                        : 'Device ',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    log!.entries.isNotEmpty
                        ? log!.entries.first.key.split(".")[0]
                        : "Unknown time",
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
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
                    style: const TextStyle(fontSize: 12),
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
        decoration: const BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: BorderRadius.all(
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

  Widget clearHistoryButton() {
    return TextButton(
        onPressed: () {
          clearHistory();
        },
        child: const Text("Clear History"));
  }
}
