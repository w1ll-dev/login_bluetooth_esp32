import 'package:flutter/material.dart';

import 'login.dart';

void main() => runApp(SismicLogin());

class SismicLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SismicLogin',
      theme: ThemeData(
        fontFamily: "Quebec Black",
        primaryColor: Colors.black,
      ),
      home: Login(),
    );
  }
}
