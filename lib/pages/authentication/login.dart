import 'package:authenticator/modals/user_modal.dart' as user_modal;
import 'package:authenticator/pages/authentication/reset_pass.dart';
import 'package:authenticator/pages/authentication/signup.dart';
import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
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
  // late FocusNode emailFocusNode;
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
    FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) async {
      String userId = value.user!.uid;
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('userId', isEqualTo: userId)
          .get();

      if (users.size < 1) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('Alert!'),
              content: Text(
                  'Error while login\nUser not found\n${users.docs.toString()}'),
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
      );
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(context).dispatch(LoginAction(user: newUser));
    }).catchError((err) {
      StoreProvider.of<AppState>(context)
          .dispatch(LoginErrAction(errMess: err.toString()));
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Login Error'),
          content: Text(err.toString()),
          actions: <CupertinoDialogAction>[
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
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
    });
    setState(() {
      showSpinner = true;
    });
    // Login user with email and password
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      navigationBar:
          const CupertinoNavigationBar(middle: Text('Authenticator')),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              placeholder: 'Password',
              controller: passwordController,
              obscureText: true,
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
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              onPressed: () => _startLogin(context),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 35.0, vertical: 10.0),
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
                    Navigator.push(context, CupertinoPageRoute<Widget>(
                        builder: (BuildContext context) {
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
