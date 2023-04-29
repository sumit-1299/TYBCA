import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:mongo_dart/mongo_dart.dart';

import 'Home.dart';
import 'Login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Firebase Initialization
  await Firebase.initializeApp();
  //MongoDB Initialization
  Db _db = Db("mongodb://accman:password@3.106.137.118:27017/khata?directConnection=true&appName=mongosh+1.8.0");
  await _db.open().then((value) {
    print("connection Successful");
    return value;
  }).catchError((error) {
    print("Error: ${error.toString()}");
  });

  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    debugShowCheckedModeBanner: false,
    home: FirebaseAuth.instance.currentUser!=null?Home(db: _db):Login(db: _db),
  ));
}




