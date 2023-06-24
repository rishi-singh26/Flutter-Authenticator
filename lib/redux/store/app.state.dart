import 'package:authenticator/redux/auth/auth_state.dart';
import 'package:authenticator/redux/pvKey/pv_key_state.dart';

class AppState {
  final AuthState auth;
  final PrivateKeyState pvKey;

  AppState({
    required this.auth,
    required this.pvKey,
  });

  factory AppState.initial() => AppState(
        auth: AuthState.initialState(),
        pvKey: PrivateKeyState.initialState(),
      );

  @override
  bool operator ==(other) => identical(this, other) || other is AppState && runtimeType == other.runtimeType;

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  // @override
  // String toString() {
  //   return "AppState { }";
  // }

  static AppState fromJson(dynamic json) {
    return AppState(
      auth: json == null ? AuthState.initialState() : AuthState.fromJson(json['auth']),
      pvKey: json == null ? PrivateKeyState.initialState() : PrivateKeyState.fromJson(json['pvKey']),
    );
  }

  // dynamic toJson() => {'auth': auth.toJson(), 'theme': theme.toJson()};

  // AppState.fromJson(json)
  //     : auth = AuthState.fromJson(json['auth']),
  //       theme = ThemeState.fromJson(json['theme']);

  Map<String, dynamic> toJson() => {
        'auth': auth.toJson(),
        'pvKey': pvKey.toJson(),
      };
}
