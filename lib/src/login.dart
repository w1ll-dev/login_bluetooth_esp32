import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Login extends StatefulWidget {
  final BluetoothDevice device;
  Login({this.device});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  final String TARGET_DEVICE_NAME = "ESP32 GET NOTI FROM DEVICE";
  bool _showPassword = true;
  bool _remenberPassword = true;
  String pswd = '';
  Stream<List<int>> stream;
  bool isReady;
  BluetoothCharacteristic targetCharacteristic;
  String connectionText = "";

  @override
  void initState() {
    super.initState();
    isReady = false;
    connectToDevice();
  }

  connectToDevice() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    Timer(const Duration(seconds: 15), () {
      if (!isReady) {
        disconnectFromDevice();
        _Pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _Pop();
      return;
    }

    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _Pop();
      return;
    }

    List<BluetoothService> servicesSending =
        await widget.device.discoverServices();
    servicesSending.forEach(
      (service) {
        if (service.uuid.toString() == SERVICE_UUID) {
          service.characteristics.forEach(
            (characteristic) {
              if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
                targetCharacteristic = characteristic;
                if (mounted) {
                  setState(
                    () {
                      isReady = true;
                    },
                  );
                }
              }
            },
          );
        }
      },
    );
    List<BluetoothService> servicesReceiving =
        await widget.device.discoverServices();
    servicesReceiving.forEach(
      (service) {
        if (service.uuid.toString() == SERVICE_UUID) {
          service.characteristics.forEach(
            (characteristic) {
              if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
                characteristic.setNotifyValue(!characteristic.isNotifying);
                stream = characteristic.value;
                if (mounted) {
                  setState(
                    () {
                      isReady = true;
                    },
                  );
                }
              }
            },
          );
        }
      },
    );
    if (!isReady) {
      setState(() {
        isReady = false;
      });
      print("disconnected");
      _Pop();
    }
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Are you sure?'),
            content: Container(
              width: 500,
              height: 200,
              child: Text('Do you want to disconnect device and go back?'),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('No')),
              FlatButton(
                onPressed: () {
                  !_remenberPassword ? writeData("Wrong") : false;
                  disconnectFromDevice();
                  Navigator.of(context).pop(true);
                },
                child: Text('Yes'),
              ),
            ],
          ) ??
          false,
    );
  }

  _Pop() {
    Navigator.of(context).pop(true);
  }

  List<num> _listParser(List<int> dataFromDevice) {
    String stringData = utf8.decode(dataFromDevice);
    return stringData.split('|').map((e) => num.parse(e)).toList();
  }

  writeData(String data) {
    if (targetCharacteristic == null) return;

    List<int> bytes = utf8.encode(data);
    targetCharacteristic.write(bytes, withoutResponse: false);
  }

  Widget textField({
    double width,
    double height,
    String label,
  }) =>
      Container(
        width: width,
        height: height,
        child: TextFormField(
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Insert username",
            labelText: label,
          ),
        ),
      );

  Widget pswdFormField({
    double width,
    double height,
  }) =>
      Container(
        width: width,
        height: height,
        child: TextFormField(
          onChanged: (pswdWrited) => pswd = pswdWrited,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Insert passord",
            labelText: "Password",
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
              child: Container(
                child: Icon(
                  _showPassword ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ),
          ),
          obscureText: !_showPassword,
          validator: (String name) => "Insert password",
        ),
      );

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  "assets/images/SBAGUIA.png",
                  width: screen.width / 3,
                  height: screen.width / 3,
                ),
              ),
              pswdFormField(
                width: screen.width / 1.5,
                height: screen.height / 8,
              ),
              FlatButton(
                onPressed: () => writeData(pswd),
                child: Text("Enter"),
              ),
              Text(
                "Remember password",
              ),
              Checkbox(
                value: _remenberPassword,
                onChanged: (value) {
                  setState(() {
                    _remenberPassword = value;
                  });
                },
              ),
              Container(
                child: StreamBuilder<List<int>>(
                  stream: stream,
                  initialData: [0],
                  builder: (c, AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    switch (snapshot.connectionState) {
                      case ConnectionState.active:
                        List<num> arrData = _listParser(snapshot.data);
                        print("Values: $arrData");
                        return Column(
                          children: <Widget>[
                            Center(
                              child: arrData.length == 1
                                  ? Text("Wrong password")
                                  : Text("$arrData"),
                            ),
                          ],
                        );
                        break;
                      case ConnectionState.none:
                        return Container(
                          child: Center(
                            child: Text("${snapshot.connectionState}"),
                          ),
                        );
                        break;
                      default:
                        return Center(
                          child: Text("${snapshot.connectionState}"),
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
