import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/components/bottom_container.dart';
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
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:redux/redux.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TotpAccount> totpAccounts = [];
  final TextEditingController _searchController = TextEditingController();

  int _selectedSorting =
      0; // 0 => Newest first, 1 => Oldest first, 2 => Alphabetical desc, 3 => Alphabetical asc

  _showAlertDilogue(String title, String message, Function onPress) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.pop(context);
                onPress();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
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

  String _getSortingKey(int selectedSorting) {
    if (selectedSorting == 0 || selectedSorting == 1) {
      return 'createdOn';
    }
    if (selectedSorting == 2 || selectedSorting == 3) {
      return 'name';
    }
    return 'createdOn';
  }

  bool _getSortingOrder(int selectedSorting) {
    if (selectedSorting == 0 || selectedSorting == 2) {
      return true;
    }
    if (selectedSorting == 1 || selectedSorting == 3) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final String sortingKey = _getSortingKey(_selectedSorting);
    final bool sortingOrder = _getSortingOrder(_selectedSorting);
    Stream<QuerySnapshot> accountsStream = FirebaseFirestore.instance
        .collection('newTotpAccounts')
        .where(
          'userId',
          isEqualTo: FirebaseAuth.instance.currentUser?.uid ?? '',
        )
        .orderBy(sortingKey, descending: sortingOrder)
        .snapshots();

    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              // backgroundColor:
              //     CupertinoTheme.of(context).scaffoldBackgroundColor,
              border: null,
              leading: CupertinoButton(
                onPressed: () => _showActions(context),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerLeft,
                child: const Icon(CupertinoIcons.settings, size: 23),
              ),
              largeTitle: const Text('Authenticator'),
              trailing: PullDownButton(
                itemBuilder: (context) => [
                  const PullDownMenuTitle(title: Text('Sorting Options')),
                  SelectablePullDownMenuItem(
                    title: 'Newest First',
                    onTap: () => setState(() => _selectedSorting = 0),
                    selected: _selectedSorting == 0,
                    icon: CupertinoIcons.calendar_badge_minus,
                  ),
                  const PullDownMenuDivider(),
                  SelectablePullDownMenuItem(
                    title: 'Oldest First',
                    onTap: () => setState(() => _selectedSorting = 1),
                    selected: _selectedSorting == 1,
                    icon: CupertinoIcons.calendar_badge_plus,
                  ),
                  const PullDownMenuDivider(),
                  SelectablePullDownMenuItem(
                    title: 'Service (A to Z)',
                    selected: _selectedSorting == 3,
                    onTap: () => setState(() => _selectedSorting = 3),
                    icon: CupertinoIcons.text_badge_minus,
                  ),
                  const PullDownMenuDivider(),
                  SelectablePullDownMenuItem(
                    title: 'Service (Z to A)',
                    selected: _selectedSorting == 2,
                    onTap: () => setState(() => _selectedSorting = 2),
                    icon: CupertinoIcons.text_badge_plus,
                  ),
                  // const PullDownMenuDivider.large(),
                ],
                position: PullDownMenuPosition.under,
                buttonBuilder: (context, showMenu) => CupertinoButton(
                  onPressed: showMenu,
                  padding: const EdgeInsets.all(0.0),
                  alignment: Alignment.centerRight,
                  child: const Icon(CupertinoIcons.ellipsis_circle, size: 23),
                ),
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
                    builder: (context, state) => SlidableAutoCloseBehavior(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(top: 0),
                        itemCount: accounts.length,
                        itemBuilder: (context, index) {
                          if (state.pvKey.isAttached) {
                            TotpAccntCryptoResp decryptedData = accounts[index]
                                .decrypt(
                                    RSAPrivateKey.fromPEM(state.pvKey.key));
                            if (!decryptedData.status) {
                              return RenderAccountLocked(
                                accountData: accounts[index],
                                onPressed: () => _showAlertDilogue(
                                  'Alert!',
                                  'An error occured while decryption!',
                                  () {},
                                ),
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
                    ),
                  );
                },
              ),
            ),
            BottomContainer(onPress: _navigateToScanner),
          ],
        ),
      ),
    );
  }
}
