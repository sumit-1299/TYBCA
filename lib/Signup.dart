import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:register1/Login.dart';
import 'package:register1/Widgets/Button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:register1/utils/utils.dart';
import 'package:mongo_dart/mongo_dart.dart' as Mongo;
import 'package:string_validator/string_validator.dart';

import 'Home.dart';

class Signup extends StatefulWidget {
  Signup({Key? key, required this.db}) : super(key: key);

  Mongo.Db db;
  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool  loading = false;
  final _form = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final unameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }
  void Signup() async {
    await _auth.createUserWithEmailAndPassword(
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
    await _auth.currentUser?.updateDisplayName(unameController.text.toString()).onError((error, stackTrace) {
      print("error: $error");
      print("stackTrace: $stackTrace");
    });
    await widget.db.collection('test').insert({
      "_id":_auth.currentUser?.uid,
      "${_auth.currentUser?.displayName}" : {
        "Parties" : {},
        "People" : {},
        "Items" : [],
        "PNames" : [],
        "Transactions" : {}
      }
    }).then((value){
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context)=>Home(db: widget.db)));
    });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text("Create Account", style: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 40,)),
                  const SizedBox(height: 40,),
                  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: unameController,
                    decoration: InputDecoration(
                      hintText: 'Username',
                      hintStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
                      prefixIcon: const Icon(Icons.person, color: Colors.white,),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white
                          )
                      ),
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey
                          )
                      ),
                      enabledBorder:const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                    ),
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter Username';
                      }
                      else
                      {
                        return null;
                      }
                    },
                  ),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: emailController ,
                    decoration: InputDecoration(
                      hintText: 'Email',
                      hintStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
                      prefixIcon: const Icon(Icons.alternate_email,color: Colors.white,),
                        focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.white
                            )
                        ),
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey
                          )
                      ),
                      enabledBorder:const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
                    ),
                    validator: (value){
                      if(value!.isEmpty){
                        return 'Enter email';
                      }
                      else if(!isEmail(value)){
                        return 'Invalid Email';
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
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300),
                      prefixIcon: const Icon(Icons.lock_open, color: Colors.white,),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.white
                          )
                      ),
                      border: const UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.grey
                          )
                      ),
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.grey,
                          )
                      ),
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
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color(0xff5d5f64)),
              ),

              child: Padding(
                  padding: EdgeInsets.only(left: MediaQuery.of(context).size.width/3,right: MediaQuery.of(context).size.width/3),
                  child: const Text("Signup",style: TextStyle(color: Colors.white))
              ),
              onPressed: (){
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
                const Text("Already have an account"),
                TextButton(onPressed: (){
                  // Navigator.push(context,
                  //     MaterialPageRoute(builder: (context) => Login()));
                  Navigator.pop(context);
                },
                    child: const Text('Login'))
              ],
            )
          ],
        ),
      ),
    );
  }
}
