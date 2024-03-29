import 'dart:convert';
import 'dart:typed_data';

import 'package:authenticator/modals/user_modal.dart' as user_modal;
import 'package:authenticator/pages/authentication/reset_pass.dart';
import 'package:authenticator/pages/authentication/signup.dart';
import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/crypto_service.dart';
import 'package:authenticator/shared/functions/regex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Login extends StatefulWidget {
  // final PageController controller;
  const Login({
    Key? key,
    // required this.controller,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool hidePassword = true;
  _setHidePass(bool val) => setState(() => hidePassword = val);
  late FocusNode passwordFocusNode;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showSpinner = false;

  @override
  void initState() {
    // emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();

    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    // emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  _onEmailSubmit(String email) {
    passwordFocusNode.requestFocus();
  }

  showDilogue(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                FirebaseAuth.instance.signOut();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _startLogin(BuildContext context) async {
    String email = emailController.text;
    String password = passwordController.text;
    if (!validateEmail(email)) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: const Text('Enter a valid email.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    if (password.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: const Text('Enter your password.'),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        ),
      );
      return;
    }
    setState(() {
      showSpinner = true;
    });

    try {
      UserCredential value = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

      String userId = value.user!.uid;
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore.instance.collection('users').where('userId', isEqualTo: userId).get();

      if (users.size < 1) {
        showDilogue('Error while login\nUser not found\n${users.docs.toString()}');
        setState(() {
          showSpinner = false;
        });
        return;
      }
      Map<String, dynamic> user = users.docs[0].data();
      user_modal.User newUser = user_modal.User(
        email: value.user!.email ?? '',
        publicKey: user['publicKey'],
        userId: userId,
        pbkdfSalt: user['pbkdfSalt'],
        privateKey: user['privateKey'],
        pvtKeySalt: user['pvtKeySalt'],
      );
      final pbkdfKey = CryptoService.generatePBKDF(password, newUser.pbkdfSalt);
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(context).dispatch(AttachKeyAction(
        key: const Latin1Codec().decode(CryptoService.decrypt(
          pbkdfKey,
          Uint8List.fromList(const Latin1Codec().encode(newUser.pvtKeySalt)),
          Uint8List.fromList(const Latin1Codec().encode(newUser.privateKey)),
        )),
      ));
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(context).dispatch(LoginAction(user: newUser));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDilogue('No user found for that email.');
        setState(() {
          showSpinner = false;
        });
      } else if (e.code == 'wrong-password') {
        showDilogue('Wrong password provided for that user.');
        setState(() {
          showSpinner = false;
        });
      }
    } catch (e) {
      StoreProvider.of<AppState>(context).dispatch(LoginErrAction(errMess: e.toString()));
      showDilogue(e.toString());

      setState(() {
        showSpinner = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      navigationBar: const CupertinoNavigationBar(middle: Text('Authenticator')),
      child: ListView(
        children: [
          const SizedBox(height: 20.0),
          Image.asset(
            'images/login.png',
            width: 250.0,
            height: 250.0,
          ),
          const SizedBox(height: 20.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              placeholder: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              onSubmitted: _onEmailSubmit,
              readOnly: showSpinner,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              placeholder: 'Password',
              controller: passwordController,
              obscureText: hidePassword,
              readOnly: showSpinner,
              // keyboardType: TextInputType.none,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: passwordFocusNode,
              onSubmitted: (pass) => _startLogin(context),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              suffix: CupertinoButton(
                padding: EdgeInsets.zero,
                child: Icon(
                  hidePassword ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                  color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
                  size: 20,
                ),
                onPressed: () => _setHidePass(!hidePassword),
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              disabledColor: CupertinoColors.systemBlue,
              onPressed: showSpinner ? null : () => _startLogin(context),
              child: showSpinner
                  ? const CupertinoActivityIndicator()
                  : const Text(
                      'Login',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CupertinoButton(
                  onPressed: () {
                    // widget.controller.animateToPage(
                    //   1,
                    //   duration: const Duration(milliseconds: 300),
                    //   curve: Curves.easeIn,
                    // );
                    Navigator.push(
                      context,
                      CupertinoPageRoute<void>(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return const SignUp();
                        },
                      ),
                    );
                  },
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                CupertinoButton(
                  onPressed: () {
                    // widget.controller.animateToPage(
                    //   2,
                    //   duration: const Duration(milliseconds: 300),
                    //   curve: Curves.easeIn,
                    // );
                    Navigator.push(context, CupertinoPageRoute<Widget>(builder: (BuildContext context) {
                      return const ResetPassword();
                    }));
                  },
                  child: const Text(
                    'Reset Password',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
