import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:string_validator/string_validator.dart';
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
  final noteController = TextEditingController();
  final amountController = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  Map<String,dynamic> data = {};

  Future<dynamic> get_connection() async{
    if(!widget.db.isConnected || widget.db.state == Mongo.State.closed || !widget.db.masterConnection.connected){

      await widget.db.close();
      await widget.db.open();
    }
  }

  Future<Map<String, dynamic>> get_data() async{
    await get_connection();
    return await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.People": 1}).last.then((value){
      return Map<String, dynamic>.from(value.values.last['People']);
    });
    // return data;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: get_data(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
          if(snapshot.hasData){
            data.clear();
            // int total = 0;
            for(int index=0;index<snapshot.data!.length;index++){
              if(data.keys.contains("${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}")){
                data[snapshot.data?.values.toList().reversed.elementAt(index).keys.first].addAll({
                  snapshot.data!.keys.toList().reversed.elementAt(index) : {
                    "Amount": snapshot.data?.values
                        .toList()
                        .reversed
                        .elementAt(index)
                        .values
                        .first,
                    "note": snapshot.data?.values
                        .toList()
                        .reversed
                        .elementAt(index)['note'],
                    "pay": snapshot.data?.values
                        .toList()
                        .reversed
                        .elementAt(index)
                        .values
                        .last
                  }
                });
              }
              else {
                data.addAll({
                  "${snapshot.data!.values.toList().reversed.elementAt(index).keys.first}" : {
                    snapshot.data!.keys.toList().reversed.elementAt(index): {
                      "Amount": snapshot.data?.values
                          .toList()
                          .reversed
                          .elementAt(index)
                          .values
                          .first,
                      "note": snapshot.data?.values
                          .toList()
                          .reversed
                          .elementAt(index)['note'],
                      "pay": snapshot.data?.values
                          .toList()
                          .reversed
                          .elementAt(index)
                          .values
                          .last
                    }
                  }
                });
              }
            }
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Transactions"),
                ),
                floatingActionButton: FloatingActionButton(
                  child: const Icon(Icons.add,color: Color(0xff141415)),
                  onPressed: () async{
                    await get_connection().then((value){
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xff27292a),
                            title: Text("Add Transaction",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w300)),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.next,
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
                                    enabledBorder:const UnderlineInputBorder(
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
                                  textInputAction: TextInputAction.next,
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
                                    else {
                                      return null;
                                    }
                                  },
                                ),
                                TextFormField(
                                  keyboardType: TextInputType.text,
                                  textInputAction: TextInputAction.done,
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
                                )
                              ],
                            ),
                            actionsAlignment: MainAxisAlignment.spaceBetween,
                            actions: [
                              TextButton(
                                child: Text("Collect",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w300),),
                                onPressed: () async{
                                  snapshot.data?.addEntries([MapEntry("${DateTime.now()}", {
                                    nameController.text : int.parse(amountController.text),
                                    "note" : noteController.text.isEmpty?null:noteController.text,
                                    "pay" : false
                                  })]);
                                  await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.People', snapshot.data)).then((value){
                                    Navigator.pop(context);
                                    setState(() {});
                                  }).catchError((error){
                                  });
                                  nameController.clear();
                                  amountController.clear();
                                },
                              ),
                              TextButton(
                                child: Text("Pay",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w300),),
                                onPressed: () async{
                                  snapshot.data?.addEntries([MapEntry("${DateTime.now()}", {
                                    nameController.text : int.parse(amountController.text),
                                    "note" : noteController.text.isEmpty?null:noteController.text,
                                    "pay" : true
                                  })]);
                                  await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.People', snapshot.data)).then((value){
                                    Navigator.pop(context);
                                    setState(() {});
                                  }).catchError((error){
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
                    });

                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(builder: (context) => NewParty(db: db))
                    // );
                  },
                ),
                body: RefreshIndicator(
                  color: const Color(0xff141415),
                  onRefresh: () async{ setState((){}); },
                  child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, tindex) {
                        int total = 0;
                        for(Map<String, dynamic > value in data.values.elementAt(tindex).values){
                          if(value['pay']){
                            total -= value['Amount'] as int;
                          }
                          else{
                            total += value['Amount'] as int;
                          }
                        }
                        /*if(snapshot.data?.values.toList().reversed.elementAt(index).values.last){
                          total -= snapshot.data?.values.toList().reversed.elementAt(index).values.first as int;
                        }
                        else{
                          total += snapshot.data?.values.toList().reversed.elementAt(index).values.first as int;
                        }*/
                        // snapshot.data?.values.toList().reversed.elementAt(index).values.forEach((value){
                        //   // if(value['pay']) {
                        //   //   total -= value['Amount'] as int;
                        //   // }
                        //   // else{
                        //   //   total += value['Amount'] as int;
                        //   // }
                        // });
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                total.isNegative?Colors.red.withOpacity(0.4):Colors.green.withOpacity(0.4),
                                Colors.transparent
                              ],
                              stops: const [0.1,1]
                            )
                          ),
                          child: ListTile(
                              title: Text(data.keys.elementAt(tindex),style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400,fontSize: 18)),
                              subtitle: Text("${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).day}-${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).month}-${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).year.toString().substring(2)} at ${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).hour}:${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).minute}:${DateTime.parse(snapshot.data!.keys.toList().reversed.elementAt(tindex)).second}"),
                              trailing: total.isNegative?Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("₹${total.abs()}",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w600,fontSize: 18)),
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                        appBar: AppBar(
                                            title: Text(data.keys.elementAt(tindex))
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
                                                                      data.keys.elementAt(tindex): int.parse(amountController.text),
                                                                      "note" : noteController.text.isEmpty?null:noteController.text,
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
                                                                      data.keys.elementAt(tindex): int.parse(amountController.text),
                                                                      "note" : noteController.text.isEmpty?null:noteController.text,
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
                                          color:  const Color(0xff141415),
                                          child: ListView.builder(
                                            itemCount: data.entries.elementAt(tindex).value.length,
                                            itemBuilder: (context, index) {
                                              return Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            data.values.elementAt(tindex).values.elementAt(index)['pay']?Colors.red.withOpacity(0.4):Colors.green.withOpacity(0.4),
                                                            Colors.transparent,
                                                          ],
                                                          stops: const [0.1,1]
                                                      )
                                                  ),
                                                  child: ListTile(
                                                    title: Text("₹${data.values.elementAt(tindex).values.elementAt(index)['Amount']}",style: GoogleFonts.roboto(color: data.values.elementAt(tindex).values.elementAt(index)['pay']?Colors.red:Colors.green, fontWeight: FontWeight.w600,fontSize: 18)),
                                                    subtitle: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                            DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()<60?
                                                            DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()==1?
                                                            "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minute ago":
                                                            "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minutes ago":
                                                            DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs()==1?
                                                            "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hour ago":
                                                            "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hours ago",
                                                            style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)
                                                        ),
                                                        data.values.elementAt(tindex).values.elementAt(index)['note'] != null ?Text(" - ${data.values.elementAt(tindex).values.elementAt(index)['note']}",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)):const SizedBox()
                                                      ],
                                                    ),
                                                    trailing: data.values.elementAt(tindex).values.elementAt(index)['pay']?const Icon(Icons.arrow_upward, color: Colors.red,):const Icon(Icons.arrow_downward, color: Colors.green,),
                                                    /*onLongPress: (){
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => AlertDialog(
                                                          title: const Text("Delete Transaction?"),
                                                          content: ListTile(
                                                            title: Text("₹${data.values.elementAt(tindex).values.elementAt(index)['Amount']}",style: GoogleFonts.roboto(color: data.values.elementAt(tindex).values.elementAt(index)['pay']?Colors.red:Colors.green, fontWeight: FontWeight.w600,fontSize: 18)),
                                                            subtitle: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Text(
                                                                    DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()<60?
                                                                    DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs()==1?
                                                                    "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minute ago":
                                                                    "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inMinutes.abs().toString()} minutes ago":
                                                                    DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs()==1?
                                                                    "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hour ago":
                                                                    "${DateTime.parse(data.values.elementAt(tindex).keys.elementAt(index)).difference(DateTime.now()).inHours.abs().toString()} hours ago",
                                                                    style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)
                                                                ),
                                                                data.values.elementAt(tindex).values.elementAt(index)['note'] != null ?Text(" - ${data.values.elementAt(tindex).values.elementAt(index)['note']}",style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.w400)):const SizedBox()
                                                              ],
                                                            ),
                                                            trailing: data.values.elementAt(tindex).values.elementAt(index)['pay']?const Icon(Icons.arrow_upward, color: Colors.red,):const Icon(Icons.arrow_downward, color: Colors.green,),
                                                            tileColor: const Color(0xff5d5f64),
                                                          ),
                                                          backgroundColor: const Color(0xff27292a),
                                                          actions: [
                                                            TextButton(
                                                              child: Text("Yes",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w300,fontSize: 18)),
                                                              onPressed: () async{

                                                                print("SNAPSHOTB: ${snapshot.data}");
                                                                snapshot.data!.remove(data.values.elementAt(tindex).keys.elementAt(index));
                                                                print("SNAPSHOTA: ${snapshot!.data}");
                                                                print("DATAb: $data");
                                                                data.values.elementAt(tindex).remove(data.values.elementAt(tindex).keys.elementAt(index));
                                                                print("DATAa: $data");
                                                                await widget.db.collection('test').update({"_id" : FirebaseAuth.instance.currentUser?.uid}, {FirebaseAuth.instance.currentUser?.displayName : {
                                                                  "People" : snapshot.data
                                                                }.cast<String, dynamic>(),
                                                                },multiUpdate: true).then((value){
                                                                  setState(() {

                                                                  });
                                                                });
                                                              },
                                                            ),
                                                            TextButton(
                                                              child: Text("No",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w300,fontSize: 18)),
                                                              onPressed: (){

                                                              },
                                                            )
                                                          ],
                                                        )
                                                      );
                                                    },*/
                                                  )
                                              );
                                            },
                                          ),
                                          onRefresh: () async{
                                            data.clear();
                                            setState(() {});
                                          },
                                        )
                                    )
                                  )
                                );
                            }
                          )
                        );
                      }
                  ),
                )
            );
          }
          else if(snapshot.hasError){
            get_connection().then((value){
              setState(() {});
            });

            return Scaffold(
              appBar: AppBar(
                title: const Text("Transactions"),
              ),
              body: const Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("Fetching Data")
                      ]
                  )
              )
            );
          }
          else{
            return Scaffold(
                appBar: AppBar(
                  title: const Text("Transactions"),
                ),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 20),
                        Text("Fetching Data")
                      ]
                  )
                )
            );
          }
        }
    );
  }
}
