import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String?> signIn(String email, String password);
  Future<String?> register(String email, String password);
  Future<User?> getCurrentUser();
  Future<String?> getUserEmail();
  Future<void> signOut();
}

class Auth implements BaseAuth{
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

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
}