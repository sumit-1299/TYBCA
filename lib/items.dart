import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Items extends StatelessWidget {
  Items({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;

  Future<Map<String, dynamic>> get_data() async{
    Map<String, dynamic> data = Map();
    await db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"Nigam1.PNames": 1}).last.then((value) async{
      // print("${value.entries.last.value['PNames'].length}");
      for(int i=0;i <value.entries.last.value['PNames'].length;i++){
        await db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"Nigam1.Parties.${value.entries.last.value['PNames'][i]}": 1}).last.then((value){
          // print("Loop Index: $i");
          // print("values: ${value.entries.last.value['Parties']}");
          data.addAll(value.entries.last.value['Parties']);
          // print("data: $data");
        }).catchError((error){
          print(error);
        });
      }
      // await _db.collection('test').modernFind(selector: where.eq("_id", "1234"),projection: {"Nigam1.PNames": 1}).last
    });

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Items")
      ),
      body: FutureBuilder(
        future: get_data(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if(snapshot.hasData){
            return Column(
              children: [
                ListTile(
                  title: Text("New Item"),
                  leading: Icon(Icons.add, color: Colors.purple),
                )
              ],
            );
          }
          else if(snapshot.hasError){
            return Center(
              child: Text("${snapshot.error}")
            );
          }
          else{
            return Center(
              child: CircularProgressIndicator()
            );
          }
        },
      )
    );
  }
}