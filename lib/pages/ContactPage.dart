import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Contact_page extends StatefulWidget {
  const Contact_page({Key key}) : super(key: key);

  @override
  State<Contact_page> createState() => _Contact_pageState();
}

class _Contact_pageState extends State<Contact_page> {
  final List<String> CatagoryItems = [
    'Bug',
    'Request',
    'Suggestion',
    'Other',
  ];
  String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 75),
          child: Text(
            'Contact',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/bg_contact.jpg'),
              fit: BoxFit.cover),
        ),
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
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: Form(
        //key: _formKey,
        child: Center(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              Text(
                'Name',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              nameInput(),
              Text(
                'Phome number',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              phoneInput(),
              Text(
                'Email',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              emailInput(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Topic',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  categoryDropdown(),
                ],
              ),
              topicInput(),
              Text(
                'Detail',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
              detailInput(),
              submitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget nameInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 10,
        child: TextFormField(
          obscureText: false,
          maxLines: 1,
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Username',
          ),
        ),
      ),
    );
  }

  Widget phoneInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 300,
        child: TextFormField(
          obscureText: false,
          maxLines: 1,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget emailInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 300,
        child: TextFormField(
          obscureText: false,
          maxLines: 1,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Email adreess',
          ),
        ),
      ),
    );
  }

  Widget topicInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 300,
        child: TextFormField(
          obscureText: false,
          maxLines: 1,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Username',
          ),
        ),
      ),
    );
  }

  Widget categoryDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text(
            'Select Catagory',
            style: TextStyle(
              fontSize: 15,
              color: Color.fromRGBO(215, 215, 215, 1.0),
            ),
          ),
          items: CatagoryItems.map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color.fromRGBO(155, 155, 155, 1.0),
                  ),
                ),
              )).toList(),
          value: selectedValue,
          onChanged: (value) {
            setState(() {
              selectedValue = value as String;
            });
          },
          buttonHeight: 40,
          buttonWidth: 130,
          itemHeight: 40,
        ),
      ),
    );
  }

  Widget detailInput() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: 300,
        child: TextFormField(
          //obscureText: false,
          maxLines: 3,
          keyboardType: TextInputType.multiline,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color.fromRGBO(255, 255, 255, 0.8),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12),
            ),
            hintText: 'Username',
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
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
                color: Colors.pink.withOpacity(0.2),
                spreadRadius: 4,
                blurRadius: 10,
                offset: const Offset(0, 3),
              )
            ]),
        child: OutlinedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
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
}
