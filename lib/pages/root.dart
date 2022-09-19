// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:smart_iot_app/services/MQTTClientHandler.dart';
// import 'package:smart_iot_app/services/authentication.dart';
// import 'package:smart_iot_app/pages/Login.dart';
// import 'package:smart_iot_app/pages/MainPage.dart';

// enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

// class RootPage extends StatefulWidget {
//   RootPage({required this.auth, required this.client});
//   final BaseAuth auth;
//   final MQTTClientWrapper client;
//   @override
//   State<StatefulWidget> createState() => _RootPageState();
// }

// class _RootPageState extends State<RootPage> {
//   AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
//   String _userID = "";

//   @override
//   void dispose() {
//     widget.client.client.disconnect();
//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();
//     widget.auth.getCurrentUser().then((user) {
//       print("[Root] $user");
//       setState(() {
//         // Check if current user exists
//         if (user != null) {
//           _userID = user.uid;
//           if (kDebugMode) {
//             print(_userID);
//           }
//         }
//         // If current user.uid is null then status is not logged in
//         // Otherwise, status is logged in
//         authStatus =
//             user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
//       });
//     });
//   }

//   void loginCallback() {
//     widget.auth.getCurrentUser().then((user) {
//       setState(() {
//         // Ensure that user.uid is not nullable.
//         _userID = user!.uid;
//       });
//     });
//     setState(() {
//       authStatus = AuthStatus.LOGGED_IN;
//     });
//   }

//   void logoutCallback() {
//     setState(() {
//       authStatus = AuthStatus.NOT_LOGGED_IN;
//       _userID = "";
//     });
//   }

//   Widget buildingWaitingScreen() {
//     return Scaffold(
//       body: Container(
//         alignment: Alignment.center,
//         child: const CircularProgressIndicator(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     switch (authStatus) {
//       case AuthStatus.NOT_DETERMINED:
//         return buildingWaitingScreen();
//         break;
//       case AuthStatus.NOT_LOGGED_IN:
//         return LogIn();
//         break;
//       case AuthStatus.LOGGED_IN:
//         print(
//             "[Root] - LOGGED IN - $_userID is not empty ${_userID.isNotEmpty}");
//         print("[Root][Ready] - ${widget.client == null}");
//         if (_userID.isNotEmpty) {
//           return MainPage(
//             userId: _userID,
//             auth: widget.auth,
//             logoutCallback: logoutCallback,
//             user: widget.client,
//           );
//         } else {
//           return buildingWaitingScreen();
//         }
//       default:
//         return buildingWaitingScreen();
//     }
//   }
// }
