import 'dart:math';

import 'package:flutter/material.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/Login.dart';

enum AuthStatus{
  NOT_DETERMINED,
  NOT_LOGGED_IN,
  LOGGED_IN
}

class RootPage extends StatefulWidget{
  RootPage({required this.auth});
  final BaseAuth auth;
  @override
  State<StatefulWidget> createState() => new _RootPageState();
}

class _RootPageState extends State<RootPage>{
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userID = "";

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then(
            (user) {
              setState(() {
                // Check if current user exists
                if(user != null){
                  _userID = user.uid;
                  print(_userID);
                }
                // If current user.uid is null then status is not logged in
                // Otherwise, status is logged in
                authStatus = user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
              });
            });
  }

  void loginCallback() {
    widget.auth.getCurrentUser().then(
            (user) {
              setState(() {
                // Ensure that user.uid is not nullable.
                _userID = user!.uid;
              });
            });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void logoutCallback() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
      _userID = "";
    });
  }

  Widget buildingWaitingScreen(){
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch(authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return buildingWaitingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return LogIn(
          auth: widget.auth,
          loginCallback: loginCallback,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if(_userID.length > 0 && _userID != null){
          //return MainPage(
          //  userID: _userID,
          //  auth: widget.auth,
          //  logoutCallback: logoutCallback,
          //);
          print("RETURN MAIN PAGE!");
          return buildingWaitingScreen();
        }else{
          return buildingWaitingScreen();
        }
        break;
      default:
        return buildingWaitingScreen();
    }
  }
}