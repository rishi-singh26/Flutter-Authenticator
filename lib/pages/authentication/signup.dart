import 'package:authenticator/pages/authentication/key_pair.dart';
import 'package:authenticator/shared/functions/regex.dart';
import 'package:flutter/cupertino.dart';

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
  final TextEditingController repeatPasswordController =
      TextEditingController();

  @override
  void initState() {
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

  _onRepeatPasswordSubmit(String repeatPassword) {
    _startSignup();
  }

  _startSignup() {
    String errMessage = '';
    String email = emailController.text;
    String password = passwordController.text;
    String repeatPsswd = repeatPasswordController.text;
    if (!validateEmail(email)) {
      errMessage += 'Enter a valid emaail.';
    }
    if (password.length < 7) {
      errMessage +=
          '${errMessage.isEmpty ? '' : '\n'}Password should have minimum seven cahracters.';
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
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute<Widget>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return KeypairPage(
            email: email,
            password: password,
            // keyPair: rsaKeyPair,
          );
        },
      ),
    );
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: repeatPasswordController,
              placeholder: 'Repeat passeord',
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: repeatPasswordFocusNode,
              onSubmitted: _onRepeatPasswordSubmit,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              autofillHints: const [AutofillHints.newPassword],
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              onPressed: _startSignup,
              child: const Text(
                'Next',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
