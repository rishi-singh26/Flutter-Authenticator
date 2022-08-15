import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:otpauth_migration/otpauth_migration.dart';
import 'package:redux/redux.dart';

class SelectAccounts extends StatefulWidget {
  final String scanResult;
  const SelectAccounts({Key? key, required this.scanResult}) : super(key: key);

  @override
  State<SelectAccounts> createState() => _SelectAccountsState();
}

class _SelectAccountsState extends State<SelectAccounts> {
  TextStyle stepsStyle(BuildContext context) => CupertinoTheme.of(context)
      .textTheme
      .tabLabelTextStyle
      .copyWith(fontSize: 14);

  List<TotpAccount> accounts = [];
  List<int> unSelectedAccountIndices = [];

  @override
  void initState() {
    _decode(widget.scanResult);
    super.initState();
  }

  _showDilogue(
      BuildContext context, String title, String content, Function onPress) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(
            title,
            style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
          ),
          content: Text(
            content,
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
                onPress();
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
  }

  _decode(String migrationUri) async {
    try {
      final OtpAuthMigration otpAuthParser = OtpAuthMigration();
      final String decodedUri = Uri.decodeComponent(migrationUri);
      print(decodedUri);
      List<String> accountsURIs = otpAuthParser.decode(decodedUri);
      print(accountsURIs);
      Store<AppState> store = await AppStore.getAppStore();

      for (String accountUri in accountsURIs) {
        final Uri uriComponents = Uri.parse(accountUri);
        String issuer = uriComponents.queryParameters.containsKey('issuer')
            ? uriComponents.queryParameters['issuer'].toString()
            : '';
        String host = uriComponents.host;
        String name = uriComponents.pathSegments.isNotEmpty
            ? uriComponents.pathSegments[0].toString()
            : '';
        String protocol = uriComponents.scheme;
        String secret = uriComponents.queryParameters.containsKey('secret')
            ? uriComponents.queryParameters['secret'].toString()
            : '';
        String algorithm =
            uriComponents.queryParameters.containsKey('algorithm')
                ? uriComponents.queryParameters['algorithm'].toString()
                : 'SHA1';
        String digits = uriComponents.queryParameters.containsKey('digits')
            ? uriComponents.queryParameters['digits'].toString()
            : '6';
        String period = uriComponents.queryParameters.containsKey('period')
            ? uriComponents.queryParameters['period'].toString()
            : '30';

        TotpAccount account = TotpAccount(
          createdOn: DateTime.now(),
          data: TotpAccountDetail(
            backupCodes: '',
            host: host,
            issuer: issuer,
            name: name,
            protocol: protocol,
            secret: secret,
            tags: [],
            url: accountUri,
          ),
          id: 'id',
          name: issuer.toUpperCase(),
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          options: TotpOptions(
            isEnabled: false,
            selectedAlgorithm: algorithm,
            selectedDigitsCount: digits,
            selectedInterval: period,
          ),
          isFavourite: false,
        );
        TotpAccntCryptoResp accountEncryptionResp = account.encrypt(
          RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
        );
        accounts.add(accountEncryptionResp.data);
      }
      setState(() {});
    } catch (e) {
      _showDilogue(
        context,
        'Alert! Error occured.',
        e.toString(),
        () {},
      );
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
              largeTitle: const Text('Select Accounts'),
            ),
          ];
        }),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                itemCount: accounts.length,
                itemBuilder: (context, index) {
                  TotpAccount thisAccount = accounts[index];
                  return AccountTile(
                    accountName: thisAccount.data.name,
                    issuerName: thisAccount.data.issuer,
                    switchVal: !unSelectedAccountIndices.contains(index),
                    isFirst: index == 0,
                    isLast: index == accounts.length - 1,
                    onSwitch: (value) {
                      unSelectedAccountIndices.contains(index)
                          ? setState(
                              () => unSelectedAccountIndices.remove(index))
                          : setState(() => unSelectedAccountIndices.add(index));
                    },
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
              child: CupertinoButton.filled(
                child: Text(
                  'Continue',
                  style: TextStyle(
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  print(unSelectedAccountIndices);
                  print(accounts.length);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountTile extends StatelessWidget {
  final String accountName;
  final String issuerName;
  final bool switchVal;
  final bool isFirst;
  final bool isLast;
  final Function(bool) onSwitch;
  const AccountTile({
    Key? key,
    required this.accountName,
    required this.issuerName,
    required this.switchVal,
    required this.onSwitch,
    this.isFirst = false,
    this.isLast = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      margin: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isFirst ? 12.0 : 0.0),
          topRight: Radius.circular(isFirst ? 12.0 : 0.0),
          bottomLeft: Radius.circular(isLast ? 12.0 : 0.0),
          bottomRight: Radius.circular(isLast ? 12.0 : 0.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issuerName,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  accountName,
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                ),
              ),
            ],
          ),
          CupertinoSwitch(value: switchVal, onChanged: (val) => onSwitch(val)),
        ],
      ),
    );
  }
}
