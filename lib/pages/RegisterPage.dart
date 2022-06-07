import 'package:flutter/material.dart';
import 'package:smart_iot_app/pages/MainPage.dart';
import 'package:smart_iot_app/services/authentication.dart';

class Register extends StatefulWidget {
  const Register({required this.auth, required this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  late String _email;
  late String _password;
  late String _errMsg;

  bool _isRegisForm = true;
  late bool _isLoading;

  bool ValidateAndSave() {
    final form = _formKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }
    return false;
  }

  Future<void> ValidateAndSubmit() async{
    setState(() {
      _errMsg = "";
      _isLoading = true;
      _isRegisForm = true;
    });

    if(ValidateAndSave()){
      String? userId = "";
      try{
        if(_isRegisForm){
          userId = await widget.auth.register(_email, _password);
        }else{
          print("Please register first");
        }
        setState(() {
          _isLoading = false;
        });
        if(userId!.length > 0 && userId != null && _isRegisForm){
          widget.loginCallback();
        }
        Navigator.pop(context);
      }catch(e){
        setState(() {
          _isLoading = false;
          _errMsg = e.toString();
          _formKey.currentState?.reset();
        });
      }
    }
  }

  @override
  void initState(){
    _errMsg = "";
    _isLoading = false;
    _isRegisForm = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: Row(
          children: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text(
                "Back",
                style: TextStyle(
                  color: Colors.black,
                ),
                textAlign: TextAlign.start,
              )
          )],
        ),

      ),
        backgroundColor: Color.fromRGBO(255, 203, 182, 1.0),
        body: Stack(
          children: [
            _showForm(),
            _showCircularProgress(),
          ],
        ),
      extendBodyBehindAppBar: true,
    );
  }
  Widget _showForm() {
    return Container(
      //padding: EdgeInsets.all(25.0),
      //margin: EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[

              _Text1(),
              EmailRegister(),
              PasswordRegister(),
              RegisterButton(),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose(){
    super.dispose();
  }

  void resetForm(){
    _formKey.currentState?.reset();
    _errMsg = "";
  }

  void toggleFormMode(){
    resetForm();
    setState(() {
      _isRegisForm != _isRegisForm;
    });
  }

  Widget _Text1(){
    return Container(margin: EdgeInsets.symmetric(horizontal: 20,vertical: 30),

        child: Text(
          'Welcome to Smart IOT APP',
          textAlign: TextAlign.left,
          style: TextStyle(
            color: Color.fromRGBO(0, 0, 0, 1.0),
            fontFamily: 'Roboto Slab',
            fontSize: 20,
            letterSpacing:
            0 /*percentages not used in flutter. defaulting to zero*/,
            fontWeight: FontWeight.bold,
            height: 1,

          ),
        ));
  }

  Widget EmailRegister(){
    return Container(margin: EdgeInsets.symmetric(horizontal: 20),
      width: 300,
      height: 80,
      child: TextFormField(
        obscureText: false,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          filled: true,
          fillColor:
          Color.fromRGBO(255, 255, 255, 0.6000000238418579),
          suffixIcon: Icon(Icons.account_circle),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30)),
          labelText: 'Username',
        ),
        validator: (value) => value!.isEmpty ? 'Please enter your email':null,
        onSaved: (value) => _email = value!.trim(),
      ),
    );
  }

  Widget PasswordRegister() {
    return Container(margin: EdgeInsets.symmetric(horizontal: 20),
      width: 300,
      height: 100,
      child: TextFormField(
        obscureText: true,
        maxLines: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor:
          Color.fromRGBO(255, 255, 255, 0.6000000238418579),
          suffixIcon: Icon(Icons.remove_red_eye),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          labelText: 'Password',
        ),
        validator: (value) => value!.isEmpty ? 'Please enter your password':null,
        onSaved: (value) => _password = value!.trim(),
      ),
    );
  }

  Widget RegisterButton(){
    return Container(
      margin: EdgeInsets.symmetric(vertical: 70,horizontal: 20),

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
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        onPressed: ValidateAndSubmit,
        child: Text(
          'Register',
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

  Widget _showCircularProgress() {
    if(_isLoading){
      return Center(child: CircularProgressIndicator(),);
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }
}

/*Widget _showCircularProgress() {
  if(_isLoading){
    return Center(child: CircularProgressIndicator(),);
  }
  return Container(
    height: 0.0,
    width: 0.0,
  );
}*/



