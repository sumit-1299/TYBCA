// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:register1/Screens/UI/Login.dart';
// import 'package:register1/utils/utils.dart';
//
// class Home extends StatefulWidget {
//   const Home({Key? key}) : super(key: key);
//
//   @override
//   State<Home> createState() => _HomeState();
// }
//
// class _HomeState extends State<Home> {
//   final auth = FirebaseAuth.instance;
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Home'),
//       ),
//       body: Center(
//         child: Column(
//           children:[
//           IconButton(onPressed: (){
//             auth.signOut().then((value){
//                Navigator.push(context,
//                 MaterialPageRoute(builder: (context)=> Login()));
//             }).onError((error, stackTrace){
//             Utils().toastMessage(error.toString());
//           });
//               }, icon: Icon(Icons.login_outlined),),
//             const SizedBox(width: 10,),
//         ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

