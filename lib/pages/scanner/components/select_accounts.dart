import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/scanner/functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

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
  String errorMessage = '';

  @override
  void initState() {
    _decode(widget.scanResult);
    super.initState();
  }

  // _showDilogue(
  //     BuildContext context, String title, String content, Function onPress) {
  //   showCupertinoDialog(
  //     context: context,
  //     builder: (context) {
  //       return CupertinoAlertDialog(
  //         title: Text(
  //           title,
  //           style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
  //         ),
  //         content: Text(
  //           content,
  //           style: CupertinoTheme.of(context).textTheme.textStyle,
  //         ),
  //         actions: [
  //           CupertinoDialogAction(
  //             isDestructiveAction: true,
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           CupertinoDialogAction(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               onPress();
  //             },
  //             child: const Text('Continue'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  _decode(String migrationUri) async {
    try {
      DecodeGoogleUriResp decodeGoogleUriResp =
          await decodeGoogleMigration(migrationUri);
      if (!decodeGoogleUriResp.status) {
        setState(() {
          errorMessage = decodeGoogleUriResp.message;
        });
        return;
      }
      setState(() {
        accounts = decodeGoogleUriResp.accounts;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  Future<bool> _addAccounts(
      BuildContext context, List<TotpAccount> accounts) async {
    try {
      for (var i = 0; i < accounts.length; i++) {
        if (unSelectedAccountIndices.contains(i)) {
          continue;
        }
        TotpAccount account = accounts[i];
        await FirebaseFirestore.instance
            .collection('newTotpAccounts')
            .add(account.toApiJson());
        // ignore: use_build_context_synchronously
        Navigator.canPop(context) ? Navigator.pop(context) : null;
      }
      return true;
    } catch (e) {
      return false;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: accounts.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        'No accounts available \nError occured while decoding accounts.\nPlease try scanning one account at a time',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 15.0),
                      itemCount: accounts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Text(
                            errorMessage,
                            style: const TextStyle(
                                color: CupertinoColors.systemRed),
                          );
                        }
                        final int index2 = index - 1;
                        TotpAccount thisAccount = accounts[index2];
                        return _AccountTile(
                          accountName: thisAccount.data.name,
                          issuerName: thisAccount.data.issuer,
                          switchVal: !unSelectedAccountIndices.contains(index2),
                          isFirst: index == 1,
                          isLast: index == accounts.length,
                          onSwitch: (value) {
                            unSelectedAccountIndices.contains(index2)
                                ? setState(() =>
                                    unSelectedAccountIndices.remove(index2))
                                : setState(
                                    () => unSelectedAccountIndices.add(index2));
                          },
                        );
                      },
                    ),
            ),
            accounts.isEmpty
                ? const SizedBox()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 20),
                    child: CupertinoButton.filled(
                      child: Text(
                        'Continue',
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        _addAccounts(context, accounts);
                        // print(unSelectedAccountIndices);
                        // print(accounts.length);
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String accountName;
  final String issuerName;
  final bool switchVal;
  final bool isFirst;
  final bool isLast;
  final Function(bool) onSwitch;
  const _AccountTile({
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
