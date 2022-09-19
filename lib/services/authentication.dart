import 'dart:async';
import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:crypto/crypto.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:smart_iot_app/services/AuthExceptionHandler.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// abstract class BaseAuth {
//   Future<String?> signIn(String email, String password);
//   Future<String?> register(String username, String email, String password);
//   Future<User> getCurrentUser();
//   Future<String?> getUserEmail();
//   Future<void> signOut();
//   Future<AuthStatus> resetPassword({required String email});

//   Future<void> editDisplayName(String displayName);
//   Future<String?> getDisplayName();

//   // Google methods
//   Future<String> signInWithGoogle();
//   Future<void> signOutFromGoogle();
// }

// class Auth implements BaseAuth {
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//   final GoogleSignIn _googleSignIn = GoogleSignIn();

//   @override
//   Future<User> getCurrentUser() async {
//     User? user = _firebaseAuth.currentUser;
//     return user!;
//   }

//   @override
//   Future<String> signIn(String email, String password) async {
//     UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
//         email: email, password: password);
//     User? user = result.user;
//     return user!.uid;
//   }

//   @override
//   Future<void> signOut() {
//     return _firebaseAuth.signOut();
//   }

//   @override
//   Future<String?> register(
//       String username, String email, String password) async {
//     UserCredential result;
//     var _status;
//     try {
//       result = await _firebaseAuth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       result.user?.updateDisplayName(username);
//       await result.user?.reload();
//     } on FirebaseAuthException catch (e) {
//       _status = AuthExceptionHandler.handleAuthException(e);
//       return _status;
//     }
//     User? user = result.user;
//     return user?.uid;
//   }

//   @override
//   Future<String?> getUserEmail() async {
//     User? user = _firebaseAuth.currentUser;
//     return user?.email;
//   }

//   @override
//   Future<String> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleSignInAccount =
//           await _googleSignIn.signIn();
//       final GoogleSignInAuthentication googleSignInAuthentication =
//           await googleSignInAccount!.authentication;
//       final AuthCredential credential = GoogleAuthProvider.credential(
//         accessToken: googleSignInAuthentication.accessToken,
//         idToken: googleSignInAuthentication.idToken,
//       );
//       await _firebaseAuth.signInWithCredential(credential);

//       User user = await getCurrentUser();
//       return user.uid;
//     } on FirebaseAuthException catch (e) {
//       var _status = AuthExceptionHandler.handleAuthException(e);
//       return _status;
//     }
//   }

//   @override
//   Future<void> signOutFromGoogle() async {
//     await _googleSignIn.signOut();
//     await _firebaseAuth.signOut();
//   }

//   @override
//   Future<void> editDisplayName(String displayName) async {
//     User? user = _firebaseAuth.currentUser;
//     user?.updateDisplayName(displayName);
//     await user?.reload();
//   }

//   @override
//   Future<String?> getDisplayName() async {
//     User? user = _firebaseAuth.currentUser;
//     return user?.displayName;
//   }

//   @override
//   Future<AuthStatus> resetPassword({required String email}) async {
//     var _status;

//     await _firebaseAuth
//         .sendPasswordResetEmail(email: email)
//         .then((value) => _status = AuthStatus.successful)
//         .catchError(
//             (e) => _status = AuthExceptionHandler.handleAuthException(e));
//     return _status;
//   }
// }

class Auth {
  Future<bool> signedUpUser(
      String inputEmail, String username, String password) async {
    try {
      final userAttributes = <CognitoUserAttributeKey, String>{
        CognitoUserAttributeKey.email: inputEmail,
      };
      final result = await Amplify.Auth.signUp(
          username: username,
          password: password,
          options: CognitoSignUpOptions(userAttributes: userAttributes));
      return result.isSignUpComplete;
    } on AuthException catch (e) {
      print(e.message);
    }
    return false;
  }

  Future<bool> confirmUserSignedUp(String username) async {
    try {
      var userBytes = utf8.encode(username);
      String confirmationCode =
          sha256.convert(userBytes).toString().split('').take(5).join('');
      final result = await Amplify.Auth.confirmSignUp(
          username: username, confirmationCode: confirmationCode);
      return result.isSignUpComplete;
    } on AuthException catch (e) {
      print(e.message);
    }
    return false;
  }

  Future<bool> signInUser(String username, String password) async {
    try {
      final result =
          await Amplify.Auth.signIn(username: username, password: password);
      return result.isSignedIn;
    } on AuthException catch (e) {
      print(e.message);
    }
    return false;
  }
}
