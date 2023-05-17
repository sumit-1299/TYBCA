import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' ;
import 'package:google_fonts/google_fonts.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'Home.dart';
import 'Login.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  //Firebase Initialization
  await Firebase.initializeApp();
  //MongoDB Initialization
  Db _db = Db("mongodb://accman:password@3.106.137.118:27017/khata?directConnection=true&appName=mongosh+1.8.0");
  await _db.open().then((value) {
    print("connection Successful");
    return value;
  }).catchError((error) {
    print("Error: ${error.toString()}");
  });

  runApp(
      MaterialApp(
    theme: ThemeData(
      appBarTheme: AppBarTheme(
        color: const Color(0xff141415),
        elevation: 0,
        titleTextStyle: GoogleFonts.roboto(color: const Color(0xffffffff), fontWeight: FontWeight.w300,fontSize: 20),
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      scaffoldBackgroundColor: Color(0xff141415),
      textTheme: TextTheme(
        titleLarge: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        ),
        titleMedium: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        ),
        titleSmall: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        ),
        bodyLarge: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        ),
        bodyMedium: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        ),
        bodySmall: GoogleFonts.roboto(
            color: const Color(0xffffffff),
            fontWeight: FontWeight.w300
        )
      ).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white
      ),

        colorScheme: ColorScheme.fromSwatch().copyWith(primary: Colors.white,secondary: Colors.white)
    ),
    debugShowCheckedModeBanner: false,
    home: FirebaseAuth.instance.currentUser!=null?Home(db: _db):Login(db: _db),
  ));
}




