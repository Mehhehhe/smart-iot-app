import 'dart:async';
import 'dart:convert';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:smart_iot_app/secrets/secrets.dart';
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

// Draft google login
  // Future loginWithGoogle() async {
  //   GoogleSignIn _googleSignIn = GoogleSignIn();
  // }
  Future signInWithGoogle(String code) async {
    var url = Secret().getAuthUrlWithAuthCode(code);
    var tokenBody = Secret().getTokenBody(code);
    print("Signed in to $url , $url");
    final response = await http.post(
      url,
      body: {},
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );
    print("[AuthGoogleResponse] $response");
    if (response.statusCode != 200) {
      throw Exception("Bad status code: " +
          response.statusCode.toString() +
          ", body: " +
          response.body);
    }
    final token = json.decode(response.body);
    final idToken = CognitoIdToken(token['id_token']);
    final accessToken = CognitoAccessToken(token['access_token']);
    final refreshToken = CognitoRefreshToken(token['refresh_token']);
    final session =
        CognitoUserSession(idToken, accessToken, refreshToken: refreshToken);
    final user = CognitoUser(
      null,
      Secret().getCognitoUserPool(),
      signInUserSession: session,
    );

    final attributes = await user.getUserAttributes();
    for (CognitoUserAttribute attribute in attributes!) {
      if (attribute.getName() == "email") {
        user.username = attribute.getValue();
        break;
      }
    }

    return user;
  }

  Future signOut() async {}
}
