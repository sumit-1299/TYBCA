import 'package:flutter/material.dart';

class Payments extends StatelessWidget {
  const Payments({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Payments"),
          bottom: TabBar(
            tabs: [
              Text("Received",style: TextStyle(fontSize: 20)),
              Text("Sent",style: TextStyle(fontSize: 20))
            ]
          )
        ),
        body: TabBarView(
          children: [
            ListView.builder(
              itemCount: 100,
              itemBuilder: (context,index) => ListTile(
                title: Text("₹$index"),
                subtitle: Text("Sample"),
                trailing: Text("Sample"),
              ),
            ),
            ListView.builder(
              itemCount: 100,
              itemBuilder: (context,index) => ListTile(
                  title: Text("$index")
              ),
            ),
          ],
        )
      )
    );
  }
}
