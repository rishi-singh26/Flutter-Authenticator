import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

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
      Store<AppState> store = await AppStore.getAppStore();
      String url = urlController.text;
      final Uri uriComponents = Uri.parse(url);
      if (uriComponents.isScheme('otpauth')) {
        String serviceName = uriComponents.queryParameters.containsKey('issuer')
            ? uriComponents.queryParameters['issuer'].toString()
            : '';
        String algorithm =
            uriComponents.queryParameters.containsKey('algorithm')
                ? uriComponents.queryParameters['algorithm'].toString()
                : '';
        String digits = uriComponents.queryParameters.containsKey('digits')
            ? uriComponents.queryParameters['digits'].toString()
            : '';
        String period = uriComponents.queryParameters.containsKey('period')
            ? uriComponents.queryParameters['period'].toString()
            : '';
        String account = uriComponents.pathSegments[0].toString();
        String secret = uriComponents.queryParameters.containsKey('secret')
            ? uriComponents.queryParameters['secret'].toString()
            : '';
        String host = uriComponents.host;

        TotpAccount accntData = TotpAccount(
          createdOn: DateTime.now(),
          data: TotpAccountDetail(
            backupCodes: '',
            host: host,
            issuer: serviceName,
            name: account,
            protocol: uriComponents.scheme,
            secret: secret,
            tags: [],
            url: url,
          ),
          id: '',
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          options: TotpOptions(
            isEnabled: false,
            selectedAlgorithm: algorithm,
            selectedDigitsCount: digits,
            selectedInterval: period,
          ),
          isFavourite: false,
        );
        TotpAccntCryptoResp encryptionResp = accntData.encrypt(
          RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
        );
        if (!encryptionResp.status) {
          // ignore: use_build_context_synchronously
          _showDilogue(
            context,
            'Alert!',
            'Error occured while encrypting account data',
            true,
          );
        }
        FirebaseFirestore.instance
            .collection('newTotpAccounts')
            .add(encryptionResp.data.toApiJson())
            .then(
              (value) =>
                  Navigator.canPop(context) ? Navigator.pop(context) : null,
            );
      } else {
        // ignore: use_build_context_synchronously
        _showDilogue(
          context,
          'Alert!',
          'Enter valid url',
          true,
        );
      }
    } catch (e) {
      _showDilogue(
        context,
        'Alert!',
        e.toString(),
        true,
      );
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
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        style: CupertinoTheme.of(context).textTheme.textStyle,
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
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
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
      ),
    );
  }
}
