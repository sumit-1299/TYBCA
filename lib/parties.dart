import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Parties extends StatelessWidget {
  Parties({Key? key, required this.db, required this.tabIndex}) : super(key: key);

  Mongo.Db db;
  int tabIndex;

  Future<Map<String, dynamic>> data() async{
    Map<String, dynamic> data = Map();
    await db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"Nigam1.PNames": 1}).last.then((value) async{
      // print("${value.entries.last.value['PNames'].length}");
      for(int i=0;i
          <value.entries.last.value['PNames'].length;i++){
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
    return DefaultTabController(
      initialIndex: tabIndex,
        length: 2,
        child: Scaffold(
        appBar: AppBar(
            title: Text("Parties"),
          bottom: TabBar(
            tabs: [
              Padding(
                  padding: EdgeInsets.all(5),
                child: Text("To Collect",style: TextStyle(fontSize: 20),),
              ),
              Padding(
                padding: EdgeInsets.all(5),
                child: Text("To Pay",style: TextStyle(fontSize: 20),),
              )
            ],
          ),
        ),
        body: FutureBuilder(
          future: data(),
          builder: (context, AsyncSnapshot<Map<String,dynamic>> snapshot){
            if(snapshot.hasData){
              print("snapshot length: ${snapshot.data?.entries.length}");
              return TabBarView(
                children: [
                  ListView.builder(
                      itemCount: snapshot.data?.entries.where((entry) => !entry.value['pay']).length,
                      itemBuilder: (context, index) {
                        int total = 0;
                        for(int i=0;i<snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].keys.length;i++){
                          total += snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].entries.elementAt(i).value['Amount'] as int;
                        }
                        print("total: $total");
                        return ListTile(
                          title: Text("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).key}"),
                          onTap: (){
                            showDialog(context: context, builder: (context) => AlertDialog(
                                title: Text("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).key}"),
                                content: Container(
                                  height: MediaQuery.of(context).size.height*0.8,
                                  width: MediaQuery.of(context).size.width*0.9,
                                  child: ListView.builder(
                                      itemCount: snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].length,
                                      itemBuilder: (context, item) => ListTile(
                                          title: Text("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].keys.elementAt(item)}"),
                                        subtitle: ListView.builder(
                                          physics: NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].values.elementAt(item).length,
                                            itemBuilder: (context, property) => ListTile(
                                              title: Text("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].values.elementAt(item).keys.elementAt(property)}"),
                                              trailing: Text("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).value['Items'].values.elementAt(item).values.elementAt(property)}"),
                                            )
                                        ),
                                      )
                                  ),
                                )
                            ));
                          },
                          trailing: Text("Total: $total"),
                        );
                      }

                  ),
                  ListView.builder(
                      itemCount: snapshot.data?.entries.where((entry) => entry.value['pay']).length,
                      itemBuilder: (context, index) {

                        // print("${snapshot.data?.entries.where((entry) => !entry.value['pay']).elementAt(index).key}");
                        // print("snapshot: ${snapshot.data?.keys.elementAt(index)}");
                        print("collect snapshot length: ${snapshot.data?.entries.where((entry) => entry.value['pay']).length}");
                        return ListTile(
                            title: Text("${snapshot.data?.entries.where((entry) => entry.value['pay']).elementAt(index).key}")
                        );
                      }
                  )
                ],
              );
            }
            else if(snapshot.hasError){
              return Center(
                  child: Text(snapshot.error.toString())
              );
            }
            else{
              return Center(
                  child: CircularProgressIndicator()
              );
            }
          },
        )
    )
    );
  }
}
