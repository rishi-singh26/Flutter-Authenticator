import 'package:authenticator/redux/store/app.reducer.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:redux/redux.dart';
import 'package:redux_persist/redux_persist.dart';
import 'package:redux_persist_flutter/redux_persist_flutter.dart';

class AppStore {
  static Future<Store<AppState>> getAppStore() async {
    final persistor = Persistor<AppState>(
      storage: FlutterStorage(
        location: FlutterSaveLocation.sharedPreferences,
        key: 'encrypto_root',
      ), // Or use other engines
      serializer: JsonSerializer<AppState>(
        AppState.fromJson,
      ), // Or use other serializers
    );

    // Load initial state
    final initialState = await persistor.load();
    // Create store
    Store<AppState> store = Store<AppState>(
      appReducer,
      initialState: initialState ?? AppState.initial(),
      middleware: [
        persistor.createMiddleware(),
      ],
    );

    return store;
  }
}
