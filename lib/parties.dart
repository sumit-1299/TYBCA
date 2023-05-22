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
    if(!widget.db.isConnected || widget.db.state == Mongo.State.closed || !widget.db.masterConnection.connected){

      await widget.db.close();
      await widget.db.open();
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
                        padding: const EdgeInsets.all(5),
                        child: Text("To Collect",style: GoogleFonts.roboto(
                            color: const Color(0xffffffff),
                            fontWeight: FontWeight.w300,
                            fontSize: 20
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5),
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
                      Map<String,dynamic> collect = {};
                      Map<String,dynamic> pay = {};
                      for (var entry in snapshot.data!.entries) {
                        if(entry.value['Items'].entries.where((item) => !item.value['pay']==true).isNotEmpty) {
                          entry.value['Items'].entries.where((item) => !item.value['pay']==true).forEach((item) {
                            if(collect.containsKey(entry.key)) {
                              collect.addAll({
                                entry.key: Map<String, dynamic>.fromEntries([collect[entry.key].entries.first,MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                            else{
                              collect.addAll({
                                entry.key : Map<String, dynamic>.fromEntries([MapEntry<String, dynamic>(item.key, item.value)])
                              });
                            }
                          });
                        }

                        if(entry.value['Items'].entries.where((item) => item.value['pay']==true).isNotEmpty) {
                          entry.value['Items'].entries.where((item) => item.value['pay']==true).forEach((item) {
                            if(pay.containsKey(entry.key)) {
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
                        }
                      }

                      return TabBarView(
                        children: [
                          ///To Collect
                          ListView.builder(
                              itemCount: collect.length,
                              itemBuilder: (context, index) {
                                int total = 0;
                                collect.entries.elementAt(index).value.values.forEach((item){
                                  total += item['Amount'] as int;
                                });

                                return ListTile(
                                  title: Text(collect.keys.elementAt(index)),
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(collect.keys.elementAt(index)),
                                          ),
                                          body: ListView.builder(
                                              itemCount: collect.values.elementAt(index).length,
                                              itemBuilder: (context, item) {
                                                return ListTile(
                                                  title: Text(collect.values.elementAt(index).keys.elementAt(item)),
                                                  subtitle: ListView.builder(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: collect.values.elementAt(index).values.elementAt(item).length,
                                                      itemBuilder: (context, property) {
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
                                      Text("₹$total",style: const TextStyle(color: Colors.green),),
                                      const Icon(Icons.arrow_downward, color: Colors.green,)
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
                                pay.entries.elementAt(index).value.values.forEach((item){
                                  total += item['Amount'] as int;
                                });
                                return ListTile(
                                  title: Text(pay.keys.elementAt(index)),
                                  onTap: (){
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text(pay.keys.elementAt(index)),
                                          ),
                                          body: ListView.builder(
                                              itemCount: pay.values.elementAt(index).length,
                                              itemBuilder: (context, item) {
                                                return ListTile(
                                                  title: Text(pay.values.elementAt(index).keys.elementAt(item)),
                                                  subtitle: ListView.builder(
                                                      physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: pay.values.elementAt(index).values.elementAt(item).length,
                                                      itemBuilder: (context, property) {
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
                                      Text("₹$total",style: const TextStyle(color: Colors.red),),
                                      const Icon(Icons.arrow_upward, color: Colors.red,)
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
                      return const Center(
                          child: CircularProgressIndicator()
                      );
                    }
                  },
                )
            )
        );
  }
}