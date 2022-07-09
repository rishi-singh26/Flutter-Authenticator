import 'package:authenticator/redux/auth/reducers.dart';
import 'package:authenticator/redux/pvKey/reducers.dart';
import './app.state.dart';

AppState appReducer(AppState state, action) => AppState(
      auth: authReducers(state.auth, action),
      pvKey: privateKeyReducers(state.pvKey, action),
    );
