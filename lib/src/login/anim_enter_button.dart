import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/pswd_form_controller.dart';

import '../data_screen.dart';

class AnimEnterButton extends StatefulWidget {
  final stream;
  final verifyPswd;
  final addPswd;
  AnimEnterButton({
    this.stream,
    this.verifyPswd,
    this.addPswd,
  });
  @override
  _AnimEnterButtonState createState() => _AnimEnterButtonState();
}

class _AnimEnterButtonState extends State<AnimEnterButton>
    with TickerProviderStateMixin {
  final _controller = GetIt.I.get<PswdFormController>();
  bool hideIcon = false;
  AnimationController _ripleController;
  AnimationController _scaleController;

  Animation<double> _ripleAnimation;
  Animation<double> _scaleAnimation;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return DataScreen(
                      stream: widget.stream,
                    );
                  },
                ),
              );
            }
          });

    _ripleController.forward();
  }

  // List<num> _listParser(List<int> dataFromDevice) {
  //   String stringData = utf8.decode(dataFromDevice);
  //   return stringData.split('|').map((e) => num.parse(e)).toList();
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
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
                widget.verifyPswd(pswd: _controller.pswd).then((onValue) {
                  print("PSWD: ${_controller.pswd}\n RESPONSE: $onValue");
                  if (onValue.length > 1) {
                    widget.addPswd();
                    hideIcon = true;
                    _scaleController.forward();
                  } else {
                    print("WRONG PSWD!");
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
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
