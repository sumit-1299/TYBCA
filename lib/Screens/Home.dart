import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'UI/Login.dart';
import 'UI/cnb.dart';
import 'UI/parties.dart';
import 'UI/payments.dart';
import 'UI/sales.dart';
import 'UI/stock.dart';
class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

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
                  MaterialPageRoute(builder: (context) => Login())
                    
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
                          MaterialPageRoute(builder: (context) => Parties())
                        );
                      },
                    ),
                    ListTile(
                      title: Text("To Pay"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Parties())
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
                    /*ListTile(
                      title: Text("Reports"),
                      onTap: (){
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Reports())
                        );
                      },
                    ),*/
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
