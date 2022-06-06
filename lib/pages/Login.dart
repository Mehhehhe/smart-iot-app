import 'package:flutter/material.dart';

class Test_tf extends StatefulWidget {
  const Test_tf({Key? key}) : super(key: key);

  @override
  State<Test_tf> createState() => _Test_tf();
}

class _Test_tf extends State<Test_tf> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(146, 252, 232, 1.0),
      body: Center(
          child: SafeArea(
        child: Center(
          child: Column(
            children: [


              Container(
                margin: EdgeInsets.symmetric(vertical: 50),
                width: 234,
                height: 234,
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
              ),


              Container(
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
              )),


              Container(

                width: 300,
                height: 80,
                child: TextField(
                  obscureText: false,
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
              ),


              Container(
                width: 300,
                height: 60,
                child: TextField(
                  obscureText: true,
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
              ),


              Container(
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
                  onPressed: () {},
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
              ),


              Container(
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
                  onPressed: () {},
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
              ),



              Row(
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
              ),



            ],
          ),
        ),
      )),
    );
  }
}
