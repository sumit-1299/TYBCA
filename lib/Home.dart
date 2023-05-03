import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'Login.dart';
import 'cnb.dart';
import 'parties.dart';
import 'payments.dart';
import 'sales.dart';
import 'stock.dart';
import 'items.dart';
class Home extends StatelessWidget {
  Home({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;

  @override
  void initState() async{
    if(!db.isConnected){
      await db.open().then((value) {
        print("connection Successful");
        print("state: ${db.state}, connected? ${db.isConnected}");
        return value;
      }).catchError((error) {
        print("Error: ${error.toString()}");
      });
    }
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
         title: Text("Khatabook")
       ),
      drawer: Drawer(
        child: ListView(
          children: [
            Container(
              height: 100,
              color: Colors.purple,
            ),
            ListTile(
              title: Text("My Account")
            ),
            ListTile(
              title: Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () async{
                await FirebaseAuth.instance.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                    context,
                  MaterialPageRoute(builder: (context) => Login(db: db))
                    
                );
              },
            ),
            
          ],
        )
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      mainAxisSpacing: 50,
                      crossAxisSpacing: 20
                  ),
                  children: [
                    ListTile(
                      title: Text("To Collect"),
                      onTap: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Parties(db: db,tabIndex: 0,))
                        );
                      },
                    ),
                    ListTile(
                      title: Text("To Pay"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Parties(db: db,tabIndex: 1,))
                        );
                      },
                    ),
                    ListTile(
                      title: Text("Stock Value"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Stock())
                        );
                      },
                    ),
                    ListTile(
                      title: Text("0"),
                      subtitle: Text("This Week's Sale"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Sales())
                        );
                      },
                    ),
                    ListTile(
                      title: Text("Total Balance"),
                      subtitle: Text("Cash + Bank Balance"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => CnB())
                        );
                      },
                    ),
                    ListTile(
                      title: Text("Items"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Items(db: db))
                        );
                      },
                    ),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(top: 20)),
                const Text("Transactions",style: TextStyle(fontSize: 20),),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 10,
                  itemBuilder: (context, index) => ListTile(
                    title: Text(index.toString()),
                  ),
                )
              ],
            )
          ),
        ),
      ),
       floatingActionButton: Container(
         decoration: BoxDecoration(
             color: Colors.purple,
           borderRadius: BorderRadius.all(Radius.circular(20)),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.5),
               spreadRadius: 1,
               blurRadius: 10
             )
           ]
         ),
           width: MediaQuery.of(context).size.width*0.3,
           height: 40,
           child: Center(
             child: TextButton(
               onPressed: (){
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => Payments())
                 );
               },
               child: Text(
                 "Payments",
                 // textAlign: TextAlign.center,
                 style: TextStyle(
                     color: Colors.white
                 ),
               )
             )
           )
         )

    );
  }
}
