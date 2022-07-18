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

      ),

        child: Stack(
          children: [
          Container(
        margin: EdgeInsets.symmetric(horizontal: 10,vertical: 16),
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
            cardPreset(),
            cardPreset(),
            cardPreset(),
            cardPreset(),
            cardPreset(),
            cardPreset(),
            cardPreset(),
            cardPreset(),

          ],
        ),
      ),
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
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              //cardPreset()
            ],
          ),
        ),
      ),
    );
  }

  Widget cardPreset() {
    return Card(
      //margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                image: const NetworkImage(
                    'https://static.onecms.io/wp-content/uploads/sites/20/2021/04/30/petlibro-automatic-cat-feeder-timed-tout.jpg'),
                height: 115 ,
                fit: BoxFit.cover,
                child: InkWell(
                  onTap: () {},
                ),
              ),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(bottom: 5),
                child:
                Text('Cat feeding machine'),
              ),
            ],
          )
        ],
      ),
    );
  }

}
