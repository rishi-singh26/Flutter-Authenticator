import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/components/render_acc_locked.dart';
import 'package:authenticator/pages/home/components/render_account.dart';
import 'package:authenticator/pages/scanner/main.dart';
import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

const double _kItemExtent = 32.0;
const List<String> _sortingNames = <String>[
  'Newest First',
  'Oldest First',
  'Service (A to Z)',
  'Service (Z to A)',
];

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TotpAccount> totpAccounts = [];
  final TextEditingController _searchController = TextEditingController();

  int _selectedSorting = 0;

  // This shows a CupertinoModalPopup with a reasonable fixed height which hosts CupertinoPicker.
  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    ).then((value) => setState(() {}));
  }

  _attachOrDetackPVKey(
    BuildContext topLevelContext,
    bool isPvKeyAttached,
  ) async {
    if (!isPvKeyAttached) {
      PickFileResp filePickResp = await FS.pickSingleFile();
      if (!filePickResp.status) {
        return;
      }
      ReadFileResp readFileResp = await FS.readFileContents(filePickResp.file);
      if (!readFileResp.status) {
        return;
      }
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(topLevelContext)
          .dispatch(AttachKeyAction(key: readFileResp.contents));
    } else {
      StoreProvider.of<AppState>(topLevelContext).dispatch(DetachKeyAction());
    }
  }

  _showActions(BuildContext topLevelContext) async {
    Store<AppState> store = await AppStore.getAppStore();
    bool isPvKeyAttached = store.state.pvKey.isAttached;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Attach private key'),
        message: const Text(
          'Select the private which you saved while creating your account',
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              _attachOrDetackPVKey(topLevelContext, isPvKeyAttached);
            },
            child: Text('${isPvKeyAttached ? 'Detach' : 'Attach'} Private key'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              showCupertinoDialog(
                context: context,
                builder: (context) => CupertinoAlertDialog(
                  title: const Text('Alert!'),
                  content: const Text('Do you want to logout?'),
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
                        StoreProvider.of<AppState>(context)
                            .dispatch(LogoutAction());
                        FirebaseAuth.instance.signOut();
                      },
                      child: const Text('Ok'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Log out'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  _navigateToScanner() {
    Navigator.push(
      context,
      CupertinoPageRoute<Widget>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return const Scanner();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Stream<QuerySnapshot> accountsStream = FirebaseFirestore.instance
        .collection('newTotpAccounts')
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
        )
        .orderBy('createdOn', descending: true)
        .snapshots();

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              border: null,
              leading: CupertinoButton(
                onPressed: () => _showActions(context),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerLeft,
                child: const Icon(CupertinoIcons.settings, size: 23),
              ),
              largeTitle: const Text('Authenticator'),
              trailing: StatefulBuilder(
                builder: ((context, setState) {
                  return CupertinoButton(
                    onPressed: () => _showDialog(
                      CupertinoPicker(
                        magnification: 1.22,
                        squeeze: 1.2,
                        useMagnifier: true,
                        itemExtent: _kItemExtent,
                        onSelectedItemChanged: (int selectedItem) {
                          setState(() {
                            _selectedSorting = selectedItem;
                          });
                        },
                        children: List<Widget>.generate(_sortingNames.length,
                            (int index) {
                          return Center(
                            child: Text(
                              _sortingNames[index],
                            ),
                          );
                        }),
                      ),
                    ),
                    padding: const EdgeInsets.all(0.0),
                    alignment: Alignment.centerRight,
                    child: const Icon(CupertinoIcons.ellipsis_circle, size: 23),
                  );
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                ),
              ),
            )
          ];
        }),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
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
                  return StoreConnector<AppState, AppState>(
                    converter: (store) => store.state,
                    builder: (context, state) => ListView.builder(
                      padding: const EdgeInsets.only(top: 0),
                      itemCount: accounts.length,
                      itemBuilder: (context, index) {
                        if (state.pvKey.isAttached) {
                          TotpAccntCryptoResp decryptedData = accounts[index]
                              .decrypt(RSAPrivateKey.fromPEM(state.pvKey.key));
                          if (!decryptedData.status) {
                            return RenderAccountLocked(
                              accountData: accounts[index],
                              onPressed: () => _showActions(context),
                              isTopElement: index == 0,
                              isBottomElement: index == accounts.length - 1,
                            );
                          }
                          return RenderAccount(
                            accountData: decryptedData.data,
                            isTopElement: index == 0,
                            isBottomElement: index == accounts.length - 1,
                          );
                        }
                        return RenderAccountLocked(
                          accountData: accounts[index],
                          onPressed: () => _showActions(context),
                          isTopElement: index == 0,
                          isBottomElement: index == accounts.length - 1,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Container(
              color: CupertinoTheme.of(context).barBackgroundColor,
              alignment: Alignment.center,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10.0),
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 15.0,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.circle_fill,
                        color: CupertinoColors.systemGreen,
                        size: 10,
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        'Synchronised',
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .tabLabelTextStyle
                              .color,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _navigateToScanner,
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: CupertinoTheme.of(context).primaryColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(15.0),
                          ),
                        ),
                        child: const Icon(
                          CupertinoIcons.add,
                          color: CupertinoColors.white,
                          size: 20.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Container(
//   color: CupertinoTheme.of(context).barBackgroundColor,
//   alignment: Alignment.center,
//   width: double.infinity,
//   margin: const EdgeInsets.only(top: 10.0),
//   padding: const EdgeInsets.symmetric(
//     vertical: 15.0,
//     horizontal: 15.0,
//   ),
//   child: Stack(
//     alignment: Alignment.center,
//     children: [
//       Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             CupertinoIcons.circle_fill,
//             color: CupertinoColors.systemGreen,
//             size: 10,
//           ),
//           const SizedBox(width: 4.0),
//           Text(
//             'Synchronised',
//             style: TextStyle(
//               color: CupertinoTheme.of(context)
//                   .textTheme
//                   .tabLabelTextStyle
//                   .color,
//               fontSize: 14,
//             ),
//           ),
//         ],
//       ),
//       Align(
//         alignment: Alignment.centerRight,
//         child: GestureDetector(
//           onTap: _showActionSheet,
//           child: Container(
//             width: 30,
//             height: 30,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//               color: CupertinoTheme.of(context).primaryColor,
//               borderRadius: const BorderRadius.all(
//                 Radius.circular(15.0),
//               ),
//             ),
//             child: const Icon(
//               CupertinoIcons.add,
//               color: CupertinoColors.white,
//               size: 20.0,
//             ),
//           ),
//         ),
//       ),
//     ],
//   ),
// ),
