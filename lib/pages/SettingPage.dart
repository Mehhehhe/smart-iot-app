import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';
import 'package:smart_iot_app/main.dart';


class Setting_Page extends StatefulWidget {
  const Setting_Page({Key? key}) : super(key: key);

  @override
  State<Setting_Page> createState() => _Setting_PageState();
}

class _Setting_PageState extends State<Setting_Page> with TickerProviderStateMixin{

  bool notiButton_1 = true;
  bool notiButton_2 = false;

  bool changeThemestate = false;

  late final AnimationController _controller;


  @override
  void initstate() {
    super.initState();
    _controller = new AnimationController(vsync: this);
  }


  final List<String> topics = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(

          //decoration: BoxDecoration(
            //image: DecorationImage(
              //image: changeThemestate == false ? AssetImage('assets/images/bg_profile.jpg') : AssetImage('assets/images/bg_setting.jpg'),
                //fit: BoxFit.cover
                //,
            //),


          //),
        child: ListView(
          children: [
            _showForm(),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
    );
  }

  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text('Display', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,),),
              const SizedBox(height: 13,),
              Divider(color: Colors.white70,),
              const SizedBox(height: 10,),
              displaySettingButton(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                child: Text('Notification', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,),),
              ),
              //Divider(color: Colors.white70,),
              const SizedBox(height: 5,),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Allow all notification', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,),),
                  Switch(value: notiButton_1, onChanged: (value) {
                    setState(() {
                      notiButton_1 = value;
                      notiButton_1 == true ? notiButton_2 = false : notiButton_2 = true ;
                    });
                  },activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,)
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select topics', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,),),
                  DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      hint: Text(
                        'Select Item',
                        style: TextStyle(
                          fontSize: 15,
                          //color: Color.fromRGBO(155, 155, 155, 1.0),
                        ),
                      ),
                      items: topics
                          .map((item) =>
                          DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 15,color:
                              Color.fromRGBO(155, 155, 155, 1.0),
                              ),
                            ),
                          ))
                          .toList(),
                      value: selectedValue,
                      onChanged: (value) {
                        setState(() {
                          selectedValue = value as String;
                        });
                      },
                      buttonHeight: 40,
                      buttonWidth: 100,
                      itemHeight: 40,

                    ),
                  ),
                  
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('None Select', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,),),
                  Switch(value: notiButton_2, onChanged: (value) {
                    setState(() {
                      notiButton_2 = value;
                      notiButton_2 == true ? notiButton_1 = false : notiButton_1 = true ;
                    });
                  },activeTrackColor: Colors.lightGreenAccent,
                    activeColor: Colors.green,)
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 10),
                child: Text('Theme', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25,),),
              ),

              const SizedBox(height: 5,),
              themeChange(),
              const SizedBox(height: 5,),
              submitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget displaySettingButton(){
    return Row(
      children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Container(
              width: 105,
              height: 45,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 33, 194, 1.0),
                      Color.fromRGBO(70, 153, 255, 1.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                child: const Text(
                  'Grid',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: "Roboto Slab",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Container(
            width: 105,
              height: 45,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(0, 33, 194, 1.0),
                      Color.fromRGBO(70, 153, 255, 1.0),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
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
                child: const Text(
                  'Column',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: "Roboto Slab",
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: 0.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Container(
            width: 105,
            height: 45,
            decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromRGBO(0, 33, 194, 1.0),
                    Color.fromRGBO(70, 153, 255, 1.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
              child: const Text(
                'Row',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Roboto Slab",
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }


  Widget submitButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 30),
      child: Container(
        //width: 50,
        height: 50,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(6, 0, 220, 1.0),
                Color.fromRGBO(211, 79, 255, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: const BorderRadius.all(
              Radius.circular(25.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 3),
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
          child: const Text(
            'Submit',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: "Roboto Slab",
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }


  Widget themeChange(){
    return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 160,
            height: 45,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: changeThemestate
                      ? [
                    const Color.fromRGBO(203, 203, 203, 0.4),
                    const Color.fromRGBO(175, 175, 175, 0.4),
                  ]
                      : [
                    const Color.fromRGBO(255, 255, 255, 1.0),
                    const Color.fromRGBO(217, 217, 217, 1.0),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                setState(() {
                  changeThemestate = !changeThemestate;
                  context.read<Mytheme>().switchTheme();
                });
              },
              child: const Text(
                'Light',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Roboto Slab",
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.0,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            width: 160,
            height: 45,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: changeThemestate
                      ? [
                    const Color.fromRGBO(23, 23, 23, 1.0),
                    const Color.fromRGBO(54, 54, 54, 1.0),
                  ]
                      : [
                    const Color.fromRGBO(203, 203, 203, 0.2),
                    const Color.fromRGBO(175, 175, 175, 0.2),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.all(
                  Radius.circular(25.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 4,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                setState(() {
                  changeThemestate = !changeThemestate;
                  context.read<Mytheme>().switchTheme();
                });
              },
              child: const Text(
                'Dark',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontFamily: "Roboto Slab",
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }






}





