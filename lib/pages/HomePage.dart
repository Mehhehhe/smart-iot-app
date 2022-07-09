import 'package:flutter/material.dart';



class Home_Page extends StatefulWidget {
  const Home_Page({Key? key}) : super(key: key);

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(


            color : Color.fromRGBO(241, 241, 241, 1.0),


      ),

        child: Stack(
          children: [
          Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
        decoration: BoxDecoration(
            color:  Color.fromARGB(50, 133, 133, 133),
            borderRadius: BorderRadius.all(Radius.circular(22))
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 15),
                child: TextFormField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search device',
                    helperStyle: TextStyle(
                      color : Color.fromRGBO(241, 241, 241, 1.0),
                    ),
                    icon: Icon(Icons.search, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.only(top: 60),
        child: GridView.extent(

          maxCrossAxisExtent: 200,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            Container(color: Colors.red,),
            Container(color: Colors.yellow,),
            Container(color: Colors.blue,),
            Container(color: Colors.greenAccent,),

          ],
        ),
      ),
            //_showForm(),

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
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              cardPreset()
            ],
          ),
        ),
      ),
    );
  }



  Widget cardPreset(){
    return Container(
      
    );
  }



}
