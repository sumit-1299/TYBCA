import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:string_validator/string_validator.dart';

class Individual extends StatefulWidget {
  Individual({Key? key, required this.db, required this.data, required this.index}) : super(key: key);

  Mongo.Db db;
  Map<String, dynamic> data;
  int index;


  @override
  State<Individual> createState() => _IndividualState();
}

class _IndividualState extends State<Individual> {
  final _formkey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController();

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

  Future<Map<String, dynamic>> get_data() async{
    print("DB state: ${widget.db.isConnected}");
    await get_connection();
    return await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.People": 1}).last.then((value){
      return Map<String, dynamic>.from(value.values.last['People']);
    });
    // return data;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.data.entries.elementAt(widget.index));
    return Scaffold(
        appBar: AppBar(
            title: Text(widget.data.keys.elementAt(widget.index))
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.3,40)),
                    shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ))
                ),
                onPressed: () async{
                  await get_data().then((transactions){
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xff27292a),
                          title: Text("Add Transaction",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300)),
                          content: Form(
                            key: _formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                                    enabledBorder:const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        )
                                    ),
                                  ),
                                  validator: (value){
                                    if(value!.isEmpty){
                                      return 'Enter Amount';
                                    }
                                    else if(!isNumeric(value)){
                                      return 'Enter numeric value';
                                    }
                                    else {
                                      return null;
                                    }
                                  },
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: noteController,
                                  decoration: InputDecoration(
                                    hintText: 'Note',
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
                                    enabledBorder:const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        )
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              child: Text("Collect",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w300),),
                              onPressed: () async{
                                if(_formkey.currentState!.validate()) {
                                      transactions.addEntries([
                                        MapEntry("${DateTime.now()}", {
                                          widget.data.keys.elementAt(widget.index): int.parse(amountController.text),
                                          "note" : noteController.text,
                                          "pay": false
                                        })
                                      ]);
                                      await widget.db
                                          .collection('test')
                                          .modernUpdate(
                                              Mongo.where.eq(
                                                  "_id",
                                                  FirebaseAuth.instance
                                                      .currentUser?.uid),
                                              Mongo.modify.set(
                                                  '${FirebaseAuth.instance.currentUser?.displayName}.People',
                                                  transactions))
                                          .then((value) {
                                        Navigator.pop(context);
                                        setState(() {});
                                      }).catchError((error) {
                                        // print("error: $error");
                                      });
                                      noteController.clear();
                                      amountController.clear();
                                    }
                                  },
                            ),
                          ],
                        )
                    );
                  });
                },
                child: Text(
                  "Collect",
                  // textAlign: TextAlign.center,
                  style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300,fontSize: 18),
                )
            ),
            TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        fixedSize: MaterialStateProperty.all(Size(MediaQuery.of(context).size.width*0.3,40)),
                        shape: MaterialStateProperty.all(const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ))
                      ),
                onPressed: () async{
                  await get_data().then((transactions){
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: const Color(0xff27292a),
                          title: Text("Add Transaction",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300)),
                          content: Form(
                              key: _formkey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
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
                                      enabledBorder:const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          )
                                      ),
                                    ),
                                    validator: (value){
                                      if(value!.isEmpty){
                                        return 'Enter Amount';
                                      }
                                      else if(!isNumeric(value)){
                                        return 'Enter numeric value';
                                      }
                                      else {
                                        return null;
                                      }
                                    },
                                  ),
                                  TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: noteController,
                                    decoration: InputDecoration(
                                      hintText: 'Note',
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
                                      enabledBorder:const UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          )
                                      ),
                                    ),
                                  ),
                                ],
                              )
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            TextButton(
                              child: Text("Pay",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w300),),
                              onPressed: () async{
                                if(_formkey.currentState!.validate()) {
                                  transactions.addEntries([
                                    MapEntry("${DateTime.now()}", {
                                      widget.data.keys.elementAt(widget.index): int.parse(amountController.text),
                                      "note" : noteController.text,
                                      "pay": true
                                    })
                                  ]);
                                  await widget.db
                                      .collection('test')
                                      .modernUpdate(
                                      Mongo.where.eq(
                                          "_id",
                                          FirebaseAuth.instance
                                              .currentUser?.uid),
                                      Mongo.modify.set(
                                          '${FirebaseAuth.instance.currentUser?.displayName}.People',
                                          transactions))
                                      .then((value) {
                                    Navigator.pop(context);
                                    setState(() {});
                                  }).catchError((error) {
                                    // print("error: $error");
                                  });
                                  noteController.clear();
                                  amountController.clear();
                                }
                              },
                            ),
                          ],
                        )
                    );
                  });
                },
                        child: Text(
                          "Pay",
                          // textAlign: TextAlign.center,
                          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300,fontSize: 18),
                        )
                    )
          ],
        ),
        body: RefreshIndicator(
          child: ListView.builder(
            itemCount: widget.data.entries.elementAt(widget.index).value.length,
            itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          widget.data.values.elementAt(widget.index).values.elementAt(index)['pay']?Colors.red.withOpacity(0.4):Colors.green.withOpacity(0.4),
                          Colors.transparent
                        ],
                        stops: const [0.1,1]
                    )
                ),
                child: ListTile(
                    title: Text("₹${widget.data.values.elementAt(widget.index).values.elementAt(index)['Amount']}",style: GoogleFonts.roboto(color: widget.data.values.elementAt(widget.index).values.elementAt(index)['pay']?Colors.red:Colors.green, fontWeight: FontWeight.w600,fontSize: 18)),
                  subtitle: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                          DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()<60?
                          DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()==1?
                          "${DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minute ago":
                          "${DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minutes ago":
                          DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inHours.abs()==1?
                          "${DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hour ago":
                          "${DateTime.parse(widget.data.values.elementAt(widget.index).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hours ago",
                          style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)
                      ),
                      widget.data.values.elementAt(widget.index).values.elementAt(index)['note'].isNotEmpty?Text(widget.data.values.elementAt(widget.index).values.elementAt(index)['note'],style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)):const SizedBox()
                    ],
                  ),
                  trailing: widget.data.values.elementAt(widget.index).values.elementAt(index)['pay']?const Icon(Icons.arrow_upward, color: Colors.red,):const Icon(Icons.arrow_downward, color: Colors.green,),
                )
            ),
          ),
          onRefresh: () async{
            setState(() {});
          },
        )
    );
  }
}