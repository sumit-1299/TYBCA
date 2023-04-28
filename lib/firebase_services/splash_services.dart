import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:register1/Home.dart';
import 'package:register1/Login.dart';
import 'package:register1/navigator.dart';

class SplashServices {
  void isLogin(BuildContext context) {
    // if (FirebaseAuth.instance.currentUser != null) {
    //   Timer(const Duration(seconds: 3),
    //           () =>
    //           Navigator.pushReplacement(
    //               context, MaterialPageRoute(builder: (context) => Home()))
    //   );
    // } else {
    //   Timer(const Duration(seconds: 3),
    //           () =>
    //           Navigator.pushReplacement(
    //               context, MaterialPageRoute(builder: (context) => Login()))
    //   );
    // }
  }
}