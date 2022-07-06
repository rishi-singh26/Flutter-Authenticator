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

  bool _hidePassword = true;

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

  _onFullNameSubmit(String fullName) {
    emailFocusNode.requestFocus();
  }

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
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Auth Data'),
        content: Text(
          'Email: ${emailController.text}\nPassword: ${passwordController.text}',
        ),
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
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Signup'),
      ),
      child: ListView(
        children: [
          const SizedBox(height: 40.0),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: fullNameController,
              placeholder: 'Full name',
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
              onSubmitted: _onFullNameSubmit,
            ),
          ),
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
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: passwordController,
              placeholder: 'Password',
              obscureText: _hidePassword,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: passwordFocusNode,
              onSubmitted: _onPasswordSubmit,
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
              controller: repeatPasswordController,
              placeholder: 'Repeat passeord',
              obscureText: _hidePassword,
              autocorrect: false,
              enableSuggestions: false,
              focusNode: repeatPasswordFocusNode,
              onSubmitted: _onRepeatPasswordSubmit,
              padding: const EdgeInsets.symmetric(
                vertical: 12.0,
                horizontal: 10.0,
              ),
            ),
          ),
          const SizedBox(height: 30.0),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: CupertinoButton.filled(
                    onPressed: _startSignup,
                    child: Text(
                      'Sign Up',
                      style:
                          CupertinoTheme.of(context).textTheme.pickerTextStyle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
