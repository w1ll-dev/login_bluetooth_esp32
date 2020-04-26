import 'package:mobx/mobx.dart';
part 'pswd_form_controller.g.dart';

class PswdFormController = _PswdFormControllerBase with _$PswdFormController;

abstract class _PswdFormControllerBase with Store {
  @observable
  String pswd = '';
  @observable
  bool validPswd = false;
  @observable
  bool rememberPswd = false;
  @observable
  bool showPswd = false;
  @observable
  int contWrongPswd = 0;

  @action
  void changePswd({String newPswd}) => pswd = newPswd;
  @action
  void changeValidPswd({bool validPswdState}) => validPswd = validPswdState;
  @action
  void changeRememberPswd() => rememberPswd = !rememberPswd;
  @action
  void changeShowPswd() => showPswd = !showPswd;
  @action
  void changeContWrongPswd() => contWrongPswd++;

  @action
  void reset() {
    pswd = '';
    showPswd = false;
    validPswd = false;
    contWrongPswd = 0;
  }
}
