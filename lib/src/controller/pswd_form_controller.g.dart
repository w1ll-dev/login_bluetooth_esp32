// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pswd_form_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$PswdFormController on _PswdFormControllerBase, Store {
  final _$pswdAtom = Atom(name: '_PswdFormControllerBase.pswd');

  @override
  String get pswd {
    _$pswdAtom.context.enforceReadPolicy(_$pswdAtom);
    _$pswdAtom.reportObserved();
    return super.pswd;
  }

  @override
  set pswd(String value) {
    _$pswdAtom.context.conditionallyRunInAction(() {
      super.pswd = value;
      _$pswdAtom.reportChanged();
    }, _$pswdAtom, name: '${_$pswdAtom.name}_set');
  }

  final _$validPswdAtom = Atom(name: '_PswdFormControllerBase.validPswd');

  @override
  bool get validPswd {
    _$validPswdAtom.context.enforceReadPolicy(_$validPswdAtom);
    _$validPswdAtom.reportObserved();
    return super.validPswd;
  }

  @override
  set validPswd(bool value) {
    _$validPswdAtom.context.conditionallyRunInAction(() {
      super.validPswd = value;
      _$validPswdAtom.reportChanged();
    }, _$validPswdAtom, name: '${_$validPswdAtom.name}_set');
  }

  final _$rememberPswdAtom = Atom(name: '_PswdFormControllerBase.rememberPswd');

  @override
  bool get rememberPswd {
    _$rememberPswdAtom.context.enforceReadPolicy(_$rememberPswdAtom);
    _$rememberPswdAtom.reportObserved();
    return super.rememberPswd;
  }

  @override
  set rememberPswd(bool value) {
    _$rememberPswdAtom.context.conditionallyRunInAction(() {
      super.rememberPswd = value;
      _$rememberPswdAtom.reportChanged();
    }, _$rememberPswdAtom, name: '${_$rememberPswdAtom.name}_set');
  }

  final _$showPswdAtom = Atom(name: '_PswdFormControllerBase.showPswd');

  @override
  bool get showPswd {
    _$showPswdAtom.context.enforceReadPolicy(_$showPswdAtom);
    _$showPswdAtom.reportObserved();
    return super.showPswd;
  }

  @override
  set showPswd(bool value) {
    _$showPswdAtom.context.conditionallyRunInAction(() {
      super.showPswd = value;
      _$showPswdAtom.reportChanged();
    }, _$showPswdAtom, name: '${_$showPswdAtom.name}_set');
  }

  final _$contWrongPswdAtom =
      Atom(name: '_PswdFormControllerBase.contWrongPswd');

  @override
  int get contWrongPswd {
    _$contWrongPswdAtom.context.enforceReadPolicy(_$contWrongPswdAtom);
    _$contWrongPswdAtom.reportObserved();
    return super.contWrongPswd;
  }

  @override
  set contWrongPswd(int value) {
    _$contWrongPswdAtom.context.conditionallyRunInAction(() {
      super.contWrongPswd = value;
      _$contWrongPswdAtom.reportChanged();
    }, _$contWrongPswdAtom, name: '${_$contWrongPswdAtom.name}_set');
  }

  final _$_PswdFormControllerBaseActionController =
      ActionController(name: '_PswdFormControllerBase');

  @override
  void changePswd({String newPswd}) {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.changePswd(newPswd: newPswd);
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeValidPswd({bool validPswdState}) {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.changeValidPswd(validPswdState: validPswdState);
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeRememberPswd() {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.changeRememberPswd();
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeShowPswd() {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.changeShowPswd();
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void changeContWrongPswd() {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.changeContWrongPswd();
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo =
        _$_PswdFormControllerBaseActionController.startAction();
    try {
      return super.reset();
    } finally {
      _$_PswdFormControllerBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    final string =
        'pswd: ${pswd.toString()},validPswd: ${validPswd.toString()},rememberPswd: ${rememberPswd.toString()},showPswd: ${showPswd.toString()},contWrongPswd: ${contWrongPswd.toString()}';
    return '{$string}';
  }
}
