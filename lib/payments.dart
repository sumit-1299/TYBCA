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
                                if(snapshot.data!.keys.contains(nameController.text)){
                                  print("existing: ${snapshot.data?[nameController.text].runtimeType}");
                                  snapshot.data?[nameController.text].addEntries([MapEntry("${DateTime.now()}",{
                                    "Amount": int.parse(
                                        amountController.text),
                                    "pay": false
                                  })]);
                                  print("After adding payments: ${snapshot.data}");
                                }
                                else {
                                  snapshot.data?.addEntries([
                                    MapEntry(nameController.text, {
                                      "${DateTime.now()}": {
                                        "Amount": int.parse(amountController.text),
                                        "pay": false
                                      },
                                    })
                                  ]);
                                }
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
                                if(snapshot.data!.keys.contains(nameController.text)){
                                  print("existing: ${snapshot.data?[nameController.text].runtimeType}");
                                  snapshot.data?[nameController.text].addEntries([MapEntry("${DateTime.now()}",{
                                    "Amount": int.parse(
                                        amountController.text),
                                    "pay": true
                                  })]);
                                  print("After adding payments: ${snapshot.data}");
                                }
                                else {
                                      snapshot.data?.addEntries([
                                        MapEntry(nameController.text, {
                                          "${DateTime.now()}": {
                                            "Amount": int.parse(
                                                amountController.text),
                                            "pay": true
                                          },
                                        })
                                      ]);
                                    }
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
                    setState(() {});
                  },
                ),
                body: RefreshIndicator(
                  color: Color(0xff141415),
                  onRefresh: () async{ setState((){}); },
                  child: ListView.builder(
                      itemCount: snapshot.data?.length,
                      itemBuilder: (context, index) {
                        print("initial dates: ${snapshot.data?.values.toList().reversed.elementAt(index).keys}");
                        int total = 0;
                        snapshot.data?.values.toList().reversed.elementAt(index).values.forEach((value){
                          // print("amount: ${value['Amount']}");
                          if(value['pay']) {
                            total -= value['Amount'] as int;
                          }
                          else{
                            total += value['Amount'] as int;
                          }
                        });
                        print("${snapshot.data?.keys.toList().reversed.elementAt(index)}: $total");
                        snapshot.data?.values.elementAt(index).keys.toList().sort((String a,String b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
                        print("final dates: ${snapshot.data?.values.toList().reversed.elementAt(index).keys}");
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                total<0?const Color(0xffb71c1c).withOpacity(0.4):Colors.green.withOpacity(0.4),
                                Colors.transparent
                              ],
                              stops: const [0.1,1]
                            )
                          ),
                          child: ListTile(
                            title: Text("${snapshot.data?.keys.toList().reversed.elementAt(index)}",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300,fontSize: 18)),
                            subtitle: Text("${DateTime.parse(snapshot.data?.values.toList().reversed.elementAt(index).keys.first as String)}".substring(0,19)),
                            trailing: total<0?Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("₹${total.abs()}",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w600,fontSize: 18),),
                                const Icon(Icons.arrow_upward, color: Colors.red,)
                              ],
                            ):Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("₹${total.abs()}",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w600,fontSize: 18)),
                                const Icon(Icons.arrow_downward, color: Colors.green,)
                              ],
                            ),
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => Individual(db: widget.db,data: snapshot.data!.entries.toList().reversed.elementAt(index)))
                              );
                            },
                          ),
                        );
                      }
                  ),
                )
            );
          }
          else if(snapshot.hasError){
            setState(() {});
            print(snapshot.error);
            return Center();
          }
          else{
            return Center();
          }
        }
    );
  }
}
