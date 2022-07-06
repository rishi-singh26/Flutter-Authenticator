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
    // Clean up the focus node when the Form is disposed.
    emailController.dispose();

    super.dispose();
  }

  _onEmailSubmit(String email) {
    _startPasswordReset();
  }

  _startPasswordReset() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Auth Data'),
        content: Text(
          'Email: ${emailController.text}',
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
        middle: Text('Reset password'),
      ),
      child: ListView(
        children: [
          // Platform.isWindows
          //     ? TopBar(goBack: () {}, isBackBtnDisabled: true)
          //     : const SizedBox(
          //         height: 0.0,
          //       ),
          const SizedBox(height: 40.0),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: CupertinoTextField(
              controller: emailController,
              placeholder: 'Email',
              keyboardType: TextInputType.emailAddress,
              // autofocus: true,
              // focusNode: emailFocusNode,
              onSubmitted: _onEmailSubmit,
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 12.0,
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
                    onPressed: _startPasswordReset,
                    child: Text(
                      'Send password reset link',
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
