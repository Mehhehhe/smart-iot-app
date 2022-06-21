import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

abstract class ImageGetter {
  Future<String> getImageFromStorage(String userID);
  Future<void> uploadPic(BuildContext context,File? image,String username);
}

class ImageStorageManager implements ImageGetter {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  late var destinationOfProfileImage = 'Profile/';

  @override
  Future<String> getImageFromStorage(String userID) async {
    if (kDebugMode) {
      print("Username : $userID");
    }
    var bytes = utf8.encode(userID);
    var digest = sha256.convert(bytes);

    destinationOfProfileImage += digest.toString();
    if (kDebugMode) {
      print(destinationOfProfileImage);
    }
    try{
      final ref = _firebaseStorage.ref(destinationOfProfileImage).child("UserProfile$digest");
      var url = await ref.getDownloadURL();
      if (kDebugMode) {
        print(url);
      }
      return url;
    } catch (e) {
      throw "Image not found!";
    }

  }

  @override
  Future<void> uploadPic(BuildContext context,File? image ,String username) async {
    var bytes = utf8.encode(username);
    var digest = sha256.convert(bytes);
    if (kDebugMode) {
      print(digest);
    }

    if (image == null) throw Exception("Image not found.");
    destinationOfProfileImage += digest.toString();

    try{
      final ref = _firebaseStorage.ref(destinationOfProfileImage).child("UserProfile$digest");
      await ref.putFile(image);
    } catch (e) {
      throw "Error Occurred: $e";
    }

  }


}