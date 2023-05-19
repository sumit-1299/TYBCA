import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'individual.dart';

class Transactions extends StatefulWidget {
  Transactions({Key? key, required this.db, this.tabIndex=0}) : super(key: key);

  Mongo.Db db;
  int tabIndex;

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final nameController = TextEditingController();
  final amountController = TextEditingController();

  Future<dynamic> get_connection() async{
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
  }

  Future<Map<String, dynamic>> data() async{
    print("DB state: ${widget.db.isConnected}");
    await get_connection();
    return await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.People": 1}).last.then((value){
      return Map<String, dynamic>.from(value.values.last['People']);
    });
    // return data;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: data(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
          if(snapshot.hasData){
            Map<String,dynamic> data = Map();
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Individuals"),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add,color: Color(0xff141415),),
                  onPressed: (){
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: Color(0xff27292a),
                          title: Text("Add Transaction",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300)),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.text,
                                controller: nameController,
                                decoration: InputDecoration(
                                  hintText: 'Name',
                                  hintStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
                                  // prefixIcon: const Icon(Icons.person, color: Colors.white,),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      )
                                  ),
                                  border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                      )
                                  ),
                                  enabledBorder:UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      )
                                  ),
                                ),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'Enter Name';
                                  }
                                  else {
                                    return null;
                                  }
                                },
                              ),
                              TextFormField(
                                keyboardType: TextInputType.number,
                                controller: amountController,
                                decoration: InputDecoration(
                                  hintText: 'Amount',
                                  hintStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
                                  // prefixIcon: const Icon(Icons.person, color: Colors.white,),
                                  focusedBorder: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.white
                                      )
                                  ),
                                  border: const UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                      )
                                  ),
                                  enabledBorder:UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      )
                                  ),
                                ),
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'Enter Amount';
                                  }
                                  else {
                                    return null;
                                  }
                                },
                              )
                            ],
                          ),
                          actionsAlignment: MainAxisAlignment.spaceBetween,
                          actions: [
                            TextButton(
                              child: Text("Collect",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w300),),
                              onPressed: () async{
                                print("payments: ${snapshot.data}");
                                snapshot.data?.addEntries([MapEntry("${DateTime.now()}", {
                                  nameController.text : int.parse(amountController.text),
                                  "pay" : false
                                })]);
                                await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.People', snapshot.data)).then((value){
                                  Navigator.pop(context);
                                  setState(() {});
                                }).catchError((error){
                                  print("error: $error");
                                });
                                nameController.clear();
                                amountController.clear();
                              },
                            ),
                            TextButton(
                              child: Text("Pay",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w300),),
                              onPressed: () async{
                                print("payments: ${snapshot.data}");
                                snapshot.data?.addEntries([MapEntry("${DateTime.now()}", {
                                  nameController.text : int.parse(amountController.text),
                                  "pay" : true
                                })]);
                                await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.People', snapshot.data)).then((value){
                                  Navigator.pop(context);
                                  setState(() {});
                                }).catchError((error){
                                  print("error: $error");
                                });
                                nameController.clear();
                                amountController.clear();
                                // db.collection('test').insertOne({
                                //
                                // });
                              },
                            )
                          ],
                        )
                    );
                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => NewParty(db: db))
                    // );
                  },
                ),
                body: RefreshIndicator(
                  color: Color(0xff141415),
                  onRefresh: () async{ setState((){}); },
                  child: ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {

                        int total = 0;

                        if(data.keys.contains("${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}")){
                          print("qwerty - ${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}: ${data[snapshot.data?.values.toList().reversed.elementAt(index).keys.first]}");
                          data.addAll({
                            snapshot.data?.values.toList().reversed.elementAt(index).keys.first : Map<String, dynamic>.fromEntries([data[snapshot.data!.values.toList().reversed.elementAt(index).keys.first].entries.first,MapEntry(
                                "${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}",
                                {
                                  snapshot.data!.keys.toList().reversed.elementAt(index): {
                                    "Amount": snapshot.data?.values
                                        .toList()
                                        .reversed
                                        .elementAt(index)
                                        .values
                                        .first,
                                    "pay": snapshot.data?.values
                                        .toList()
                                        .reversed
                                        .elementAt(index)
                                        .values
                                        .last
                                  }
                                }
                                )])
                          }
                          );
                        }
                        else {
                          /*data.addAll(
                            Map<String,dynamic>.fromEntries([
                              MapEntry(
                                  "${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}",
                                  {
                                  snapshot.data?.keys.toList().reversed.elementAt(index): {
                                    "Amount": snapshot.data?.values
                                      .toList()
                                      .reversed
                                      .elementAt(index)
                                      .values
                                      .first,
                                  "pay": snapshot.data?.values
                                      .toList()
                                      .reversed
                                      .elementAt(index)
                                      .values
                                      .last
                                  }
                                  }
                                  )
                            ])
                          );*/
                          data.addAll({
                            "${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}" : {
                              snapshot.data?.keys.toList().reversed.elementAt(index): {
                                "Amount": snapshot.data?.values
                                    .toList()
                                    .reversed
                                    .elementAt(index)
                                    .values
                                    .first,
                                "pay": snapshot.data?.values
                                    .toList()
                                    .reversed
                                    .elementAt(index)
                                    .values
                                    .last
                              }
                            }
                          });
                          print("Data: $data");
                          /*data.addEntries([
                            MapEntry(
                                "${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}",
                                {
                                  "Amount": snapshot.data?.values
                                      .toList()
                                      .reversed
                                      .elementAt(index)
                                      .values
                                      .first,
                                  "pay": snapshot.data?.values
                                      .toList()
                                      .reversed
                                      .elementAt(index)
                                      .values
                                      .last
                                })
                          ]);*/
                        }
                        print("data: ${data.entries}");
                        if(snapshot.data?.values.toList().reversed.elementAt(index).values.last){
                          total -= snapshot.data?.values.toList().reversed.elementAt(index).values.first as int;
                        }
                        else{
                          total += snapshot.data?.values.toList().reversed.elementAt(index).values.first as int;
                        }
                        // snapshot.data?.values.toList().reversed.elementAt(index).values.forEach((value){
                        //   print("amount: ${value}");
                        //   // if(value['pay']) {
                        //   //   total -= value['Amount'] as int;
                        //   // }
                        //   // else{
                        //   //   total += value['Amount'] as int;
                        //   // }
                        // });
                        return ListTile(
                            title: Text("${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}"),
                            subtitle: Text("${DateTime.parse(snapshot.data?.keys.toList().reversed.elementAt(index) as String)}"),
                            trailing: snapshot.data?.values.toList().reversed.elementAt(index).values.last?Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("₹${total.abs()}"),
                                Icon(Icons.arrow_upward, color: Colors.red,)
                              ],
                            ):Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("₹${snapshot.data?.values.toList().reversed.elementAt(index).values.first}"),
                                Icon(Icons.arrow_downward, color: Colors.green,)
                              ],
                            )
                        );
                      }
                  ),
                )
            );
          }
          else if(snapshot.hasError){
            get_connection();
            setState(() {});
            return Center();
          }
          else{
            return Center();
          }
        }
    );
  }
}
