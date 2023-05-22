import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:string_validator/string_validator.dart';

class Stock extends StatefulWidget {
  Stock({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;

  Future<dynamic> get_connection() async{
    if(!db.isConnected || db.state == Mongo.State.closed || !db.masterConnection.connected){

      await db.close();
      await db.open();
    }
  }
  Future<Map<String, dynamic>> get_data() async{
    await get_connection();
    return await db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.Items": 1}).last.then((value) async{
        print("${value.values.last['Items']}");
      return value.values.last['Items'];
    });

  }

  @override
  State<Stock> createState() => _StockState();
}

class _StockState extends State<Stock> {
  final formkey = GlobalKey<FormState>();
  late int cp,sp,qty;
  late String name;
  Map<String, dynamic> items = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Stocks")
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add,color: Color(0xff141415)),
        onPressed: (){
          showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Add Item"),
                backgroundColor: const Color(0xff27292a),
                content: Form(
                    key: formkey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                          onSaved: (value){
                            name = value!;
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter Item Name";
                            }
                            else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Purchase Price',
                            labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                          onSaved: (value){
                            cp = int.parse(value!);
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter Purchase Price";
                            }
                            else if(!isNumeric(value)){
                              return "Enter numeric value";
                            }
                            else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Selling Price',
                            labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                          onSaved: (value){
                            sp = int.parse(value!);
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter Selling Price";
                            }
                            else if(!isNumeric(value)){
                              return "Enter numeric value";
                            }
                            else {
                              return null;
                            }
                          },
                        ),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            labelText: 'Quantity',
                            labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                          onSaved: (value){
                            qty = int.parse(value!);
                          },
                          validator: (value){
                            if(value!.isEmpty){
                              return "Enter Quantity";
                            }
                            else if(!isNumeric(value)){
                              return "Enter numeric value";
                            }
                            else {
                              return null;
                            }
                          },
                        ),
                      ],
                    )
                ),
                actions: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                  TextButton(
                      onPressed: () async{
                        if(formkey.currentState!.validate()){
                          formkey.currentState!.save();
                          items.addEntries([MapEntry(
                              name,
                              {
                                'cp' : cp,
                                'sp' : sp,
                                'qty': qty
                              }
                          )]);
                          await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),
                              Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.Items', items),
                              multi: true,
                            upsert: true
                          ).then((value){
                            setState(() {});
                            Navigator.pop(context);
                          });
                        }
                      },
                      child: const Text("Add")
                  )
                ],
              )
          );
        },
      ),
      body: FutureBuilder(
        future: widget.get_data(),
        builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
          if(snapshot.hasData){
            // print("data: ${snapshot.data}");
            items = snapshot.data!;
            return RefreshIndicator(
                color: const Color(0xff141415),
                child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text("${snapshot.data?.keys.elementAt(index)}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                              onPressed: (){
                                showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Edit ${snapshot.data?.keys.elementAt(index)}"),
                                      backgroundColor: const Color(0xff27292a),
                                      content: Form(
                                        key: formkey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                                // controller: cpController,
                                                keyboardType: TextInputType.number,
                                                textInputAction: TextInputAction.next,
                                                decoration: InputDecoration(
                                                  labelText: 'Purchase Price',
                                                  labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                                              initialValue: snapshot.data?.values.elementAt(index)['cp'].toString(),
                                              onSaved: (value){
                                                  cp = int.parse(value!);
                                              },
                                              validator: (value){
                                                  if(value!.isEmpty){
                                                    return "Enter Purchase Price";
                                                  }
                                                  else if(!isNumeric(value)){
                                                    return "Enter numeric value";
                                                  }
                                                  else {
                                                    return null;
                                                  }
                                              },
                                            ),
                                            TextFormField(
                                                // controller: spContoller,
                                                keyboardType: TextInputType.number,
                                                textInputAction: TextInputAction.next,
                                                decoration: InputDecoration(
                                                  labelText: 'Selling Price',
                                                  labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                                              initialValue: snapshot.data?.values.elementAt(index)['sp'].toString(),
                                              onSaved: (value){
                                                sp = int.parse(value!);
                                              },
                                              validator: (value){
                                                if(value!.isEmpty){
                                                  return "Enter Selling Price";
                                                }
                                                else if(!isNumeric(value)){
                                                  return "Enter numeric value";
                                                }
                                                else {
                                                  return null;
                                                }
                                              },
                                            ),
                                            TextFormField(
                                                // controller: qtyController,
                                                keyboardType: TextInputType.number,
                                                textInputAction: TextInputAction.done,
                                                decoration: InputDecoration(
                                                  labelText: 'Quantity',
                                                  labelStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
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
                                              initialValue: snapshot.data?.values.elementAt(index)['qty'].toString(),
                                              onSaved: (value){
                                                qty = int.parse(value!);
                                              },
                                              validator: (value){
                                                if(value!.isEmpty){
                                                  return "Enter Quantity";
                                                }
                                                else if(!isNumeric(value)){
                                                  return "Enter numeric value";
                                                }
                                                else {
                                                  return null;
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      ),
                                      actions: [
                                        TextButton(
                                          child: const Text("Cancel"),
                                          onPressed: (){
                                            Navigator.pop(context);
                                          },
                                        ),
                                        TextButton(
                                            onPressed: () async{
                                              if(formkey.currentState!.validate()){
                                                formkey.currentState!.save();
                                                snapshot.data?.update(snapshot.data!.keys.elementAt(index), (value) =>
                                                {
                                                  'cp' : cp,
                                                  'sp' : sp,
                                                  'qty': qty
                                                });
                                                await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.Items', snapshot.data),multi: true).then((value){
                                                  setState(() {});
                                                  Navigator.pop(context);
                                                });
                                              }
                                            },
                                            child: const Text("Update")
                                        )
                                      ],
                                    )
                                );
                              },
                              icon: const Icon(Icons.edit, color: Colors.white,)
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red,),
                            onPressed: () async{
                              // await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"Nigam1.Items": 1}).last.then((value) async{
                              //   value
                              // });
                              print("old list: ${snapshot.data}");
                              snapshot.data?.remove(snapshot.data?.keys.elementAt(index));
                              print("new list: ${snapshot.data}");
                              await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.Items', snapshot.data),multi: true);
                              setState(() {});
                              // await widget.db.collection('test').update(selector, document)
                            },
                          )
                        ],
                      ),
                    )
                ),
                onRefresh: () async{
                  setState(() {});
                }
            );

          }
          else if(snapshot.hasError){
            print(snapshot.error);
            widget.get_data().then((value){
              setState(() {});
            });

            return const Center(
                child: CircularProgressIndicator()
            );
          }
          else{
            return const Center(
                child: CircularProgressIndicator()
            );
          }
        },
      ),
    );
  }
}

