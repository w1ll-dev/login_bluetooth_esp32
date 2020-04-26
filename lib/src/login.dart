import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:login/src/data_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

String pswdSaved = "Pswd Saved";

class Login extends StatefulWidget {
  final BluetoothDevice device;
  Login({this.device});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool _showPassword = true;
  bool _remenberPassword = true;
  Stream<List<int>> stream;
  bool isReady;
  BluetoothCharacteristic targetCharacteristic;
  String pswd = '';
  List listToVerify = [];

  AnimationController _ripleController;
  AnimationController _scaleController;

  Animation<double> _ripleAnimation;
  Animation<double> _scaleAnimation;

  bool okPswd = false;
  bool hideIcon = false;
  Color buttonColor = Colors.blue;

  List<int> showData = [];

  addPswd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("pswd", pswdSaved);
  }

  getPswd() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    pswdSaved = prefs.getString('pswd') ?? "";
  }

  @override
  void initState() {
    super.initState();
    _ripleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _ripleAnimation =
        Tween<double>(begin: 80.0, end: 90.0).animate(_ripleController);

    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 30.0).animate(_scaleController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              disconnectFromDevice();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DataScreen(
                      stream: stream,
                    );
                  },
                ),
              );
            }
          });

    _ripleController.forward();

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
                if (mounted) isReady = true;
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

  Widget pswdFormField() => TextFormField(
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
      );

  animateLogin() {
    Size screen = MediaQuery.of(context).size;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("PSWD SAVED: $pswdSaved"),
          Center(
            child: Image.asset(
              "assets/images/SBAGUIA.png",
              width: screen.width / 3,
              height: screen.width / 3,
            ),
          ),
          pswdFormField(),
          Center(
            child: AnimatedBuilder(
              animation: _ripleController,
              builder: (context, child) => Container(
                width: _ripleAnimation.value,
                height: _ripleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.5),
                  ),
                  child: InkWell(
                    onTap: () {
                      pswdSaved = pswd;
                      verifyPswd(pswd: pswd).then((onValue) {
                        List responseList = _listParser(onValue);
                        print("$responseList");
                        if (responseList.length == 5) {
                          addPswd();
                          hideIcon = true;
                          _scaleController.forward();
                        }
                      });
                    },
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Container(
                          child: Icon(
                            hideIcon ? null : Icons.keyboard_arrow_right,
                            size: 60,
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: buttonColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget verify(BuildContext context) {
    return pswdSaved.isEmpty
        ? animateLogin()
        : DataScreen(
            stream: stream,
          );
  }

  verifyPswd({String pswd}) async {
    writeData(pswd);
    first() async {
      Future.delayed(Duration(seconds: 1));
      return await stream.first;
    }

    return first().then((value) {
      setState(() {
        listToVerify = value;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          body: !isReady
              ? Center(
                  child: Text("SISMIC"),
                )
              : FutureBuilder(
                  future: getPswd(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return verify(context);
                    }
                    return CircularProgressIndicator();
                  }),
        ),
      );
}
