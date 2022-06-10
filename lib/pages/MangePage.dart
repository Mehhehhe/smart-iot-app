import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class Manage_Page extends StatefulWidget {
  const Manage_Page({Key? key}) : super(key: key);

  @override
  State<Manage_Page> createState() => _Manage_PageState();
}

class _Manage_PageState extends State<Manage_Page> {

  bool sensorvalue = true;

  final scaffKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(195, 255, 232, 1.0),
              Color.fromRGBO(12, 210, 193, 1.0),
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
      extendBodyBehindAppBar: true,
    );


  }

  Widget _showForm() {
    return Container(
      //padding: EdgeInsets.all(15.0),
      child: Form(
        //key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[

              DeviceName(),
              DeviceImage(),
              MangeSensor()
            ],
          ),
        ),
      ),
    );
  }

  Widget DeviceName(){
    return Container(
      margin: EdgeInsets.only(left: 30, right: 30 ,bottom: 10),
      child: Text(
        'Device 1 : เครื่องผลิตอัลปาก้า',
        textAlign: TextAlign.left,
        style: TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1.0),
          fontFamily: 'Roboto Slab',
          fontSize: 25,
          letterSpacing:
          0 /*percentages not used in flutter. defaulting to zero*/,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
    );
  }

  Widget DeviceImage() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 30,vertical: 15),
      shadowColor: Colors.black,
      elevation: 15,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Ink.image(
                image: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/6080/6080697.png'),
                child: InkWell(
                  onTap: () {},
                ),
                height: 240,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget MangeSensor() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(left: 40,top: 10,bottom: 15),
            child: Text('Sensor ตรวจจับที่ 1',
              style: TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1.0),
              fontFamily: 'Roboto Slab',
              fontSize: 15,
              letterSpacing:
              0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.bold,
              height: 1,
            ),)),
        Container(
          margin: EdgeInsets.only(top: 20,),
          child: Card(
          margin: EdgeInsets.only(left: 30,right: 150 ,top: 10),
          shadowColor: Colors.black,
          elevation: 15,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  Ink.image(
                    image: NetworkImage(
                        'https://th.mouser.com/images/marketingid/2012/img/103485542_Omron_D6T-Series-MEMS-Thermal-Sensors.png?v=031122.0515'),
                    child: InkWell(
                      onTap: () {},
                    ),
                    height: 100,
                    width: 120,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ],
          ),
      ),
        ),
        Container(
          margin: EdgeInsets.only(left: 170,top: 30),
          child: CupertinoSwitch(
            activeColor: Colors.blue,
            value: sensorvalue,
            onChanged: (value) => setState(() => this.sensorvalue = value),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 175,top: 80),
          width: 80,
          height: 50,
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(
              filled: true,
              fillColor:
              Color.fromRGBO(255, 255, 255, 0.6000000238418579),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'ค่าที่ 1',
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 265,top: 80),
          width: 80,
          height: 50,
          child: TextFormField(
            maxLines: 1,
            decoration: InputDecoration(
              filled: true,
              fillColor:
              Color.fromRGBO(255, 255, 255, 0.6000000238418579),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              labelText: 'ค่าที่ 2',
            ),
          ),
        ),


      ],
    );
  }


}
