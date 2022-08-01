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

          decoration: BoxDecoration(
            image: DecorationImage(
              image : AssetImage('assets/images/bg_profile.jpg'),
              fit: BoxFit.cover
            ),

          ),child: ListView(
          children: [
            showProfile(),
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
              textUser(),
              email(),
              changePassword(),
              activeDevice(),
              //systenMessage(),

              submitButton(),
              //forgotPassword(),
            ],
          ),
        ),
      ),
    );
  }


Widget showProfile(){
    return Container(
      //  padding: EdgeInsets.symmetric(vertical: 10),
      child: RawMaterialButton(
        onPressed: () {
          getImage();
        },
        elevation: 2.0,
        fillColor: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.center,
              child:  CircleAvatar(
                radius: 100,
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
        padding: EdgeInsets.all(3.0),
        shape: CircleBorder(),
      ),
    );
}



  Widget textUser(){
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 70),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(displayName, style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            shadows: [
              Shadow(
                offset: Offset(0.0, 0.0),
                blurRadius: 0.0,
                color: Colors.black,
              ),
            ]
          ),),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: (){
              editThread();
            },
          )
        ],

      ),
    );
  }

   Widget email(){
     return Container(
       padding: const EdgeInsets.only(top: 15),
       child: Row(
         mainAxisAlignment: MainAxisAlignment.center,
         children: [
           Text(login, style: TextStyle(
               fontSize: 15,
               shadows: [
                 Shadow(
                   offset: Offset(0.0, 0.0),
                   blurRadius: 0.0,
                   color: Colors.black,
                 ),
               ]
           ),),
         ],

       ),
     );
   }

   Widget changePassword(){
    return TextButton(
      style: TextButton.styleFrom( primary: Color.fromARGB(255, 0, 0, 183),
        textStyle: const TextStyle(fontSize: 16,),
      ),
      onPressed: () {forgotDialog();},
      child: const Text('Change password'),
    );
   }
   Widget activeDevice(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Container(
          height: 100,
          //margin: EdgeInsets.only(top: 150,left: 20,right: 20),
          decoration: BoxDecoration(
            borderRadius : BorderRadius.circular(8),
            color : Color.fromRGBO(255, 255, 255, 0.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius:2,
                blurRadius: 5,
                offset: Offset(0, 10), // changes position of shadow
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.phone_android_rounded,size: 80,),
              Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text('Active Device', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                  Text('null devices actived', style: TextStyle(fontSize:17 ,color: Colors.white,))
                ],
              )
            ],
      ),
          )
      ),
    );
   }

   Widget systenMessage(){
     return Container(
         height: 200,
         //margin: EdgeInsets.only(top: 150,left: 20,right: 20),
         decoration: BoxDecoration(
           borderRadius : BorderRadius.circular(8),
           color : Color.fromRGBO(255, 255, 255, 0.2),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.1),
               spreadRadius:2,
               blurRadius: 5,
               offset: Offset(0, 10), // changes position of shadow
             ),
           ],
         ),
         child: Padding(
           padding: EdgeInsets.only(left: 10),
           child: Row(
             children: [
               Icon(Icons.person,size: 80,),
               Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: [
                   Text('System massage', style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                   Container(
                     height: 70,width: 240,
                     decoration: BoxDecoration(
                       borderRadius : BorderRadius.circular(8),
                       color : Color.fromRGBO(255, 255, 255, 0.2),
                     ),
                     child: Column(mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text('05/07/2022 15:02'),
                         Text('Massage : Hello World!')
                       ],
                     ),
                   ),
                   Container(
                     height: 70,width: 240,
                     decoration: BoxDecoration(
                       borderRadius : BorderRadius.circular(8),
                       color : Color.fromRGBO(255, 255, 255, 0.2),
                     ),
                     child: Column(mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         Text('05/07/2022 15:05'),
                         Text('Massage : Bye bye')
                       ],
                     ),
                   ),
                 ],
               )
             ],
           ),
         )
     );
   }

  Widget submitButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Container(
        //width: z,
        height: 50,
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color.fromRGBO(255, 0, 0, 1.0),
                Color.fromRGBO(255, 120, 120, 1.0),
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
              fontSize: 22,
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
