// ignore_for_file: use_build_context_synchronously

import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/pages/scanner/functions.dart';
import 'package:flutter/cupertino.dart';

class EnterUrl extends StatefulWidget {
  const EnterUrl({Key? key}) : super(key: key);

  @override
  State<EnterUrl> createState() => _EnterUrlState();
}

class _EnterUrlState extends State<EnterUrl> {
  late TextEditingController urlController;

  @override
  void initState() {
    urlController = TextEditingController();
    super.initState();
  }

  _showDilogue(
    BuildContext context,
    String title,
    String content,
    bool isDestructive,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  _onSubmit(BuildContext context) async {
    try {
      String url = urlController.text;
      final Uri uriComponents = Uri.parse(url);
      if (uriComponents.isScheme('otpauth')) {
        AddAccountResp addAccountResp = await addAccountToFirebase(
          url,
          uriComponents,
          () => null,
        );
        if (!addAccountResp.status) {
          _showDilogue(context, 'Alert!', addAccountResp.message, true);
          return;
        }
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      } else {
        _showDilogue(context, 'Alert!', 'Enter valid url', true);
        return;
      }
    } catch (e) {
      _showDilogue(context, 'Alert!', e.toString(), true);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              border: null,
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerLeft,
                child: const Text('Cancel'),
              ),
              largeTitle: const Text('From URL'),
            ),
          ];
        }),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius: const BorderRadius.all(Radius.circular(9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 6.0, top: 4.0),
                          child: Text(
                            'URL',
                            style:
                                CupertinoTheme.of(context).textTheme.textStyle,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: CupertinoTextField(
                            controller: urlController,
                            placeholder: 'ex.: otpauth://',
                            decoration: const BoxDecoration(
                              border: null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'You can save your Two-Factor Authentication (2FA) codes by entering the full URL. Please note, the URL should start with otpauth://. This feature can be very usefull if you want to transfer your Two-Factor Authentication codes from the password manager.',
                      style: TextStyle(
                        color: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle
                            .color,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: CupertinoButton.filled(
                      child: const Text(
                        'Continue',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (urlController.text.isEmpty) {
                          return;
                        }
                        _onSubmit(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: BottomButtons(currentPage: 2),
            ),
          ],
        ),
      ),
    );
  }
}
