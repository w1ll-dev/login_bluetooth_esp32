import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'bluetooth_off.dart';
import 'find_device.dart';

class BluetoothStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SISMIC',
      theme: ThemeData(
        fontFamily: 'Quebec Black',
        primaryColor: Colors.white,
      ),
      home: StreamBuilder<BluetoothState>(
        stream: FlutterBlue.instance.state,
        initialData: BluetoothState.unknown,
        builder: (c, snapshot) {
          final bluetoothState = snapshot.data;
          return bluetoothState == BluetoothState.off
              ? BluetoothOffScreen(state: bluetoothState)
              : FindDevicesScreen();
        },
      ),
    );
  }
}
