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
                TextFormField(
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
                    onSaved: (value){
                      pname = value!;
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
