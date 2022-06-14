import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/ResetPassWordPage.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/RegisterPage.dart';

class ResetPassWord_Page extends StatefulWidget {
  const ResetPassWord_Page({Key? key, required this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<ResetPassWord_Page> createState() => _ResetPassWord_PageState();
}

class _ResetPassWord_PageState extends State<ResetPassWord_Page> {
  String _email ='...';
  String login = '....';
  final _formKey = GlobalKey<FormState>();

  Future<void> showEmail() async{
    String? email = await widget.auth.getUserEmail();
    setState(() {
      login = email!;
    });
  }

  late String _errorMsg;

  bool _isLoginForm = true;
  late bool _isLoading;

  bool ValidateAndSave() {
    final form = _formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Future<void> ValidateAndSubmit() async {
    setState(() {
      _errorMsg = "";
      _isLoading = true;
      _isLoginForm = true;
    });
    if (ValidateAndSave()) {
      String? userId = "";
      try {
        setState(() {
          login = _email;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMsg = e.toString();
          _formKey.currentState?.reset();
        });
      }
    }
  }

  @override
  void initState() {
    //_controller = TextEditingController();
    _errorMsg = "";
    _isLoading = false;
    _isLoginForm = false;
    showEmail();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetForm() {
    _formKey.currentState?.reset();
    _errorMsg = "";
  }

  void toggleFormMode() {
    resetForm();
    setState(() {
      _isLoginForm != _isLoginForm;
    });
  }









  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Color.fromRGBO(146, 252, 232, 1.0),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(4, 97, 114, 1.0),
              Color.fromRGBO(120, 220, 212, 1.0),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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
      padding: EdgeInsets.all(15.0),
      child: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //showTitle(),
              showEmailInput(),
              showLoginButton(),

            ],
          ),
        ),
      ),
    );
  }


  Widget showEmailInput() {
    return Container(
      width: 300,
      height: 70,
      child: TextFormField(
        obscureText: false,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromRGBO(255, 255, 255, 0.6000000238418579),
          suffixIcon: Icon(Icons.account_circle),
          border: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(30)),
          labelText: 'Username',
        ),
        validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
        onSaved: (value) => _email = value!.trim(),
      ),
    );
  }


  Widget showLoginButton() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      width: 200,
      height: 50,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(73, 187, 167, 1.0),
              Color.fromRGBO(142, 238, 109, 1.0),
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
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        onPressed: (){
          ValidateAndSubmit();
          widget.auth.resetPassword(email: _email);
          Navigator.pop(context);
        },
        child: Text(
          'Login',
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
    );
  }


}
