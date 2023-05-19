import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Individual extends StatefulWidget {
  Individual({Key? key, required this.db, required this.data, required this.index}) : super(key: key);

  Mongo.Db db;
  Map<String, dynamic> data;
  int index;
  @override
  State<Individual> createState() => _IndividualState();
}

class _IndividualState extends State<Individual> {
  @override
  Widget build(BuildContext context) {
    // print(widget.data);
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.data.keys.elementAt(widget.index))
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
