// import 'package:firebase_auth/firebase_auth.dart';

// enum AuthStatus{
//   successful,
//   wrongPassword,
//   emailAlreadyExists,
//   invalidEmail,
//   weakPassword,
//   unknown
// }

// class AuthExceptionHandler{
//   static handleAuthException(FirebaseAuthException e){
//     AuthStatus status;
//     switch(e.code) {
//       case "invalid-email":
//         status = AuthStatus.invalidEmail;
//         break;
//       case "wrong-password":
//         status = AuthStatus.wrongPassword;
//         break;
//       case "email-already-in-use":
//         status = AuthStatus.emailAlreadyExists;
//         break;
//       case "weak-password":
//         status = AuthStatus.weakPassword;
//         break;
//       default:
//         status = AuthStatus.unknown;
//     }
//     return status;
//   }
//   static String generateErrorMsg(error){
//     String errorMsg;
//     switch (error){
//       case AuthStatus.invalidEmail:
//         errorMsg = "Email does not exists or incorrect format";
//         break;
//       case AuthStatus.weakPassword:
//         errorMsg = "Your password should be at least 8 characters";
//         break;
//       case AuthStatus.emailAlreadyExists:
//         errorMsg = "Your email is already in use";
//         break;
//       case AuthStatus.wrongPassword:
//         errorMsg = "Incorrect email or password";
//         break;
//       default:
//         errorMsg = "An error occured. Please try again later.";
//     }
//     return errorMsg;
//   }
// }