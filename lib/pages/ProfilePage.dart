import 'dart:ffi';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MangePage.dart';
import 'package:smart_iot_app/pages/ProfilePage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/database_op.dart';
import 'package:firebase_core/firebase_core.dart';

class Profile_Page extends StatefulWidget {
  const Profile_Page({Key? key, required this.auth}) : super(key: key);
  final BaseAuth auth;
  @override
  State<Profile_Page> createState() => _Profile_PageState();
}

class _Profile_PageState extends State<Profile_Page> {

   //UserModel ?currentUser ;


  @override
  void initState(){
    super.initState();
    showEmail();
    findDisplayName();
  }

  String login = '....';
  Future<void> showEmail() async{
    String? email = await widget.auth.getUserEmail();
    setState(() {
      login = email!;
    });
  }

  String displayName ='...';

  Future<void> findDisplayName() async{
    await widget.auth.getCurrentUser().then((value) {
      setState((){
        displayName = value!.displayName!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Container(

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(12, 210, 193, 1.0),
                Color.fromRGBO(195, 255, 232, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),child: ListView(
          children: [
            _showForm(),
          ],
        ),
        ),
        extendBodyBehindAppBar: true,
      ),
    );
  }




  Widget _showForm() {
    return Container(
      padding: EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[

              showProfile(),
              TextUser(),
              Email(),
              Forgotpassword(),
              SignoutButton(),

            ],
          ),
        ),
      ),
    );
  }

  Widget showProfile() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5,horizontal: 40),
      width: 234,
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(154.5),
          topRight: Radius.circular(154.5),
          bottomLeft: Radius.circular(154.5),
          bottomRight: Radius.circular(154.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 10,
            offset: Offset(0, 3),
          )
        ],
        image: DecorationImage(
            image: AssetImage('assets/images/profile.png'),
            fit: BoxFit.fitWidth),
      ),
    );
  }

  Widget TextUser(){
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20,horizontal: 70),
      child: ListTile(
        title: Text(displayName),
        trailing: IconButton(
          icon: Icon(Icons.edit_outlined),
          onPressed: (){
            editThread();
          },
        )
      ),
    );
  }

  Widget Email(){
    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        //filled: true,
        //fillColor:
        color: Color.fromRGBO(255, 255, 255, 0.6000000238418579),
        //suffixIcon: Icon(Icons.account_circle),
          border: Border.all(
            color: Color.fromRGBO(66, 66, 66, 0.6),
          ),
          borderRadius: BorderRadius.circular(40)
      ),
      child: Container(
        padding: EdgeInsets.only(top: 21,left: 15),
        child: Text(login),
      ),
    );
  }




  Widget SignoutButton(){
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(220, 41, 104, 1.0),
                Color.fromRGBO(255, 118, 196, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 10,
                offset: Offset(0, 3),
              )
            ]),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          onPressed: () {},
          child: Text(
            'Signout',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Roboto Slab",
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  Future<Null> editThread()async{
      showDialog(context: context, builder: (context) => SimpleDialog(
          title: ListTile(
            leading:  Icon(Icons.account_box_outlined),
            title: Text('Edit Username'),
            subtitle: Text('Please enter new Username'),
          ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                child: TextFormField(
                  onChanged: (value) => displayName = value.trim(),
                  initialValue: displayName,

                      decoration: InputDecoration (
                        suffixIcon: Icon(Icons.edit_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: () {
                widget.auth.editDisplayName(displayName);
                Navigator.pop(context);
              }, child: Text('Edit')),
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ],
          )
        ],
        )
      );
  }

  Widget Forgotpassword() {
    return Padding(
      padding: EdgeInsets.only(top: 70),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(220, 41, 104, 1.0),
                Color.fromRGBO(255, 118, 196, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 10,
                offset: Offset(0, 3),
              )
            ]),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          onPressed: () {ForgotDialog();},
          child: Text(
            'Reset Password',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Roboto Slab",
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Future<Null> ForgotDialog() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: ListTile(
            //leading:  Icon(Icons.account_box_outlined),
            title: Text('Enter Email'),
            subtitle: Text('Please enter your email to reset password'),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 280,
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: Icon(Icons.account_circle),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    //validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                    //onSaved: (value) => _email = value!.trim(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      widget.auth.resetPassword(email: login);
                      Navigator.pop(context);
                    },
                    child: Text('Submit')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel')),
              ],
            )
          ],
        ));
  }

}

