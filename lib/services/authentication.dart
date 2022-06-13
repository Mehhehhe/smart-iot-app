import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class BaseAuth {
  Future<String?> signIn(String email, String password);
  Future<String?> register(String email, String password);
  Future<User?> getCurrentUser();
  Future<String?> getUserEmail();
  Future<void> signOut();
  Future<void> editDisplayName(String displayName);
  FirebaseAuth returnInstance();
  Future<String?> getDisplayName();
  // Google methods
  Future<String?> signInWithGoogle();
  Future<void> signOutFromGoogle();
}

class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  Future<User?> getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return user;
  }

  @override
  Future<String?> signIn(String email, String password) async {
    UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password);
    User? user = result.user;
    return user?.uid;
  }

  @override
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  Future<String?> register(String email, String password) async {
    late UserCredential result;
    try{
      result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    }on FirebaseAuthException catch(e){
      print(e);
    }
    User? user = result.user;
    return user?.uid;
  }

  @override
  Future<String?> getUserEmail() async {
    User? user = _firebaseAuth.currentUser;
    return user?.email;
  }

  @override
  Future<String?> signInWithGoogle() async {
    try{
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);

      User? user = await getCurrentUser();
      return user?.uid;
    } on FirebaseAuthException catch(e){
      print(e);
      throw e;
    }
  }

  @override
  Future<void> signOutFromGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> editDisplayName(String displayName) async{
    User? user = _firebaseAuth.currentUser;
    user?.updateDisplayName(displayName);
    await user?.reload();
  }

  @override
  FirebaseAuth returnInstance() {
    return _firebaseAuth;
  }

  @override
  Future<String?> getDisplayName() async {
    User? user = _firebaseAuth.currentUser;
    return user?.displayName;
  }
}