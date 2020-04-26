import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import '../controller/pswd_form_controller.dart';

class AnimPswdForm extends StatefulWidget {
  @override
  AnimPswdFormState createState() => AnimPswdFormState();
}

class AnimPswdFormState extends State<AnimPswdForm>
    with SingleTickerProviderStateMixin {
  final _controller = GetIt.I.get<PswdFormController>();
  final TextEditingController _pswdFormController = TextEditingController();
  AnimationController animController;

  @override
  void initState() {
    animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    super.initState();
  }

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

    return AnimatedBuilder(
      animation: offsetAnimation,
      builder: (buildContext, child) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 24.0),
          padding: EdgeInsets.only(
              left: offsetAnimation.value + 24.0,
              right: 24.0 - offsetAnimation.value),
          child: Observer(
            builder: (_) {
              return Column(
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
              );
            },
          ),
        );
      },
    );
  }
}
