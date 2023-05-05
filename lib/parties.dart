import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:register1/newparty.dart';


class Parties extends StatelessWidget {
  ///Parties to collect from and pay to
  Parties({Key? key, required this.db, required this.tabIndex}) : super(key: key);

  Mongo.Db db;
  int tabIndex;

  ///This method fetches all data related to parties.
  ///
  /// This method has 2 await calls:
  /// 1. Fetching the 'PNames' array in which the party names are stored.
  /// 2. Fetching the data of the items of each party.
  ///
  ///eg:
  ///
  ///"User": {
  ///     "Parties": {
  ///       "P1": {
  ///         "Items": {
  ///           "Item1": {...},
  ///           "Item2": {...},
  ///           ...
  ///         },
  ///       },
  ///       "P2": {
  ///         "Items": {
  ///           "Item1": {...},
  ///           "Item2": {...},
  ///           ...
  ///         },
  ///       },
  ///     }
  Future<Map<String, dynamic>> data() async{
    print("DB state: ${db.isConnected}");
    if(!db.isConnected || db.state == Mongo.State.closed || !db.masterConnection.connected){

      await db.close();
      await db.open().then((value) {
        print("connection Successful");
        print("state: ${db.state}, connected? ${db.isConnected}");
        return value;
      }).catchError((error) {
        print("Error: ${error.toString()}");
      });
    }

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

  void initState() async{
    if(db.state == Mongo.State.closed || !db.masterConnection.connected){
      print("DB state: ${db.state}");
      await db.close();
      await db.open().then((value) {
        print("connection Successful");
        print("state: ${db.state}, connected? ${db.isConnected}");
        return value;
      }).catchError((error) {
        print("Error: ${error.toString()}");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: tabIndex,
        length: 2,
        child: Scaffold(
        appBar: AppBar(
            title: const Text("Parties"),
          bottom: const TabBar(
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
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
            onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewParty(db: db))
            );
            },
        ),
        body: FutureBuilder(
          future: data(),
          builder: (context, AsyncSnapshot<Map<String,dynamic>> snapshot){
            if(snapshot.hasData){
              // print("snapshot length: ${snapshot.data?.entries.length}");
              //.where((item) => !item.value['pay'])
              // print("pay? ${snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).length}");
              // snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).forEach((element) {
              //   print("collect from: ${element.key}");
              // });

              // print("test: ${snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).elementAt(2)}");
              Map<String,dynamic> collect = Map();
              Map<String,dynamic> pay = Map();

              // MapEntry<String, dynamic> mapEntry = MapEntry("zek", "0");

              // print("Snapshot: ${snapshot.data}");
              // collect.addEntries(snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']).isNotEmpty) as Iterable<MapEntry<String, dynamic>>);
              snapshot.data?.entries.forEach((entry) {
                print("Entry: ${entry.key}");
                print("Collection Exists? ${entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty}");
                if(entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty) {
                  // print(entry);
                  // collect.addAll({entry.key: });
                  print("Collection Entry: ${entry.value['Items'].entries.where((item) => !item.value['pay']==true)}");
                  entry.value['Items'].entries.where((item) => !item.value['pay']==true).forEach((item) {
                    print("Item: ${item}");

                    if(collect.containsKey(entry.key)) {
                      print("existing: ${collect[entry.key]}");
                          collect.addAll({
                            entry.key: {
                              collect[entry.key],
                              {item.key: item.value}
                            }
                          });
                        }
                    else{
                      collect.addAll({
                        entry.key : {
                          item.key : item.value
                        }
                      });
                    }
                      });

                  // collect.addEntries(entry.value['Items'].entries.where((item) => !item.value['pay']==true));
                  // collect.addAll(entry.value['Items'].values.first);
                }

                if(entry.value['Items'].entries.where((item) => item.value['pay']==true).isNotEmpty) {
                  // print(entry);
                  // collect.addAll({entry.key: });
                  print("Collection Entry: ${entry.value['Items'].entries.where((item) => item.value['pay']==true)}");
                  entry.value['Items'].entries.where((item) => item.value['pay']==true).forEach((item) {
                    print("Item: ${item}");

                    if(pay.containsKey(entry.key)) {
                      print("existing: ${pay[entry.key]}");
                      pay.addAll({
                        entry.key: {
                          pay[entry.key],
                          {item.key: item.value}
                        }
                      });
                    }
                    else{
                      pay.addAll({
                        entry.key : {
                          item.key : item.value
                        }
                      });
                    }
                  });

                  // collect.addEntries(entry.value['Items'].entries.where((item) => !item.value['pay']==true));
                  // collect.addAll(entry.value['Items'].values.first);
                }


                // collect.addAll({entry.key: entry.value['Items'].entries.where((item) => !item.value['pay']==true)});
              });
              // pay.addEntries(snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => item.value['pay']==true).isNotEmpty) as Iterable<MapEntry<String, dynamic>>);

              print("Collect: $collect\n\nPay: $pay");
              return TabBarView(
                children: [
                  ///To Collect
                  ListView.builder(
                      itemCount: collect.length,
                      itemBuilder: (context, index) {
                        int total = 0;
                        /*for(int i=0;i<snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).elementAt(index).value['Items'].keys.length;i++){
                          total += snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).elementAt(index).value['Items'].entries.elementAt(i).value['Amount'] as int;
                        }*/

                        collect.entries.elementAt(index).value['Items'].entries.forEach((item){
                          print("collect status: ${item.key}");
                          if(!item.value['pay']){
                            total += item.value['Amount'] as int;
                          }

                        });
                        print("total: $total");
                        return ListTile(
                          title: Text(collect.keys.elementAt(index)),
                          onTap: (){
                            // print("${collect}");
                            // print("Items details: ${collect.values.first['Items'].values.elementAt(0).length}");
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text(collect.keys.elementAt(index)),
                                  ),
                                  body: ListView.builder(
                                      itemCount: collect.values.elementAt(index)['Items'].length,
                                      itemBuilder: (context, item) {
                                        // print("Items details: ${collect.values.first['Items'].length}");
                                        // print("properties: ${collect.values.elementAt(index)['Items'].values.elementAt(item).length}");
                                        return ListTile(
                                          title: Text(collect.values.elementAt(index)['Items'].keys.elementAt(item)),
                                          subtitle: ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: collect.values.elementAt(index)['Items'].values.elementAt(item).length,
                                              itemBuilder: (context, property) {
                                                // print("${snapshot.data?.entries.elementAt(index).value['Items'].entries.where((item) => !item.value['pay']==true).elementAt(item).value.values.length}");
                                                // print("${snapshot.data?.entries}");
                                                // print("item: ${snapshot.data?.entries.where((entry) => !entry.value['Items'].values.elementAt(item)['pay']).elementAt(index).value['Items'].keys}");
                                                print(collect.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property));
                                                return collect.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property)!="pay"?ListTile(
                                                  title: Text("${collect.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property)}:"),
                                                  trailing: Text("${collect.values.elementAt(index)['Items'].values.elementAt(item).values.elementAt(property)}"),
                                                ): const SizedBox();
                                              }
                                          ),
                                        );
                                      }
                                  ),
                                ))
                            );
                          },
                          trailing: Text("Total: $total"),
                        );
                      }

                  ),

                  ///To Pay
                  ListView.builder(
                      itemCount: pay.length,
                      itemBuilder: (context, index) {
                        int total = 0;
                        /*for(int i=0;i<snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).elementAt(index).value['Items'].keys.length;i++){
                          total += snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty).elementAt(index).value['Items'].entries.elementAt(i).value['Amount'] as int;
                        }*/
                        pay.entries.elementAt(index).value['Items'].entries.forEach((item){
                          print("collect status: ${item.key}");
                          if(!item.value['pay']){
                            total += item.value['Amount'] as int;
                          }
                        });
                        print("total: $total");
                        return ListTile(
                          title: Text(pay.keys.elementAt(index)),
                          onTap: (){
                            // print("${collect}");
                            // print("Items details: ${collect.values.first['Items'].values.elementAt(0).length}");
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    title: Text(pay.keys.elementAt(index)),
                                  ),
                                  body: ListView.builder(
                                      itemCount: pay.values.elementAt(index)['Items'].length,
                                      itemBuilder: (context, item) {
                                        // print("Items details: ${collect.values.first['Items'].length}");
                                        // print("properties: ${pay.values.elementAt(index)['Items'].values.elementAt(item).length}");
                                        return ListTile(
                                          title: Text(pay.values.elementAt(index)['Items'].keys.elementAt(item)),
                                          subtitle: ListView.builder(
                                              physics: const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: pay.values.elementAt(index)['Items'].values.elementAt(item).length,
                                              itemBuilder: (context, property) {
                                                // print("${snapshot.data?.entries.elementAt(index).value['Items'].entries.where((item) => !item.value['pay']==true).elementAt(item).value.values.length}");
                                                // print("${snapshot.data?.entries}");
                                                // print("item: ${snapshot.data?.entries.where((entry) => !entry.value['Items'].values.elementAt(item)['pay']).elementAt(index).value['Items'].keys}");
                                                print(pay.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property));
                                                return pay.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property)!="pay"?ListTile(
                                                  title: Text("${pay.values.elementAt(index)['Items'].values.elementAt(item).keys.elementAt(property)}:"),
                                                  trailing: Text("${pay.values.elementAt(index)['Items'].values.elementAt(item).values.elementAt(property)}"),
                                                ): const SizedBox();
                                              }
                                          ),
                                        );
                                      }
                                  ),
                                ))
                            );
                          },
                          trailing: Text("Total: $total"),
                        );
                      }

                  ),
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
