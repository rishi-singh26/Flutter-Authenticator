import 'package:authenticator/shared/functions/regex.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    emailController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  _showDialog(BuildContext context, String title, String content,
      {bool error = false, Function()? onPress}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: error,
            onPressed: () {
              Navigator.pop(context);
              onPress != null ? onPress() : null;
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  _startPasswordReset(String email, BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // ignore: use_build_context_synchronously
      _showDialog(
        context,
        'Succes!',
        'Password reset link sent\nMake sure you check you spam box.',
        onPress: () =>
            Navigator.canPop(context) ? Navigator.pop(context) : null,
      );
    } catch (e) {
      _showDialog(context, 'Error!', e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isValidEmail = validateEmail(emailController.text);
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Reset password'),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 40.0),
          Image.asset(
            'images/forgotPass2.png',
            width: 260.0,
            height: 260.0,
          ),
          const SizedBox(height: 40.0),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              onSubmitted: (email) => _startPasswordReset(email, context),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 12.0,
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              onPressed: !isValidEmail
                  ? null
                  : () => _startPasswordReset(emailController.text, context),
              child: const Text(
                'Send password reset link',
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
