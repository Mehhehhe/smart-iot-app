import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:smart_iot_app/services/authentication.dart';
import 'package:smart_iot_app/services/image_op.dart';

class Profile_Page extends StatefulWidget {
  const Profile_Page({Key? key, required this.auth}) : super(key: key);
  final BaseAuth auth;

  @override
  State<Profile_Page> createState() => _Profile_PageState();

}

class _Profile_PageState extends State<Profile_Page> {
   Image? imageNet;
   File? image;
   bool finishSetState = false;

  @override
  void initState(){
    super.initState();
    showEmail();
    findDisplayName();
  }

  String login = '....';
  Future<void> showEmail() async{
    String? email = await widget.auth.getUserEmail();
    setState(() {
      login = email!;
    });
  }

  String displayName ='...';

  Future<void> findDisplayName() async{
    await widget.auth.getCurrentUser().then((value) {
      setState((){
        displayName = value!.displayName!;
        finishSetState = true;
        setProfileFromFireStorage();
      });
    });
  }

  Future<void> setProfileFromFireStorage() async {
    ImageStorageManager img = ImageStorageManager();
    String url = await img.getImageFromStorage(displayName);

    setState(() {
      imageNet = Image.network(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(

          backgroundColor: Colors.transparent,
          elevation: 0.0,
        ),
        body: Container(

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(12, 210, 193, 1.0),
                Color.fromRGBO(195, 255, 232, 1.0),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),child: ListView(
          children: [
            _showForm(),
          ],
        ),
        ),
        extendBodyBehindAppBar: true,
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

              showProfile(),
              addPhoto(),
              textUser(),
              email(),
              submitButton(),
              forgotPassword(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showProfile() {
    return Builder(
      builder: (context)=>Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child:  CircleAvatar(
                  radius: 130,
                  backgroundColor: Colors.grey,
                  child: ClipOval(
                    child: SizedBox(
                      width: 240,
                      height: 240,
                      child: imageNet ?? Image.network("https://icon-library.com/images/9272.png",fit:BoxFit.fill ,) ,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

    );
  }

  Widget addPhoto(){
    return Padding(
  padding:const EdgeInsets.only(left: 200),
  child: IconButton(
  onPressed: (){
    getImage();
    //widget.auth.getProfile();
  },
  icon: const Icon(Icons.add_a_photo,size: 30,),
  ),
  );
}
//icon: Image.asset('assets/images/profile.png'),

  Widget textUser(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 70),
      child: ListTile(
        title: Text(displayName),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined),
          onPressed: (){
            editThread();
          },
        )
      ),
    );
  }

  Widget email(){
    return Container(
      width: 300,
      height: 60,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
          border: Border.all(
            color: const Color.fromRGBO(66, 66, 66, 0.6),
          ),
          borderRadius: BorderRadius.circular(40)
      ),
      child: Container(
        padding: const EdgeInsets.only(top: 21,left: 15),
        child: Text(login),
      ),
    );
  }

  Widget submitButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(220, 41, 104, 1.0),
                Color.fromRGBO(255, 118, 196, 1.0),
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
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          onPressed: () {
            //uploadPic(this.context);
            ImageStorageManager img = ImageStorageManager();
            img.uploadPic(context, image, displayName);
          },
          child: const Text(
            'Submit',
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
    );
  }

  Widget signOutButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(220, 41, 104, 1.0),
                Color.fromRGBO(255, 118, 196, 1.0),
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
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          onPressed: () {},
          child: const Text(
            'Signout',
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
    );
  }

  Future<Null> editThread()async{
      showDialog(context: context, builder: (context) => SimpleDialog(
          title: const ListTile(
            leading:  Icon(Icons.account_box_outlined),
            title: Text('Edit Username'),
            subtitle: Text('Please enter new Username'),
          ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: TextFormField(
                  onChanged: (value) => displayName = value.trim(),
                  initialValue: displayName,

                      decoration: InputDecoration (
                        suffixIcon: Icon(Icons.edit_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              TextButton(onPressed: () {
                widget.auth.editDisplayName(displayName);
                Navigator.pop(context);
              }, child: const Text('Edit')),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ],
          )
        ],
        )
      );
  }

  Widget forgotPassword() {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: Container(
        width: 200,
        height: 50,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(220, 41, 104, 1.0),
                Color.fromRGBO(255, 118, 196, 1.0),
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
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0)),
            ),
          ),
          onPressed: () {forgotDialog();},
          child: const Text(
            'Reset Password',
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
    );
  }

  Future<void> forgotDialog() async {
    showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          title: const ListTile(
            title: Text('Enter Email'),
            subtitle: Text('Please enter your email to reset password'),
          ),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 280,
                  child: TextFormField(
                    decoration: InputDecoration(
                      suffixIcon: const Icon(Icons.account_circle),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    //validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
                    //onSaved: (value) => _email = value!.trim(),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                    onPressed: () {
                      widget.auth.resetPassword(email: login);
                      Navigator.pop(context);
                    },
                    child: const Text('Submit')),
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
              ],
            )
          ],
        ));
  }

  Future getImage () async{
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
    } on PlatformException catch(e) {
      if (kDebugMode) {
        print('Failed to pick image: $e');
      }
    }
  }
}
