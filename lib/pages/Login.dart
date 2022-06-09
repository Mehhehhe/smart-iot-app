import 'package:flutter/material.dart';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/pages/RegisterPage.dart';

class LogIn extends StatefulWidget {
  const LogIn({required this.auth, required this.loginCallback});

  final BaseAuth auth;
  final VoidCallback loginCallback;

  @override
  State<LogIn> createState() => _LogIn();
}

class _LogIn extends State<LogIn> {
  bool _isObscure = true;
  final _formKey = GlobalKey<FormState>();

  late String _email;
  late String _password;
  late String _errorMsg;

  bool _isLoginForm = true;
  late bool _isLoading;

  bool ValidateAndSave() {
    final form = _formKey.currentState;
    if(form!.validate()){
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
    if(ValidateAndSave()){
      String? userId = "";
      try{
        if(_isLoginForm){
          userId = await widget.auth.signIn(_email, _password);
        }else{
          print("Please signing in");
        }
        setState(() {
          _isLoading = false;
        });
        if(userId!.length > 0 && userId != null && _isLoginForm){
          widget.loginCallback();
        }
      }catch(e){
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void resetForm(){
    _formKey.currentState?.reset();
    _errorMsg = "";
  }

  void toggleFormMode(){
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
            _showCircularProgress(),
          ],
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
              showProfile(),
              showEmailInput(),
              showPasswordInput(),
              showLoginButton(),
              showRegisterButton(),
              showOtherLogInOption(),
              showErrorMsg(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showErrorMsg(){
    if(_errorMsg.isNotEmpty){
      return Text(
        _errorMsg,
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w500,
        ),
      );
    }else{
      return Container(height: 0.0,);
    }
  }

  Widget showEmailInput(){
    return Container(
      width: 300,
      height: 70,
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
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(30)),

          labelText: 'Username',
        ),
        validator: (value) => value!.isEmpty ? 'Please enter your email':null,
        onSaved: (value) => _email = value!.trim(),
      ),
    );
  }




  Widget showPasswordInput() {
    return Container(
      width: 300,
      height: 80,
      child: TextFormField(
        obscureText: _isObscure,
        //obscureText: true,
        maxLines: 1,
        decoration: InputDecoration(
          filled: true,
          fillColor:
          Color.fromRGBO(255, 255, 255, 0.6000000238418579),
          suffixIcon: IconButton(
              icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
            onPressed: (){
                setState((){
                  _isObscure = !_isObscure;
                });
            },
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          labelText: 'Password',
        ),
        validator: (value) => value!.isEmpty ? 'Please enter password':null,
        onSaved: (value) => _password = value!.trim(),
      ),
    );
  }



  Widget showLoginButton(){
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
            RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
          ),
        ),
        onPressed: ValidateAndSubmit,
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

  Widget showRegisterButton(){
    return Container(
      width: 200,
      height: 50,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(220, 157, 41, 1.0),
              Color.fromRGBO(255, 187, 118, 1.0),
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
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Register(
                auth: widget.auth,
                loginCallback: widget.loginCallback,
              )
              ),
          );
        },
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

  Widget showTitle(){
    return Container(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          'SMART IOT APP',
          textAlign: TextAlign.left,
          style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontFamily: 'Roboto Slab',
              fontSize: 30,
              letterSpacing:
              0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.bold,
              height: 1,
              shadows: [
                Shadow(
                  blurRadius: 30,
                  color: Colors.black,
                  offset: Offset(0, 3),
                ),
              ]
          ),
        ));
  }

  Widget showProfile() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 26,horizontal: 40),
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

  Widget showOtherLogInOption(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(
            icon: Image.asset('assets/images/Facebook_icon.png'),
            iconSize: 50,
            onPressed: () {},
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(10.0),
          child: IconButton(

            icon: Image.asset('assets/images/google_icon.png'),
            iconSize: 60,
            onPressed: () {},
          ),

        ),


      ],
    );
  }
}

