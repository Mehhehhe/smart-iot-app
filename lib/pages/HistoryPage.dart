// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:animated_theme_switcher/animated_theme_switcher.dart';
// import 'package:flutter/material.dart';

// import 'package:smart_iot_app/services/dataManagement.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:fpdart/fpdart.dart' as fp;
// import 'package:intl/intl.dart';
// import 'package:flutter/services.dart' show rootBundle;

// class History_Page extends StatefulWidget {
//   const History_Page({Key key, this.liveData}) : super(key: key);
//   final Stream<String> liveData;
//   @override
//   State<History_Page> createState() => _History_PageState();
// }

// class _History_PageState extends State<History_Page> {
//   final ScrollController _scrollController = new ScrollController();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<String> get _localPath async {
//     final directory = await getApplicationDocumentsDirectory();
//     return directory.path;
//   }

//   Future<File> get _localFile async {
//     final path = await _localPath;
//     //print("path => $path");
//     return File("$path/history.txt");
//   }

//   Future<File> writeHistory(String content) async {
//     final file = await _localFile;
//     bool fileCheck = await file.exists();

//     return file.writeAsString(content, mode: FileMode.append);
//   }

//   Future<String> readHistory() async {
//     final file = await _localFile;
//     var contents = await file.readAsString();
//     return contents;
//   }

//   void clearHistory() async {
//     final file = await _localFile;
//     file.delete();
//   }

//   _scrollToTop() {
//     _scrollController.animateTo(_scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.fastOutSlowIn);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Color.fromRGBO(241, 241, 241, 1.0),
//         ),
//         child: Stack(
//           children: [
//             _showForm(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _showForm() {
//     return Container(
//       padding: const EdgeInsets.all(15.0),
//       child: Form(
//         //key: _formKey,
//         child: ListView(
//           shrinkWrap: true,
//           children: <Widget>[
//             sortHistory(),
//             clearHistoryButton(),
//             SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.6,
//                 child: _buildHistoryCard()),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHistoryCard() {
//     WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTop());
//     return FutureBuilder(
//       future: readHistory(),
//       builder: (context, snapshot) {
//         print("type: ${snapshot.data.runtimeType}, GET DATA: ${snapshot.data}");
//         //var temp = snapshot.data as String;
//         //Map data = json.decode(temp);
//         //print("Mapped: $data");

//         if (snapshot.data == null) {
//           return Container();
//         }

//         var data = snapshot.data as String;
//         List<dynamic> dataList = data.split("\n");
//         List<Map<dynamic, dynamic>> newDataList = [];
//         print("data len: ${dataList.length}");
//         for (var element in dataList) {
//           if (element == "" || element == " ") {
//             dataList.remove(dataList.last);
//             break;
//           }
//           //element = Map.from(json.decode(element.trim()));
//           newDataList.add(Map<dynamic, dynamic>.from(
//               json.decode(element) as Map<dynamic, dynamic>));
//         }
//         //print("Conclude data : ${newDataList[0]}, ${newDataList.runtimeType}");
//         //print(cardData);
//         //newDataList = newDataList.reversed.toList();
//         return ListView.builder(
//           itemCount: newDataList.length ?? 0,
//           shrinkWrap: true,
//           scrollDirection: Axis.vertical,
//           reverse: true,
//           controller: _scrollController,
//           physics: const AlwaysScrollableScrollPhysics(),
//           itemBuilder: (context, index) {
//             return history_cardPreset(
//                 json.decode(json.encode(newDataList[index])));
//           },
//         );
//       },
//     );
//   }

//   Widget history_cardPreset(Map log) {
//     return Card(
//       //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
//       color: log.entries.first.value["flag"] == "flag{normal}"
//           ? Colors.lightGreen
//           : log.entries.first.value["flag"] == "flag{warning}"
//               ? Colors.orangeAccent
//               : log.entries.first.value["flag"] == "flag{error}"
//                   ? Colors.redAccent
//                   : Colors.blueGrey,
//       shadowColor: Colors.black,
//       elevation: 15,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//       ),
//       //color : Color.fromRGBO(255, 255, 255, 0.75),
//       child: Container(
//         padding: const EdgeInsets.all(15),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     log.entries
//                             .where((element) => element.value["id"] != null)
//                             .isNotEmpty
//                         ? log.entries
//                             .where((element) => element.value["id"] != null)
//                             .first
//                             .value["id"]
//                             .toString()
//                             .split(".")
//                             .join(" ")
//                         : 'Device ',
//                     style: const TextStyle(
//                         fontSize: 20, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     log.entries.isNotEmpty
//                         ? log.entries.first.key.split(".")[0]
//                         : "Unknown time",
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               margin: const EdgeInsets.only(top: 10),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     log
//                             .transformAndLocalize()
//                             .entries
//                             .filter((t) => t.key
//                                 .toString()
//                                 .endsWith("message")
//                                 .match(() => false, () => t.value != null))
//                             .isNotEmpty
//                         ? log
//                             .transformAndLocalize()
//                             .entries
//                             .where((element) =>
//                                 element.key.toString().endsWith("message"))
//                             .first
//                             .value
//                         : "No message",
//                     style: const TextStyle(fontSize: 12),
//                   ),
//                 ],
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget sortHistory() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 10),
//       child: Container(
//         width: 400,
//         height: 50,
//         decoration: const BoxDecoration(
//           color: Color.fromRGBO(255, 255, 255, 0.8),
//           borderRadius: BorderRadius.all(
//             Radius.circular(25.0),
//           ),
//         ),
//         child: ThemeSwitcher(
//           builder: (context) => OutlinedButton(
//             style: ButtonStyle(
//               shape: MaterialStateProperty.all(
//                 RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0)),
//               ),
//             ),
//             onPressed: () {},
//             child: const Text(
//               'Sort History',
//               textAlign: TextAlign.left,
//               style: TextStyle(
//                 fontFamily: "Roboto Slab",
//                 fontWeight: FontWeight.w600,
//                 fontSize: 18,
//                 letterSpacing: 0.0,
//                 color: Color.fromRGBO(70, 70, 70, 0.80196078431372547),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget clearHistoryButton() {
//     return TextButton(
//         onPressed: () {
//           clearHistory();
//         },
//         child: const Text("Clear History"));
//   }
// }
