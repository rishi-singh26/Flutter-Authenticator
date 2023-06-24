import 'dart:convert';
import 'dart:typed_data';

import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/crypto_service.dart';
import 'package:authenticator/shared/functions/regex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:authenticator/modals/user_modal.dart' as user_modal;
import 'package:flutter_redux/flutter_redux.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late FocusNode emailFocusNode;
  late FocusNode passwordFocusNode;
  late FocusNode repeatPasswordFocusNode;

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController repeatPasswordController = TextEditingController();

  bool showSpinner = false;
  bool doesUnderstand = false;
  late RSAKeypair keyPair;

  @override
  void initState() {
    keyPair = CryptoService.getKeyPair();

    emailFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    repeatPasswordFocusNode = FocusNode();

    fullNameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    repeatPasswordController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    repeatPasswordFocusNode.dispose();

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();

    super.dispose();
  }

  // _onFullNameSubmit(String fullName) {
  //   emailFocusNode.requestFocus();
  // }

  _onEmailSubmit(String email) {
    passwordFocusNode.requestFocus();
  }

  _onPasswordSubmit(String password) {
    repeatPasswordFocusNode.requestFocus();
  }

  _onRepeatPasswordSubmit(BuildContext context, String repeatPassword) {
    _startSignup(context);
  }

  _startSignup(BuildContext context) {
    if (!doesUnderstand) {
      return;
    }
    String errMessage = '';
    String email = emailController.text;
    String password = passwordController.text;
    String repeatPsswd = repeatPasswordController.text;
    if (!validateEmail(email)) {
      errMessage += 'Enter a valid emaail.';
    }
    if (password.length < 7) {
      errMessage += '${errMessage.isEmpty ? '' : '\n'}Password should have minimum seven cahracters.';
    }
    if (password != repeatPsswd) {
      errMessage += "${errMessage.isEmpty ? '' : '\n'}Passwords do not match.";
    }
    if (errMessage.isNotEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Alert!'),
          content: Text(errMessage),
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
    _startLogin(context, email, password);
  }

  void _startLogin(BuildContext context, String email, String password) async {
    setState(() {
      showSpinner = true;
    });
    try {
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final pbkfdSalt = CryptoService.generateRandomSalt();
      final pbkdfKey = CryptoService.generatePBKDF(password, pbkfdSalt);

      final privateKeySalt = CryptoService.generateRandomSalt();
      final encryptedPrivateKey = CryptoService.encrypt(
        pbkdfKey,
        Uint8List.fromList(privateKeySalt.codeUnits),
        Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
      );

      Map<String, dynamic> userData = {
        'userId': user.user!.uid,
        'publicKey': keyPair.publicKey.toFormattedPEM(),
        'email': email,
        'pbkdfSalt': pbkfdSalt,
        'privateKey': const Latin1Codec().decode(encryptedPrivateKey),
        'pvtKeySalt': privateKeySalt,
      };
      await FirebaseFirestore.instance.collection('users').add(userData);

      user_modal.User newUser = user_modal.User.fromJson(userData);
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
    } catch (e) {
      StoreProvider.of<AppState>(context).dispatch(LoginErrAction(errMess: e.toString()));
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Signup Error'),
          content: Text(e.toString()),
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
    }
    setState(() {
      showSpinner = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Signup'),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 40.0),
          Image.asset(
            'images/signup.png',
            width: 220.0,
            height: 220.0,
          ),
          const SizedBox(height: 40.0),
          // Padding(
          //   padding:
          //       const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          //   child: CupertinoTextField(
          //     controller: fullNameController,
          //     placeholder: 'Full name',
          //     padding: const EdgeInsets.symmetric(
          //       vertical: 12.0,
          //       horizontal: 10.0,
          //     ),
          //     onSubmitted: _onFullNameSubmit,
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              // autofocus: true,
              focusNode: emailFocusNode,
              onSubmitted: _onEmailSubmit,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              autofillHints: const [AutofillHints.email],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: passwordController,
              placeholder: 'Password',
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: passwordFocusNode,
              onSubmitted: _onPasswordSubmit,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: repeatPasswordController,
              placeholder: 'Repeat passeord',
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: repeatPasswordFocusNode,
              onSubmitted: (String val) => _onRepeatPasswordSubmit(context, val),
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: RichText(
              textScaleFactor: 0.9,
              text: TextSpan(
                text: '',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'Remember you will ',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'NOT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: "be able to access your account if you forget your ",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'PASSWORD.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '\n\nYou can reset your password but',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: ' NOT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: "without the current password.",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CupertinoButton(
                child: Icon(doesUnderstand ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.check_mark_circled),
                onPressed: () {
                  setState(() {
                    doesUnderstand = !doesUnderstand;
                  });
                },
              ),
              const Text('I Understand'),
            ],
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              onPressed: doesUnderstand ? () => _startSignup(context) : null,
              child: showSpinner
                  ? const CupertinoActivityIndicator()
                  : const Text(
                      'Sign Up',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
