import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        backgroundColor: Color.fromRGBO(255, 203, 182, 1.0),
        body: Stack(
          children: [
            _showForm(),
          ],
        )
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

Widget _showForm() {
  return Container(
    //padding: EdgeInsets.all(25.0),
    //margin: EdgeInsets.symmetric(horizontal: 20),
    child: Form(
      //key: _formKey,
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[

            _Text1(),
            EmailRegister(),
            PasswordRegister(),
            _Text2(),
            OtherLogInOption(),
            RegisterButton(),

          ],
        ),
      ),
    ),
  );
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
    ),
  );
}

Widget _Text2(){
  return Container(

      child: Text(
        'or',
        textAlign: TextAlign.center,
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

Widget OtherLogInOption(){
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
      onPressed: (){},
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