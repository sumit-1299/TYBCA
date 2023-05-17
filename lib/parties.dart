import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:register1/newparty.dart';

class Parties extends StatefulWidget {
  Parties({Key? key, required this.db, this.tabIndex=0}) : super(key: key);

  Mongo.Db db;
  int tabIndex;

  @override
  State<Parties> createState() => _PartiesState();
}

class _PartiesState extends State<Parties> {
  Future<Map<String, dynamic>> data() async{
    print("DB state: ${widget.db.isConnected}");
    if(!widget.db.isConnected || widget.db.state == Mongo.State.closed || !widget.db.masterConnection.connected){

      await widget.db.close();
      await widget.db.open().then((value) {
        print("connection Successful");
        print("state: ${widget.db.state}, connected? ${widget.db.isConnected}");
        return value;
      }).catchError((error) {
        print("Error: ${error.toString()}");
      });
    }
    return await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.Parties": 1}).last.then((value){
      return Map<String, dynamic>.from(value.values.last['Parties']);
    });
    // return data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
            initialIndex: widget.tabIndex,
            length: 2,
            child: Scaffold(
                appBar: AppBar(
                  title: const Text("Parties"),
                  bottom: TabBar(
                    indicatorColor: Colors.white,
                    tabs: [
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("To Collect",style: GoogleFonts.roboto(
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w300,
                            fontSize: 20
                        )),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                        child: Text("To Pay",style: GoogleFonts.roboto(
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w300,
                            fontSize: 20
                        )),
                      )
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add,color: Color(0xff141415),),
                  onPressed: (){
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NewParty(db: widget.db))
                    );
                  },
                ),
                body: FutureBuilder(
                  future: data(),
                  builder: (context, AsyncSnapshot<Map<String,dynamic>> snapshot){
                    if(snapshot.hasData){
                      Map<String,dynamic> collect = Map();
                      Map<String,dynamic> pay = Map();

                      // MapEntry<String, dynamic> mapEntry = MapEntry("zek", "0");

                      // print("Snapshot: ${snapshot.data}");
                      // collect.addEntries(snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => !item.value['pay']).isNotEmpty) as Iterable<MapEntry<String, dynamic>>);
                      snapshot.data?.entries.forEach((entry) {
                        // print("Entry: ${entry.key}");
                        // print("Collection Exists? ${entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty}");
                        if(entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty) {
                          // print(entry);
                          // collect.addAll({entry.key: });
                          // print("Collection Entry: ${entry.value['Items'].entries.where((item) => !item.value['pay']==true)}");
                          entry.value['Items'].entries.where((item) => !item.value['pay']==true).forEach((item) {
                            // print("Item: ${item}");

                            if(collect.containsKey(entry.key)) {
                              print("existing: ${collect[entry.key].entries}");
                              // collect[entry.key].addAll();
                              collect.addAll({
                                // entry.key: MapEntry<String, dynamic>(
                                //   collect[entry.key].key, MapEntry<String, dynamic>(co)
                                // ),
                                // entry.key: {
                                //   collect[entry.key] as MapEntry<String, dynamic>,
                                //   MapEntry<String, dynamic>(item.key, item.value)
                                // }
                                entry.key: Map<String, dynamic>.fromEntries([collect[entry.key].entries.first,MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                            else{
                              collect.addAll({
                                entry.key : Map<String, dynamic>.fromEntries([MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                          });

                          // collect.addEntries(entry.value['Items'].entries.where((item) => !item.value['pay']==true));
                          // collect.addAll(entry.value['Items'].values.first);
                        }

                        if(entry.value['Items'].entries.where((item) => item.value['pay']==true).isNotEmpty) {
                          // print(entry);
                          // collect.addAll({entry.key: });
                          // print("Collection Entry: ${entry.value['Items'].entries.where((item) => item.value['pay']==true)}");
                          entry.value['Items'].entries.where((item) => item.value['pay']==true).forEach((item) {
                            // print("Item: ${item}");

                            if(pay.containsKey(entry.key)) {
                              // print("existing: ${pay[entry.key]}");
                              pay.addAll({
                                entry.key: Map<String, dynamic>.fromEntries([pay[entry.key].entries.first,MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                            else{
                              pay.addAll({
                                entry.key : Map<String, dynamic>.fromEntries([MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                          });

                          // collect.addEntries(entry.value['Items'].entries.where((item) => !item.value['pay']==true));
                          // collect.addAll(entry.value['Items'].values.first);
                        }


                        // collect.addAll({entry.key: entry.value['Items'].entries.where((item) => !item.value['pay']==true)});
                      });
                      // pay.addEntries(snapshot.data?.entries.where((entry) => entry.value['Items'].entries.where((item) => item.value['pay']==true).isNotEmpty) as Iterable<MapEntry<String, dynamic>>);

                      print("Collect: ${collect}\n\nPay: $pay");
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

                                /*collect.entries.elementAt(index).value['Items'].entries.forEach((item){
                          print("collect status: ${item.key}");
                          if(!item.value['pay']){
                            total += item.value['Amount'] as int;
                          }

                        });*/


                                // print("Amount: ${collect.entries.elementAt(index).value.values}");
                                collect.entries.elementAt(index).value.values.forEach((item){
                                  total += item['Amount'] as int;
                                });
                                print("total: $total");
                                return ListTile(
                                  title: Text(collect.keys.elementAt(index)),
                                  onTap: (){
                                    // print("${collect}");
                                    // print("Items details: ${collect.values.first['Items'].values.elementAt(0).length}");
                                    print("Item details: ${collect.values.elementAt(index)}");
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(collect.keys.elementAt(index)),
                                          ),
                                          body: ListView.builder(
                                              itemCount: collect.values.elementAt(index).length,
                                              itemBuilder: (context, item) {
                                                // print("Items details: ${collect.values.first['Items'].length}");
                                                // print("properties: ${collect.values.elementAt(index)['Items'].values.elementAt(item).length}");
                                                return ListTile(
                                                  title: Text(collect.values.elementAt(index).keys.elementAt(item)),
                                                  subtitle: ListView.builder(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: collect.values.elementAt(index).values.elementAt(item).length,
                                                      itemBuilder: (context, property) {
                                                        // print("${snapshot.data?.entries.elementAt(index).value['Items'].entries.where((item) => !item.value['pay']==true).elementAt(item).value.values.length}");
                                                        // print("${snapshot.data?.entries}");
                                                        // print("item: ${snapshot.data?.entries.where((entry) => !entry.value['Items'].values.elementAt(item)['pay']).elementAt(index).value['Items'].keys}");
                                                        print(collect.values.elementAt(index).values.elementAt(item).keys.elementAt(property));
                                                        return collect.values.elementAt(index).values.elementAt(item).keys.elementAt(property)!="pay"?ListTile(
                                                          title: Text("${collect.values.elementAt(index).values.elementAt(item).keys.elementAt(property)}:"),
                                                          trailing: Text("${collect.values.elementAt(index).values.elementAt(item).values.elementAt(property)}"),
                                                        ): const SizedBox();
                                                      }
                                                  ),
                                                );
                                              }
                                          ),
                                        )
                                        )
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("₹$total",style: TextStyle(color: Colors.green),),
                                      Icon(Icons.arrow_downward, color: Colors.green,)
                                    ],
                                  ),
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
                                /*pay.entries.elementAt(index).value['Items'].entries.forEach((item){
                          print("collect status: ${item.key}");
                          if(!item.value['pay']){
                            total += item.value['Amount'] as int;
                          }
                        });*/
                                pay.entries.elementAt(index).value.values.forEach((item){
                                  total += item['Amount'] as int;
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
                                              itemCount: pay.values.elementAt(index).length,
                                              itemBuilder: (context, item) {
                                                // print("Items details: ${collect.values.first['Items'].length}");
                                                // print("properties: ${pay.values.elementAt(index)['Items'].values.elementAt(item).length}");
                                                return ListTile(
                                                  title: Text(pay.values.elementAt(index).keys.elementAt(item)),
                                                  subtitle: ListView.builder(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: pay.values.elementAt(index).values.elementAt(item).length,
                                                      itemBuilder: (context, property) {
                                                        // print("${snapshot.data?.entries.elementAt(index).value['Items'].entries.where((item) => !item.value['pay']==true).elementAt(item).value.values.length}");
                                                        // print("${snapshot.data?.entries}");
                                                        // print("item: ${snapshot.data?.entries.where((entry) => !entry.value['Items'].values.elementAt(item)['pay']).elementAt(index).value['Items'].keys}");
                                                        print(pay.values.elementAt(index).values.elementAt(item).keys.elementAt(property));
                                                        return pay.values.elementAt(index).values.elementAt(item).keys.elementAt(property)!="pay"?ListTile(
                                                          title: Text("${pay.values.elementAt(index).values.elementAt(item).keys.elementAt(property)}:"),
                                                          trailing: Text("${pay.values.elementAt(index).values.elementAt(item).values.elementAt(property)}"),
                                                        ): const SizedBox();
                                                      }
                                                  ),
                                                );
                                              }
                                          ),
                                        ))
                                    );
                                  },
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text("₹$total",style: TextStyle(color: Colors.red),),
                                      Icon(Icons.arrow_upward, color: Colors.red,)
                                    ],
                                  ),
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