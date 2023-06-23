import 'package:flutter/cupertino.dart';
// Components
import 'package:authenticator/pages/authentication/login.dart';
import 'package:authenticator/pages/home/main.dart';
// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:authenticator/firebase_options.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Redux
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:redux/redux.dart';
import 'package:flutter_redux/flutter_redux.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );
  runApp(MyApp(store: await AppStore.getAppStore()));
}

class MyApp extends StatefulWidget {
  final Store<AppState> store;
  const MyApp({Key? key, required this.store}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        setState(() {
          _isLoggedIn = false;
        });
        // print('User is currently signed out!');
      } else {
        setState(() {
          _isLoggedIn = true;
        });
        // print('User is signed in!');
      }
    });
    super.initState();
  }

  bool _isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: widget.store,
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) => CupertinoApp(
          title: 'Authenticator',
          home: _isLoggedIn && state.auth.isAuthenticated
              ? const MyHomePage()
              : const Login(),
        ),
      ),
    );
  }
}
