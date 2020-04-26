import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './data_screen.dart';

String _pswdSaved = "Remember pswd";

class StreamFirst extends StatefulWidget {
  final BluetoothDevice device;
  StreamFirst({this.device});
  @override
  _StreamFirstState createState() => _StreamFirstState();
}

class _StreamFirstState extends State<StreamFirst>
    with TickerProviderStateMixin {
  final String SERVICE_UUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String CHARACTERISTIC_UUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  Stream<List<int>> stream;
  bool isReady;
  BluetoothCharacteristic targetCharacteristic;
  List firstList = [];
  SharedPreferences _sp;

  Future<void> _addPswd() async {
    var _sPref = await SharedPreferences.getInstance();
    _sPref.setString("pswd", _pswdSaved);
  }

  Future<void> _getPswd() async {
    _sp = await SharedPreferences.getInstance();
    _pswdSaved = _sp.getString('pswd') ?? "";
  }

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
                if (mounted)
                  setState(() {
                    isReady = true;
                  });
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
                  _sp.remove("pswd");
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

  getFirst({String pswd}) async {
    writeData(pswd);
    first() async {
      await Future.delayed(Duration(milliseconds: 100));
      return await stream.first;
    }

    return first().then((value) {
      setState(() {
        firstList = value;
      });
      return value;
    });
  }

  streamFirst() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text("pswdSaved: $_pswdSaved"),
            ),
            StreamBuilder<List<int>>(
              stream: stream,
              initialData: [],
              builder: (context, snapshot) {
                return Center(
                  child: Text("${_listParser(snapshot.data)}"),
                );
                return Container();
              },
            ),
            Center(
              child: Text("$firstList"),
            ),
            TextFormField(
              onFieldSubmitted: (pswd) {
                getFirst(pswd: pswd).then((onValue) {
                  List responseList = _listParser(onValue);
                  print("$responseList");
                  _pswdSaved = pswd;
                  if (responseList.length == 5) _addPswd();
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => WillPopScope(
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

  @override
  Widget verify(BuildContext context) {
    return _pswdSaved.isEmpty
        ? streamFirst()
        : DataScreen(
            stream: stream,
          );
  }
}
