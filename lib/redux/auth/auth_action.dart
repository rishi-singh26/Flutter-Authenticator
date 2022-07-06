import 'package:authenticator/modals/user_modal.dart';

abstract class AuthAction {}

class LoginStartAction extends AuthAction {}

class LoginAction extends AuthAction {
  final User user;

  LoginAction({required this.user});
}

class LoginErrAction extends AuthAction {
  final String errMess;

  LoginErrAction({required this.errMess});
}

class LogoutAction extends AuthAction {}
