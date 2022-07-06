import 'package:authenticator/redux/auth/auth_state.dart';

class AppState {
  final AuthState auth;

  AppState({required this.auth});

  factory AppState.initial() => AppState(
        auth: AuthState.initialState(),
      );

  @override
  bool operator ==(other) =>
      identical(this, other) ||
      other is AppState && runtimeType == other.runtimeType;

  @override
  // ignore: unnecessary_overrides
  int get hashCode => super.hashCode;

  // @override
  // String toString() {
  //   return "AppState { }";
  // }

  static AppState fromJson(dynamic json) {
    return AppState(
      auth: json == null
          ? AuthState.initialState()
          : AuthState.fromJson(json['auth']),
    );
  }

  // dynamic toJson() => {'auth': auth.toJson(), 'theme': theme.toJson()};

  // AppState.fromJson(json)
  //     : auth = AuthState.fromJson(json['auth']),
  //       theme = ThemeState.fromJson(json['theme']);

  Map<String, dynamic> toJson() => {
        'auth': auth.toJson(),
      };
}
