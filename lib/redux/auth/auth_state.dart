import 'package:authenticator/modals/user_modal.dart';

class AuthState {
  final bool isAuthenticated;
  final String errMess;
  final bool isLoading;
  final User userData;

  AuthState({
    required this.isAuthenticated,
    required this.errMess,
    required this.isLoading,
    required this.userData,
  });

  AuthState.fromJson(json)
      : isAuthenticated = json['isAuthenticated'],
        errMess = json['errMess'],
        isLoading = json['isLoading'],
        userData = User.fromJson(json['userData']);

  Map<String, dynamic> toJson() => {
        'isAuthenticated': isAuthenticated,
        'errMess': errMess,
        'isLoading': isLoading,
        'userData': userData.toJson(),
      };

  AuthState.initialState()
      : isAuthenticated = false,
        errMess = '',
        isLoading = false,
        userData = User.defaultValues();

  AuthState.startLogin(AuthState prev)
      : isAuthenticated = prev.isAuthenticated,
        errMess = prev.errMess,
        isLoading = true,
        userData = prev.userData;

  AuthState.login(AuthState prev, User user)
      : isAuthenticated = true,
        errMess = '',
        isLoading = false,
        userData = user;

  AuthState.error(AuthState prev, String err)
      : isAuthenticated = prev.isAuthenticated,
        errMess = err,
        isLoading = false,
        userData = prev.userData;

  AuthState.logout()
      : isAuthenticated = false,
        errMess = '',
        isLoading = false,
        userData = User.defaultValues();
}
