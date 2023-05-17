import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

class Items extends StatefulWidget {
  Items({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;

  Future<List<dynamic>> get_data() async{
    if(!db.isConnected || db.state == Mongo.State.closed || !db.masterConnection.connected){

      await db.close();
      await db.open().then((value) {
        print("connection Successful");
        print("state: ${db.state}, connected? ${db.isConnected}");
        return value;
      }).catchError((error) {
        print("Error: ${error.toString()}");
      });
    }

    return await db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.Items": 1}).last.then((value) async{
      print("${value.values.last['Items'].runtimeType}");
      return value.values.last['Items'];
    });

  }

  @override
  State<Items> createState() => _ItemsState();
}

class _ItemsState extends State<Items> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Items")
        ),
        body: FutureBuilder(
          future: widget.get_data(),
          builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
            if(snapshot.hasData){
              // print("data: ${snapshot.data}");
              return RefreshIndicator(
                color: Color(0xff141415),
                  child: ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) => ListTile(
                    title: Text("${snapshot.data?.elementAt(index)}"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: (){
                              TextEditingController _controller = TextEditingController();
                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Edit Item"),
                                    content: TextFormField(
                                      controller: _controller,
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text("Cancel"),
                                        onPressed: (){
                                          Navigator.pop(context);
                                        },
                                      ),
                                      TextButton(
                                          onPressed: () async{
                                            print("old list: ${snapshot.data}");
                                            snapshot.data?.removeAt(index);
                                            snapshot.data?.insert(index, _controller.value.text);
                                            print("new list: ${snapshot.data}");
                                            await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('${FirebaseAuth.instance.currentUser?.displayName}.Items', snapshot.data));
                                            setState(() {});
                                            Navigator.pop(context);
                                          },
                                          child: Text("Update")
                                      )
                                    ],
                                  )
                              );
                            },
                            icon: Icon(Icons.edit, color: Colors.white,)
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red,),
                          onPressed: () async{
                            // await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"Nigam1.Items": 1}).last.then((value) async{
                            //   value
                            // });
                            print("old list: ${snapshot.data}");
                            snapshot.data?.removeAt(index);
                            print("new list: ${snapshot.data}");
                            await widget.db.collection('test').modernUpdate(Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid), Mongo.modify.set('Nigam1.Items', snapshot.data) );
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
              return Center(
                  child: Text("${snapshot.error}")
              );
            }
            else{
              return Center(
                  child: CircularProgressIndicator()
              );
            }
          },
        ),
    );
  }
}
