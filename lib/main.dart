import 'package:flutter/material.dart';
import 'package:register1/Screens/UI/Splash.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:mongo_dart/mongo_dart.dart' show Db,DbCollection;

class DBConnection {
  static late DBConnection _instance;
  final String _host = "3.106.137.118";
  final String _port = "27017";
  final String _dbName = "accman";
  late Db _db;

  static getInstance(){
    if(_instance == null) {
      _instance = DBConnection();
    }
    return _instance;
  }
  Future<Db> getConnection() async{
        _db = Db(_getConnectionString());
        await _db.open().then((value) {
          print("connection Successful");
          return value;
        }).catchError((error) {
          print("Error: ${error.toString()}");
        });
    return _db;
  }

  _getConnectionString(){
    return "mongodb://accman:password@3.106.137.118:27017/khata?directConnection=true&appName=mongosh+1.8.0";
  }
  closeConnection() {
    _db.close();
  }
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  DBConnection  abc = new DBConnection();
      abc.getConnection();
  await Firebase.initializeApp();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: Splash(),
    );
  }
}


