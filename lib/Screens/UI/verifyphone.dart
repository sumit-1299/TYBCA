import 'package:flutter/material.dart';

import 'package:flutter/material.dart';


class VerifyPhone extends StatefulWidget {
  final String  verificationId;
  const VerifyPhone({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<VerifyPhone> createState() => _VerifyPhoneState();
}

class _VerifyPhoneState extends State<VerifyPhone> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('VerifyPhone'),
      ),
      body: Column(
        children: [

        ],
      ),
    );
  }
}
