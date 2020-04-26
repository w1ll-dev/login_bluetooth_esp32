import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';
import 'package:login/src/bluetooth/find_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controller/pswd_form_controller.dart';
import '../data_screen.dart';
import 'anim_enter_button.dart';
import 'anim_pswd_form.dart';
import 'login_layout.dart';

String _pswdSaved = "Remember pswd";

class NewLogin extends StatefulWidget {
  final BluetoothDevice device;
  NewLogin({this.device});
  @override
  _NewLoginState createState() => _NewLoginState();
}

class _NewLoginState extends State<NewLogin> {
  final _controller = GetIt.I.get<PswdFormController>();
  final _pswdFormController = GetIt.I.get<PswdFormController>();
  static const String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String CHARACTERISTIC_UUID =
      "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  Stream<List<int>> stream;
  bool isReady;
  BluetoothCharacteristic targetCharacteristic;
  SharedPreferences _sp;

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
                stream = characteristic.value.asBroadcastStream();
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

  backToFindDevice(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => FindDevicesScreen(),
      ),
      (route) => false,
    );
  }

  Future<bool> _onWillPop() {
    return showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Are you sure?'),
            content: Container(
              child: Text('Do you want to disconnect device and go back?'),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              FlatButton(
                onPressed: () {
                  _pswdFormController.reset();
                  writeData("Wrong");
                  disconnectFromDevice();
                  backToFindDevice(context);
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

  Future<void> _getPswd() async {
    _sp = await SharedPreferences.getInstance();
    _pswdSaved = _sp.getString('pswd') ?? "";
  }

  Widget _animateLogin() {
    final screen = MediaQuery.of(context).size;
    final image = Image.asset(
      "assets/images/SBAGUIA.png",
      width: screen.width / 3,
      height: screen.width / 3,
    );
    final loginLayout = LoginLayout(
      stream: stream,
      writeData: writeData,
    );

    return Scaffold(
      body: isReady
          ? Center(
              child: Column(
                children: <Widget>[
                  image,
                  loginLayout,
                ],
              ),
            )
          : Center(
              child: Text("connecting..."),
            ),
    );
  }

  Widget verify(BuildContext context) {
    return _pswdSaved.isEmpty
        ? _animateLogin()
        : DataScreen(
            stream: stream,
          );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: !isReady
            ? Center(
                child: Text("SISMIC"),
              )
            : FutureBuilder(
                future: _getPswd(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return verify(context);
                  }
                  return CircularProgressIndicator();
                }),
      ),
    );
  }
}
