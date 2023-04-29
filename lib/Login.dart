import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:register1/Home.dart';
import 'package:register1/Login_phone.dart';
import 'package:register1/Signup.dart';
import 'package:register1/Widgets/Button.dart';
class Login extends StatefulWidget {
  Login({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _form = GlobalKey<FormState>();
  String email='nigam123@gmail.com', password='1234567890';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Login'),
        ),
        body: Padding(
           padding: const EdgeInsets.symmetric(horizontal: 20),
          // padding:const EdgeInsets.only(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      // controller: emailController,
                      decoration:const InputDecoration(
                        hintText: 'Email',
                        prefixIcon: Icon(Icons.alternate_email),

                      ),
                     initialValue: "nigam123@gmail.com",
                     validator: (value){
                        if(value!.isEmpty){
                          return 'Enter email';
                        }
                        else
                          {
                            return null;
                          }
                     },
                      onSaved: (value){
                        email = value!;
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
                      // controller: passwordController,
                      obscureText: true,
                      decoration:const InputDecoration(
                        hintText: 'Password',
                        prefixIcon: Icon(Icons.lock_open),
                      ),
                      initialValue: "1234567890",
                      validator: (value){
                        if(value!.isEmpty){
                          return 'Enter password';
                        }
                        else
                        {
                          return null;
                        }
                      },
                      onSaved: (value){
                        password = value!;
                      },
                    ),
                  ],
                ),
              ),
             const SizedBox(height: 50,),
              Button(title: 'Login',
              onTap: () async{
                if(_form.currentState!.validate()){
                  _form.currentState?.save();
                   await FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: email,
                        password: password).then((value){
                          // Utils().toastMessage(value.user!.toString());
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful"),));
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Home(db: widget.db,))
                          );
                });
                      }
              },
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account"),
                  TextButton(onPressed: (){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Signup()));
                  },
                      child: const Text('Sign up'))
                ],
              ),
               const SizedBox(height: 10,),
              // InkWell(
              //   onTap: (){
              //
              //   },
              // ),
              GestureDetector(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPhone()));
                },
                child:Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.black
                  )
                ),
                  child: const Center(
                   child: Text('Login with phone number'),
                ),
              ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
