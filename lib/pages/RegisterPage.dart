// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:smart_iot_app/services/authentication.dart';

// class Register extends StatefulWidget {
//   const Register({required this.auth, required this.loginCallback});

//   final BaseAuth auth;
//   final VoidCallback loginCallback;

//   @override
//   State<Register> createState() => _RegisterState();
// }

// class _RegisterState extends State<Register> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isObscure = true;

//   late String _username;
//   late String _email;
//   late String _password;
//   late String _errMsg;

//   bool _isRegisForm = true;
//   late bool _isLoading;

//   bool validateAndSave() {
//     final form = _formKey.currentState;
//     if (form!.validate()) {
//       form.save();
//       return true;
//     }
//     return false;
//   }

//   Future<void> validateAndSubmit() async {
//     setState(() {
//       _errMsg = "";
//       _isLoading = true;
//       _isRegisForm = true;
//     });

//     if (validateAndSave()) {
//       String? userId = "";
//       try {
//         if (_isRegisForm) {
//           userId = await widget.auth.register(_username, _email, _password);
//         } else {
//           if (kDebugMode) {
//             print("Please register first");
//           }
//         }
//         setState(() {
//           _isLoading = false;
//         });
//         if (userId!.isNotEmpty && _isRegisForm) {
//           widget.loginCallback();
//         }
//         Navigator.pop(context);
//       } catch (e) {
//         setState(() {
//           _isLoading = false;
//           _errMsg = e.toString();
//           _formKey.currentState?.reset();
//         });
//       }
//     }
//   }

//   @override
//   void initState() {
//     _errMsg = "";
//     _isLoading = false;
//     _isRegisForm = false;
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//       ),
//       //backgroundColor: Color.fromRGBO(255, 203, 182, 1.0),
//       body: Stack(
//         children: [
//           //_showCircularProgress(),

//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Color.fromRGBO(255, 63, 242, 1.0),
//                   Color.fromRGBO(123, 168, 255, 1.0),
//                 ],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),


//           _showCircularProgress(),
//           loginFrame(),
//           _showForm()
//         ],
//       ),

