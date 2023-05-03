import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class NewParty extends StatefulWidget {
  NewParty({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;
  @override
  State<NewParty> createState() => _NewPartyState();
}

class _NewPartyState extends State<NewParty> {
  final _formkey = GlobalKey<FormState>();
  late String pname;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Party")
      ),
      body: Center(
        child: Form(
          key: _formkey,
          child: Padding(
            padding: EdgeInsets.all(50),
            child: ListView(
              children: [
                const Text('New Party',style: TextStyle(fontSize: 23,fontWeight: FontWeight.bold)),
                Container(height: 20),
                TextFormField(
                    cursorColor: Colors.black,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person_outline, color: Colors.purple),
                      labelText: "Name",
                      labelStyle: TextStyle(color: Colors.black,fontSize: 15),
                      border:UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black
                          )
                      ),
                      focusedBorder:UnderlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.blue
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    validator:(value){
                      // if(value.isEmpty) return "Required!";

                    },
                    onSaved: (value){

                    }
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
