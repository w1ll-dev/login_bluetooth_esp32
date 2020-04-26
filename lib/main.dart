import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:login/src/bluetooth/bluetooth_status.dart';

import 'src/controller/pswd_form_controller.dart';

void main() {
  GetIt getIt = GetIt.I;
  getIt.registerSingleton<PswdFormController>(PswdFormController());
  runApp(SismicLogin());
}

class SismicLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SismicLogin',
      theme: ThemeData(
        fontFamily: "Quebec Black",
        primaryColor: Colors.white,
      ),
      home: BluetoothStatus(),
    );
  }
}
