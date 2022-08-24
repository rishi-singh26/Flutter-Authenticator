import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Scaffold;
import 'package:flutter_redux/flutter_redux.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ExportAccounts extends StatefulWidget {
  const ExportAccounts({Key? key}) : super(key: key);

  @override
  State<ExportAccounts> createState() => _ExportAccountsState();
}

class _ExportAccountsState extends State<ExportAccounts> {
  TextStyle stepsStyle(BuildContext context) => CupertinoTheme.of(context)
      .textTheme
      .tabLabelTextStyle
      .copyWith(fontSize: 14);

  _showAlert(BuildContext context, String content, {String header = 'Alert!'}) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(header),
        content: Text(content),
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

  _showQRBox(BuildContext context, TotpAccount account, AppState state) {
    TotpAccntCryptoResp totpAccntCryptoResp =
        account.decrypt(RSAPrivateKey.fromPEM(state.pvKey.key));

    if (!totpAccntCryptoResp.status) {
      _showAlert(context, totpAccntCryptoResp.message);
      return;
    }
    final TotpAccount decrypedAccount = totpAccntCryptoResp.data;
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(decrypedAccount.data.issuer),
        content: Column(
          children: [
            Text(
              Uri.decodeComponent(
                (decrypedAccount.data.name).split(':').last,
              ),
              style: CupertinoTheme.of(context)
                  .textTheme
                  .tabLabelTextStyle
                  .copyWith(fontSize: 14),
            ),
            Container(
              width: 230,
              height: 230,
              margin: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
                color: CupertinoColors.white,
              ),
              child: QrImage(
                data: decrypedAccount.data.url,
                version: QrVersions.auto,
                size: 100,
                errorStateBuilder: (cxt, err) {
                  return const Center(
                    child: Text(
                      "Uh oh! Something went wrong...",
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // _exportToGoogle(BuildContext context) {
  //   // NOTE Every thing in export to google works but when exported the accounts dont have correct TOTP codes
  //   List<String> urls = [];
  //   for (TotpAccount element in accounts) {
  //     urls.add(element.data.url.toUpperCase());
  //   }
  //   EncodeToGoogleUriResp encodeToGoogleUriResp = encodeToGoogleMigration(urls);
  //   if (!encodeToGoogleUriResp.status) {
  //     _showAlert(context, encodeToGoogleUriResp.message);
  //     return;
  //   }
  //   _showQRBox(
  //     context,
  //     'Export',
  //     'Google Authenticator',
  //     encodeToGoogleUriResp.uri,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> accountsStream = FirebaseFirestore.instance
        .collection('newTotpAccounts')
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
        )
        .orderBy('name')
        .snapshots();
    return Scaffold(
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return CupertinoPageScaffold(
            child: NestedScrollView(
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  const CupertinoSliverNavigationBar(
                    border: null,
                    largeTitle: Text('Export Accounts'),
                  ),
                ];
              }),
              body: StreamBuilder<QuerySnapshot>(
                stream: accountsStream,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                          "Something went wrong ${snapshot.error.toString()}"),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                  if (snapshot.hasData && snapshot.data?.docs.isEmpty == null) {
                    return const Center(child: Text("Document does not exist"));
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      child: Text('No Accounts available'),
                    );
                  }
                  List<TotpAccount> accounts =
                      snapshot.data!.docs.map((DocumentSnapshot doc) {
                    Map<String, dynamic> data =
                        doc.data()! as Map<String, dynamic>;
                    TotpAccount account = TotpAccount.fromJson(data, doc.id);
                    return account;
                  }).toList();

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20, bottom: 5),
                      //   child: Text(
                      //     'Export to Google Authenticcator',
                      //     style: CupertinoTheme.of(context)
                      //         .textTheme
                      //         .tabLabelTextStyle
                      //         .copyWith(fontSize: 12),
                      //   ),
                      // ),
                      // Container(
                      //   margin: const EdgeInsets.symmetric(horizontal: 12),
                      //   padding: const EdgeInsets.all(10.0),
                      //   decoration: BoxDecoration(
                      //     color: CupertinoTheme.of(context).barBackgroundColor,
                      //     borderRadius:
                      //         const BorderRadius.all(Radius.circular(10.0)),
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       InfoTile(
                      //         infoNumber: '1',
                      //         text: RichText(
                      //           maxLines: 3,
                      //           text: TextSpan(
                      //             text: 'Open Google Authenticator app.',
                      //             style: stepsStyle(context),
                      //           ),
                      //         ),
                      //       ),
                      //       InfoTile(
                      //         infoNumber: '2',
                      //         text: RichText(
                      //           maxLines: 3,
                      //           text: TextSpan(
                      //             text: 'Tap the overflow button ',
                      //             style: stepsStyle(context),
                      //             children: const [
                      //               WidgetSpan(
                      //                 child: Icon(CupertinoIcons.ellipsis,
                      //                     size: 14),
                      //               ),
                      //               TextSpan(
                      //                   text: ' at the top right of the app.'),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //       InfoTile(
                      //         infoNumber: '3',
                      //         text: RichText(
                      //           maxLines: 3,
                      //           text: TextSpan(
                      //             text: 'Find "Import Accounts"',
                      //             style: stepsStyle(context),
                      //           ),
                      //         ),
                      //       ),
                      //       InfoTile(
                      //         infoNumber: '4',
                      //         text: RichText(
                      //           maxLines: 3,
                      //           text: TextSpan(
                      //             text:
                      //                 'Click on "Scan QR Code" and scan the QR code from this app.',
                      //             style: stepsStyle(context),
                      //           ),
                      //         ),
                      //       ),
                      //       InfoTile(
                      //         infoNumber: '5',
                      //         text: RichText(
                      //           maxLines: 3,
                      //           text: TextSpan(
                      //             text:
                      //                 'Other app which support Importing from Google Authenticator will also support this method of exporting.',
                      //             style: stepsStyle(context),
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(
                      //       horizontal: 30.0, vertical: 20),
                      //   child: CupertinoButton.filled(
                      //     child: const Text(
                      //       'Export',
                      //       style: TextStyle(
                      //         color: CupertinoColors.white,
                      //         fontSize: 19,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     onPressed: () => _exportToGoogle(context),
                      //   ),
                      // ),
                      // Tile(
                      //   title: 'Google Authenticator',
                      //   subtitle: 'Exporting all accounts.',
                      //   isFirst: true,
                      //   isLast: true,
                      //   icon: CupertinoIcons.chevron_up,
                      //   iconColor: CupertinoColors.systemBlue,
                      //   onPress: () {},
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, bottom: 10, top: 10),
                        child: Text(
                          'Export each account individually',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .tabLabelTextStyle
                              .copyWith(fontSize: 12),
                        ),
                      ),
                      for (TotpAccount element in accounts)
                        _Tile(
                          title: element.data.issuer,
                          subtitle: Uri.decodeComponent(
                            (element.data.name).split(':').last,
                          ),
                          isFirst: accounts.indexOf(element) == 0,
                          isLast:
                              accounts.indexOf(element) == accounts.length - 1,
                          icon: CupertinoIcons.share,
                          iconColor: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color ??
                              CupertinoColors.systemBlue,
                          onPress: () {
                            _showQRBox(context, element, state);
                          },
                        )
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function() onPress;
  final bool isFirst;
  final bool isLast;
  final IconData icon;
  final Color iconColor;
  const _Tile({
    Key? key,
    this.subtitle = '',
    required this.title,
    required this.onPress,
    this.isFirst = false,
    this.isLast = false,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(title);
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15),
        margin: const EdgeInsets.symmetric(horizontal: 12.0),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isFirst ? 10 : 0),
            topRight: Radius.circular(isFirst ? 10 : 0),
            bottomLeft: Radius.circular(isLast ? 10 : 0),
            bottomRight: Radius.circular(isLast ? 10 : 0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: imageName == 'account'
                      ? const Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 35,
                          // color: CupertinoColors.placeholderText,
                          color: CupertinoColors.secondaryLabel,
                        )
                      : Image.asset(imageName, height: 35, width: 35),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                    ),
                    subtitle.isEmpty
                        ? const SizedBox()
                        : SizedBox(
                            width: 220,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                subtitle,
                                maxLines: 2,
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .tabLabelTextStyle
                                    .copyWith(fontSize: 14),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            ),
            Icon(icon, size: 20, color: iconColor),
          ],
        ),
      ),
    );
  }
}
