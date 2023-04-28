import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:register1/Splash.dart';
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

  /*Map<String, dynamic> temp = await _db.collection('test').modernFind(selector: where.eq("_id", "1234"),projection: {"Nigam1.PNames": 1}).last.then((value) async{
    print("${value.entries.last.value['PNames'].length}");
    for(int i=0;i<value.entries.last.value['PNames'].length;i++){
      await _db.collection('test').modernFind(selector: where.eq("_id", "1234"),projection: {"Nigam1.Parties.${value.entries.last.value['PNames'][i]}": 1}).last.then((value){
        // print(value.entries.last);
        return value;
      });
    }
    return value;
    // await _db.collection('test').modernFind(selector: where.eq("_id", "1234"),projection: {"Nigam1.PNames": 1}).last
  });

  print(temp.entries.last);*/
  runApp(MaterialApp(
    theme: ThemeData(
      primarySwatch: Colors.purple,
    ),
    debugShowCheckedModeBanner: false,
    home: FirebaseAuth.instance.currentUser!=null?Home(db: _db):Login(),
  ));
}




