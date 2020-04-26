import 'package:flutter/material.dart';

class DataScreen extends StatelessWidget {
  final Stream<List<int>> stream;
  DataScreen({
    this.stream,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.active:
                return Text("${snapshot.data}");
                break;
              default:
              // return CircularProgressIndicator();
            }
            return Container();
          },
        ),
      ),
    );
  }
}
