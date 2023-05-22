import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;

import 'Login.dart';
import 'cnb.dart';
import 'parties.dart';
import 'payments.dart';
import 'sales.dart';
import 'stock.dart';
import 'items.dart';

class Home extends StatefulWidget {
  Home({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Future<dynamic> get_connection() async{
    if(!widget.db.isConnected || widget.db.state == Mongo.State.closed || !widget.db.masterConnection.connected){

      await widget.db.close();
      await widget.db.open();
    }
  }

  Future<Map<String, dynamic>> get_data() async{
    await get_connection();

    return await widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.Parties": 1}).last.then((value){
      return Map<String, dynamic>.from(value.values.last['Parties']);
    });
    // return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("LedgerMate")
        ),
        drawer: Drawer(
            backgroundColor: const Color(0xff141415),
            child: ListView(
              children: [
                Container(
                  height: 100,
                  color: const Color(0xffb1b5b7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      Text("${FirebaseAuth.instance.currentUser?.displayName}",style: GoogleFonts.roboto(color: const Color(0xff000000), fontWeight: FontWeight.w700,fontSize: 50))
                    ],
                  ),
                ),
                const ListTile(
                    title: Text("My Account")
                ),
                ListTile(
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: () async{
                    await FirebaseAuth.instance.signOut().then((value) {
                      Navigator.popUntil(context, (route) => route.isFirst);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Login(db: widget.db))

                      );
                    });

                  },
                ),

              ],
            )
        ),
        body: FutureBuilder(
            future: get_data(),
            builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
              if(snapshot.hasData){
                int collect=0,pay=0;
                for (var entry in snapshot.data!.entries) {
                  entry.value['Items'].entries.forEach((item){
                    if(item.value['pay']){
                      pay += item.value['cp'] as int;
                    }
                    if(!item.value['pay']){
                      collect += item.value['sp'] as int;
                    }
                  });
                }
                return RefreshIndicator(
                    color: const Color(0xff141415),
                    child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: ListView(
                            children: [
                              GridView(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 3,
                                    mainAxisSpacing: 30,
                                    crossAxisSpacing: 20
                                ),
                                children: [
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                    ),
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Parties(db: widget.db,tabIndex: 0,))
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Collect ",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18 )),
                                        Text("₹$collect",style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.w300,fontSize: 18 )),
                                        const Icon(Icons.arrow_downward,color: Colors.green,)
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                      shadowColor: MaterialStateProperty.all(const Color(0xff000000)),
                                    ),
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Parties(db: widget.db,tabIndex: 1,))
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("Pay ",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18 )),
                                        Text("₹$pay",style: GoogleFonts.roboto(color: Colors.red, fontWeight: FontWeight.w300,fontSize: 18 )),
                                        const Icon(Icons.arrow_upward,color: Colors.red,)
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                      // shadowColor: MaterialStateProperty.all(Colors.white),
                                    ),
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Stock(db: widget.db))
                                      );
                                    },
                                    child: Text("Stock Value",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18 )),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                    ),
                                    onPressed: (){
                                      // Navigator.push(
                                      //     context,
                                      //     MaterialPageRoute(builder: (context) => Sales())
                                      // );
                                    },
                                    child: Column(
                                      children: [
                                        Text("$collect",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18 )),
                                        Text("This Week's Sale",style: GoogleFonts.roboto(color: const Color(0xffb1b5b7), fontWeight: FontWeight.w300,fontSize: 14 )),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                      // side: MaterialStateProperty.all(BorderSide(color: Color(0xff5d5f64),width: 3))
                                    ),
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => CnB())
                                      );
                                    },
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Total Balance",style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18 )),
                                        Text("Cash + Bank Balance",style: GoogleFonts.roboto(color: const Color(0xffb1b5b7), fontWeight: FontWeight.w300,fontSize: 14 )),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all(const Color(0xff27292a)),
                                      shape: MaterialStateProperty.all(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)))),
                                      elevation: MaterialStateProperty.all(10),
                                      // side: MaterialStateProperty.all(BorderSide(color: Color(0xff5d5f64),width: 3))
                                    ),
                                    onPressed: (){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => Transactions(db: widget.db,))
                                      );
                                    },
                                    child: Text(
                                      "Transactions",
                                      // textAlign: TextAlign.center,
                                      style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 18),
                                    )
                                  )
                                ],
                              ),
                              const Padding(padding: EdgeInsets.only(top: 20)),
                              const Text("Recent Transactions",style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                              FutureBuilder(
                                  future: widget.db.collection('test').modernFind(selector: Mongo.where.eq("_id", FirebaseAuth.instance.currentUser?.uid),projection: {"${FirebaseAuth.instance.currentUser?.displayName}.People": 1}).last.then((value){
                                    return Map<String, dynamic>.from(value.values.last['People']);
                                  }),
                                  builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot){
                                    if(snapshot.hasData){
                                      return snapshot.data!.isEmpty? Padding(
                                        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/5),
                                        child: Text("No Transactions",textAlign: TextAlign.center, style: GoogleFonts.roboto(color: const Color(0xffb1b5b7), fontWeight: FontWeight.w300,fontSize: 14 )),
                                      ):ListView.builder(
                                          shrinkWrap: true,
                                          physics: const NeverScrollableScrollPhysics(),
                                          itemCount: snapshot.data!.length>10?10:snapshot.data?.length,
                                          itemBuilder: (context, index) => ListTile(
                                              title: Text("${snapshot.data?.values.toList().reversed.elementAt(index).keys.first}"),
                                              subtitle: Text("${DateTime.parse(snapshot.data?.keys.toList().reversed.elementAt(index) as String)}"),
                                              trailing: snapshot.data?.values.toList().reversed.elementAt(index).values.last?Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("₹${snapshot.data?.values.toList().reversed.elementAt(index).values.first}"),
                                                  const Icon(Icons.arrow_upward, color: Colors.red,)
                                                ],
                                              ):Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text("₹${snapshot.data?.values.toList().reversed.elementAt(index).values.first}"),
                                                  const Icon(Icons.arrow_downward, color: Colors.green,)
                                                ],
                                              )
                                          )
                                      );
                                    }
                                    else if(snapshot.hasError){
                                      return const Center();
                                    }
                                    else{
                                      return const Center();
                                    }
                                  }
                              )
                            ],
                          )
                      ),


                    onRefresh: () async{
                      setState(() {});
                    }
                );
              }
              else if(snapshot.hasError){
                // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unable to connect to server")));
                get_data().then((value){
                  setState(() {});
                });

                return const SizedBox();
              }
              else {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white,),
                );
              }
            }
        ),
          

    );
  }
}
