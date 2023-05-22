import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class NewParty extends StatefulWidget {
  NewParty({Key? key, required this.db, required this.data}) : super(key: key);

  Mongo.Db db;
  Map<String, dynamic> data;
  Future<dynamic> get_connection() async{
    if(!db.isConnected || db.state == Mongo.State.closed || !db.masterConnection.connected){
      await db.close();
      await db.open();
    }
  }

  Future<Map<String, dynamic>> get_data() async{
    await get_connection();
    return db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.Items": 1}).last.then((value) async{
      return value.values.last['Items'] as Map<String, dynamic>;
    });
  }
  @override
  State<NewParty> createState() => _NewPartyState();
}

class _NewPartyState extends State<NewParty> {
  final _formkey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final gstController = TextEditingController();
  final cpController = TextEditingController();
  final spController = TextEditingController();
  final qtyController = TextEditingController();
  late String selectedItem = "";
  bool pay = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Party")
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formkey,
            child: Padding(
              padding: const EdgeInsets.all(50),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: Colors.white),
                      hintText: "Name",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:(value){
                      if(value!.isEmpty) {
                        return "Required!";
                      }
                      else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: gstController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.numbers, color: Colors.white),
                      hintText: "GST No.",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:(value){
                      if(value!.isEmpty) {
                        return "Required!";
                      }
                      else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  FutureBuilder(
                      future: widget.get_data(),
                      builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
                        if(snapshot.hasData){
                          List<DropdownMenuItem<String>> items = [];
                          if(selectedItem.isEmpty) selectedItem = snapshot.data!.keys.first;

                          for(var item in snapshot.data!.entries){
                            items.add(
                                DropdownMenuItem(
                                  value: item.key,
                                  child: Text(item.key,style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),),
                                )
                            );
                          }
                          return Row(
                            children: [
                              Text("Item: ",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 16)),
                              DropdownButton(
                                  items: items,
                                  value: selectedItem,
                                  underline: const SizedBox(),
                                  dropdownColor: const Color(0xff27292a),
                                  onChanged: (index){
                                    setState(() {
                                      selectedItem = index!;
                                    });
                                  })
                            ],
                          );
                        }
                        else{
                          widget.get_data().then((value){
                            setState(() {

                            });
                          });
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      }),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: cpController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.currency_rupee, color: Colors.white),
                      hintText: "Purchase Price",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator:(value){
                      if(value!.isEmpty) {
                        return "Required!";
                      }
                      else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: spController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.currency_rupee, color: Colors.white),
                      hintText: "Selling Price",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator:(value){
                      if(value!.isEmpty) {
                        return "Required!";
                      }
                      else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  TextFormField(
                    controller: qtyController,
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.shopping_cart, color: Colors.white),
                      hintText: "Quantity",
                      hintStyle: TextStyle(color: Colors.white,fontSize: 15),
                      border: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      enabledBorder:UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.white
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    validator:(value){
                      if(value!.isEmpty) {
                        return "Required!";
                      }
                      else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 20,),
                  DropdownButton(
                      items: const [
                        DropdownMenuItem(value: false, child: Text("Collect")),
                        DropdownMenuItem(value: true, child: Text("Pay")),
                      ],
                      value: pay,
                      dropdownColor: const Color(0xff27292a),
                      underline: const SizedBox(),
                      onChanged: (index){
                        setState(() {
                          pay = index!;
                        });
                      }
                  ),
                  const SizedBox(height: 20,),
                  TextButton(
                    onPressed: () async{
                      if(_formkey.currentState!.validate()){
                        if(!widget.data.containsKey(nameController.text)){
                          widget.data.addEntries([
                            MapEntry(nameController.text, {
                              "Items": {
                                selectedItem : {
                                  "cp": int.parse(cpController.text),
                                  "sp": int.parse(spController.text),
                                  "qty": int.parse(qtyController.text),
                                  "pay" : pay
                                }
                              },
                              "GST": gstController.text
                            })
                          ]);
                        }
                        else{
                          widget.data[nameController.text]['Items'].addEntries([
                            MapEntry(
                              selectedItem,
                                {
                                  "cp": int.parse(cpController.text),
                                  "sp": int.parse(spController.text),
                                  "qty": int.parse(qtyController.text),
                                  "pay" : pay
                                }
                            )
                          ]);
                        }
                        await widget.db.collection('test').modernUpdate(
                            Mongo.where.eq(
                                "_id", FirebaseAuth.instance.currentUser?.uid),
                            Mongo.modify.set(
                                '${FirebaseAuth.instance.currentUser?.displayName}.Parties',
                                widget.data),
                            multi: true,
                            upsert: true
                        ).then((value){
                          Navigator.pop(context);
                          setState(() {

                          });
                        });

                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                      elevation: MaterialStateProperty.all(10),
                      // side: MaterialStateProperty.all(BorderSide(color: Color(0xff5d5f64),width: 3))
                    ),
                    child: Text(
                        "Add Party",
                        style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18)
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
