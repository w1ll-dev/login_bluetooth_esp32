import 'dart:convert';

import 'package:flutter/material.dart';

class StreamData extends StatelessWidget {
  final Stream<List<int>> stream;
  StreamData({this.stream});

  List<num> _listParser(List<int> dataFromDevice) {
    String stringData = utf8.decode(dataFromDevice);
    return stringData.split('|').map((e) => num.parse(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<int>>(
        stream: stream,
        initialData: [],
        builder: (c, AsyncSnapshot<List<int>> snapshot) {
          // print("CONNECTION STATE: ${snapshot.connectionState}");
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.data.isEmpty == false) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                List<num> arrData = _listParser(snapshot.data);
                return Center(
                  child: Text("$arrData"),
                );
                break;
              case ConnectionState.none:
                return Container(
                  child: Center(
                    child: Text("bluetooth disconected"),
                  ),
                );
                break;
              default:
                return Center(
                  child: Text("${snapshot.connectionState}"),
                );
            }
          } else {
            return Center(
              child: Text("${snapshot.connectionState}"),
            );
          }
        },
      ),
    );
  }
}
