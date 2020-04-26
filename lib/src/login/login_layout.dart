import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controller/pswd_form_controller.dart';

import '../data_screen.dart';

String _pswdSaved = "Remember pswd";

class LoginLayout extends StatefulWidget {
  final stream;
  final writeData;

  LoginLayout({
    this.stream,
    this.writeData,
  });
  @override
  _LoginLayoutState createState() => _LoginLayoutState();
}

class _LoginLayoutState extends State<LoginLayout>
    with TickerProviderStateMixin {
  final _controller = GetIt.I.get<PswdFormController>();
  SharedPreferences _sp;
  bool hideIcon = false;
  final TextEditingController _pswdFormController = TextEditingController();
  AnimationController animController;
  AnimationController _ripleController;
  AnimationController _scaleController;

  Animation<double> _ripleAnimation;
  Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

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

  Future<void> _addPswd() async {
    var _sPref = await SharedPreferences.getInstance();
    _sPref.setString("pswd", _pswdSaved);
  }

  Future<List> verifyPswd({String pswd}) async {
    widget.writeData(pswd);
    first() async {
      Future.delayed(Duration(seconds: 2));
      return await widget.stream.first;
    }

    return first().then((value) {
      if (value.length > 1) _controller.changeValidPswd(validPswdState: true);
      return value;
    });
  }
  // List<num> _listParser(List<int> dataFromDevice) {
  //   String stringData = utf8.decode(dataFromDevice);
  //   return stringData.split('|').map((e) => num.parse(e)).toList();
  // }

  @override
  Widget build(BuildContext context) {
    final Animation<double> offsetAnimation = Tween(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(animController)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              animController.reverse();
            }
          });
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: offsetAnimation,
          builder: (buildContext, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              padding: EdgeInsets.only(
                  left: offsetAnimation.value + 24.0,
                  right: 24.0 - offsetAnimation.value),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    onFieldSubmitted: (pswdSubmited) =>
                        animController.forward(),
                    controller: _pswdFormController,
                    onChanged: (pswdWrited) =>
                        _controller.changePswd(newPswd: pswdWrited),
                    autofocus: true,
                    decoration: InputDecoration(
                      errorText:
                          _controller.validPswd ? null : "wrong password",
                      border: OutlineInputBorder(),
                      hintText: "Insert passord",
                      labelText: "Password",
                      suffixIcon: GestureDetector(
                        onTap: () {
                          _controller.changeShowPswd();
                        },
                        child: Container(
                          child: Icon(
                            _controller.showPswd
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                        ),
                      ),
                    ),
                    obscureText: !_controller.showPswd,
                    validator: (String name) => "Insert password",
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("REMEMBER PASSWORD"),
                      Checkbox(
                        value: _controller.rememberPswd,
                        onChanged: (value) => _controller.changeRememberPswd(),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        ),
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
                    verifyPswd(pswd: _controller.pswd).then((onValue) {
                      print("PSWD: ${_controller.pswd}\n RESPONSE: $onValue");
                      if (onValue.length > 1) {
                        _addPswd();
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
        ),
      ],
    );
  }
}