//       extendBodyBehindAppBar: true,
//     );
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void resetForm() {
//     _formKey.currentState?.reset();
//     _errMsg = "";
//   }

//   void toggleFormMode() {
//     resetForm();
//     setState(() {
//       _isRegisForm != _isRegisForm;
//     });
//   }

//   Widget _showCircularProgress() {
//     if (_isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(),
//       );
//     }
//     return const SizedBox(
//       height: 0.0,
//       width: 0.0,
//     );
//   }

//   Widget _showForm() {
//     return Form(
//       key: _formKey,
//       child: Center(
//         child: ListView(
//           shrinkWrap: true,
//           children: <Widget>[
//             //showTitle(),
//             //textTitle(),
//             showLogo(),
//             UserNametext(),
//             userNameBox(),
//             Emailtext(),
//             emailRegis(),
//             Passwordtext(),
//             passwordRegis(),
//             regisButton(),
//           ],
//         ),
//       ),
//     );
//   }



//   Widget textTitle(){
//     return Container(
//         margin: const EdgeInsets.only(left: 30, right: 30 ,bottom: 10),
//         child: const Text(
//           'Sign up',
//           textAlign: TextAlign.left,
//           style: TextStyle(
//             color: Color.fromRGBO(0, 0, 0, 1.0),
//             fontFamily: 'Roboto Slab',
//             fontSize: 25,
//             letterSpacing:
//             0 /*percentages not used in flutter. defaulting to zero*/,
//             fontWeight: FontWeight.bold,
//             height: 1,
//           ),
//         ),
//     );
//   }
//   Widget UserNametext(){
//     return Container(
//       margin: EdgeInsets.only(left: 30,bottom: 15),
//       alignment: Alignment.bottomLeft,
//       child: Text(
//         "Username",
//         textAlign: TextAlign.left,
//         style: TextStyle(color: Colors.white,fontSize: 17,
//           shadows: <Shadow>[
//             Shadow(
//               offset: Offset(0.0, 2.0),
//               blurRadius: 12,
//               color: Color.fromARGB(255, 0, 0, 0),
//             ),
//           ],),
//       ),
//     );
//   }

//   Widget userNameBox() {
//     return Container(
//       margin: const EdgeInsets.only(left: 30, right: 30, bottom: 20),
//       child: TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         keyboardType: TextInputType.name,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
//           suffixIcon: const Icon(Icons.account_box_outlined),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           labelText: 'Username',
//         ),
//         validator: (value) =>
//         value!.isEmpty ? 'Please enter your username' : null,
//         onSaved: (value) => _username = value!.trim(),
//       ),
//     );
//   }

//   Widget Emailtext(){
//     return Container(
//       margin: EdgeInsets.only(left: 30,bottom: 15),
//       alignment: Alignment.bottomLeft,
//       child: Text(
//         "Email address",
//         textAlign: TextAlign.left,
//         style: TextStyle(color: Colors.white,fontSize: 17,
//           shadows: <Shadow>[
//             Shadow(
//               offset: Offset(0.0, 2.0),
//               blurRadius: 12,
//               color: Color.fromARGB(255, 0, 0, 0),
//             ),
//           ],),
//       ),
//     );
//   }

//   Widget emailRegis(){
//     return Container(
//       margin: const EdgeInsets.only(left: 30, right: 30 ,bottom: 20),
//       child: TextFormField(
//         obscureText: false,
//         maxLines: 1,
//         keyboardType: TextInputType.emailAddress,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor: const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
//           suffixIcon: const Icon(Icons.account_circle),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           labelText: 'Email',
//         ),
//         validator: (value) =>
//         value!.isEmpty ? 'Please enter your email' : null,
//         onSaved: (value) => _email = value!.trim(),
//       ),
//     );
//   }

//   Widget Passwordtext(){
//     return Container(
//       margin: EdgeInsets.only(left: 30,bottom: 15),
//       alignment: Alignment.bottomLeft,
//       child: Text(
//         "Password",
//         textAlign: TextAlign.left,
//         style: TextStyle(color: Colors.white,fontSize: 17,
//           shadows: <Shadow>[
//             Shadow(
//               offset: Offset(0.0, 2.0),
//               blurRadius: 12,
//               color: Color.fromARGB(255, 0, 0, 0),
//             ),
//           ],),
//       ),
//     );
//   }

//   Widget passwordRegis(){
//     return Container(
//       //margin: EdgeInsets.symmetric(horizontal: 30, vertical: 0),
//         margin: const EdgeInsets.only(left: 30, right: 30 ,bottom: 20),
//       child: TextFormField(
//         obscureText: _isObscure,
//         //obscureText: true,
//         maxLines: 1,
//         decoration: InputDecoration(
//           filled: true,
//           fillColor:
//           const Color.fromRGBO(255, 255, 255, 0.6000000238418579),
//           suffixIcon: IconButton(
//             icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
//             onPressed: (){
//               setState((){
//                 _isObscure = !_isObscure;
//               });
//             },
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           labelText: 'Password',
//         ),
//         validator: (value) =>
//         value!.isEmpty ? 'Please enter your password' : null,
//         onSaved: (value) => _password = value!.trim(),
//       ),
//     );
//   }




//   Widget regisButton() {
//     return Container(
//       margin: EdgeInsets.only(left: 60,right: 60,bottom: 30,top: 20),
//       width: 200,
//       height: 50,
//       decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               Color.fromRGBO(41, 56, 220, 1.0),
//               Color.fromRGBO(118, 182, 255, 1.0),
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: const BorderRadius.all(
//             Radius.circular(25.0),
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.pink.withOpacity(0.2),
//               spreadRadius: 4,
//               blurRadius: 10,
//               offset: const Offset(0, 3),
//             )
//           ]),
//       child: OutlinedButton(
//         style: ButtonStyle(
//           shape: MaterialStateProperty.all(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
//           ),
//         ),
//         onPressed: validateAndSubmit,
//         child: const Text(
//           'Register',
//           textAlign: TextAlign.left,
//           style: TextStyle(
//             fontFamily: "Roboto Slab",
//             fontWeight: FontWeight.w600,
//             fontSize: 18,
//             letterSpacing: 0.0,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget loginFrame(){
//     return Container(
//         height: 615,margin: EdgeInsets.only(top: 150,left: 20,right: 20),
//         decoration: BoxDecoration(
//           borderRadius : BorderRadius.only(
//             topLeft: Radius.circular(16),
//             topRight: Radius.circular(16),
//             bottomLeft: Radius.circular(16),
//             bottomRight: Radius.circular(16),
//           ),
//           color : Color.fromRGBO(255, 255, 255, 0.3),
//         )
//     );
//   }
//   Widget showLogo() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
//       width: 150,
//       height: 190,
//       decoration: BoxDecoration(
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(154.5),
//           topRight: Radius.circular(154.5),
//           bottomLeft: Radius.circular(154.5),
//           bottomRight: Radius.circular(154.5),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.pink.withOpacity(0.2),
//             spreadRadius: 4,
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           )
//         ],
//       ),
//       child: Image.network('https://bursakerja.jatengprov.go.id/assets/default-logo.png',fit: BoxFit.fitWidth),
//     );
//   }

// }


