import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'Home.dart';
import 'Login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Firebase Initialization
  await Firebase.initializeApp();
  //MongoDB Initialization
  Mongo.Db _db = Mongo.Db("mongodb://accman:password@3.106.137.118:27017/khata?directConnection=true&appName=mongosh+1.8.0");

  await _db.open().then((value) {
    print("connection Successful");
    print("state: ${_db.state}, connected? ${_db.isConnected}, master: ${_db.masterConnection.connected}");
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




