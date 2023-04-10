import 'package:flutter/material.dart';
import 'package:register1/firebase_services/splash_services.dart';


class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  SplashServices splashScreen = SplashServices();
  void initState(){
    super.initState();
    splashScreen.isLogin(context);
  }
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Firebase Tutorials', style: TextStyle(fontSize: 30),),
      ),
    );
  }
}
