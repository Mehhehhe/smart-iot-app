import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_app/main.dart';


class History_Page extends StatefulWidget {
  const History_Page({Key? key}) : super(key: key);

  @override
  State<History_Page> createState() => _History_PageState();
}

class _History_PageState extends State<History_Page> {
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(241, 241, 241, 1.0),
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
      padding: const EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              sortHistory(),
              history_cardPreset()
            ],
          ),
      ),
    );
  }

  Widget history_cardPreset() {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      shadowColor: Colors.black,
      elevation: 15,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),),
      //color : Color.fromRGBO(255, 255, 255, 0.75),
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Device : Automatic car feeding device',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('แสดงประวัติ ข้อความหรือการทำงานของ device',
                    style: TextStyle(fontSize: 12),),
                  Text('Timestamp', style: TextStyle(fontSize: 12),),
                ],
              ),
            )

          ],
        ),
      ),
    );
  }

  Widget sortHistory() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 400,
        height: 50,
        decoration: BoxDecoration(
          color: Color.fromRGBO(255, 255, 255, 0.8),
          borderRadius: const BorderRadius.all(
            Radius.circular(25.0),
          ),),

        
        child: ThemeSwitcher(
          builder: (context) => OutlinedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              ),
            ),
            onPressed: () {
            },
            child: const Text(
              'Sort History',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontFamily: "Roboto Slab",
                fontWeight: FontWeight.w600,
                fontSize: 18,
                letterSpacing: 0.0,
                color: Color.fromRGBO(70, 70, 70, 0.80196078431372547),
              ),
            ),
          ),
        ),



      ),
    );
  }

}

