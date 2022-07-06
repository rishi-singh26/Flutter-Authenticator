import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/auth/auth_state.dart';
import 'package:redux/redux.dart';

Reducer<AuthState> authReducers =
    combineReducers([loginReducer, logoutReducer]);

// Login
AuthState loginReducer(AuthState prevState, dynamic action) {
  AuthState.startLogin(prevState);
  if (action is LoginAction) {
    return AuthState.login(prevState, action.user);
  }

  return prevState;
}

// Auth Error
AuthState loginErrReducer(AuthState prevState, dynamic action) {
  if (action is LoginErrAction) {
    return AuthState.error(prevState, action.errMess);
  }

  return prevState;
}

// Logout
AuthState logoutReducer(AuthState prevState, dynamic action) {
  AuthState.startLogin(prevState);
  if (action is LogoutAction) {
    return AuthState.logout();
  }

  return prevState;
}
