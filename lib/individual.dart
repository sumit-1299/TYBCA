import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Individual extends StatefulWidget {
  Individual({Key? key, required this.db, required this.data}) : super(key: key);

  Mongo.Db db;
  MapEntry<String, dynamic> data;
  @override
  State<Individual> createState() => _IndividualState();
}

class _IndividualState extends State<Individual> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.data.key}")
      ),
      body: RefreshIndicator(
        child: ListView(),
        onRefresh: () async{
          setState(() {});
        },
      )
    );
  }
}
