import 'package:flutter/material.dart';
import 'package:register1/Login.dart';
import 'package:register1/Widgets/Button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register1/utils/utils.dart';
class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool  loading = false;
  final _form = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
  void Signup()
  {
    setState(() {
      loading = true;
    });
    _auth.createUserWithEmailAndPassword(
        email: emailController.text.toString(),
        password: passwordController.text.toString()).then((value){
      setState(() {
        loading = false;
      });
    }).onError((error, stackTrace){
      Utils().toastMessage(error.toString());
      setState(() {
        loading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Form(
              key: _form,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController ,
                    decoration:const InputDecoration(
                      hintText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email),
                    ),
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter email';
                      }
                      else
                      {
                        return null;
                      }
                    },
                    //  validator: (value) {
                    //    RegExp regex =
                    //    RegExp(r'^\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,3}$');
                    //    if (!regex.hasMatch(value!)) {
                    //      return "Invaild Email";
                    //    } else
                    //      return null;
                    //  },
                    //  onSaved: (value) {
                    //    emailController = value!;
                    //  },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: passwordController,
                    obscureText: true,
                    decoration:const InputDecoration(
                      hintText: 'Password',
                      prefixIcon: Icon(Icons.lock_open),
                    ),
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter password';
                      }
                      else
                      {
                        return null;
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50,),
            Button(title: 'Signup',
              loading: loading,
              onTap: (){
                if(_form.currentState!.validate()){
                  Signup();
                }
              },
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account"),
                TextButton(onPressed: (){
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => Login()));
                },
                    child: Text('Login'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
