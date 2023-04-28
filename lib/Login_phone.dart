import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:register1/Widgets/Button.dart';
import 'package:register1/verifyphone.dart';
import 'package:register1/utils/utils.dart';


class LoginPhone extends StatefulWidget {
  const LoginPhone({Key? key}) : super(key: key);
  @override
  State<LoginPhone> createState() => _LoginPhoneState();
}

class _LoginPhoneState extends State<LoginPhone> {
  final phone = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            TextFormField(
              controller: phone,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '+91 123 456 789',
              ),
            ),
            SizedBox(height: 80,),
            Button(title: 'Login', onTap: (){
            auth.verifyPhoneNumber(
              phoneNumber: phone.text,
                verificationCompleted: (_){

            },
                verificationFailed: (e){
                Utils().toastMessage(e.toString());
                },
                codeSent: (String verificationId, int? token){
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>
                        VerifyPhone(verificationId: verificationId,)));
                },
                codeAutoRetrievalTimeout: (e) {
                  Utils().toastMessage(e.toString());
                });
            }),
          ],
        ),
      ),
      );
  }
}
