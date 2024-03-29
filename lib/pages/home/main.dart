import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/Settings/main.dart' as settings;
import 'package:authenticator/pages/home/components/bottom_container.dart';
import 'package:authenticator/pages/home/components/otp_view.dart';
import 'package:authenticator/pages/home/components/render_acc_locked.dart';
import 'package:authenticator/pages/scanner/main.dart';
import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:pull_down_button/pull_down_button.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TotpAccount> totpAccounts = [];
  final TextEditingController _searchController = TextEditingController();

  int _selectedSorting = 0; // 0 => Newest first, 1 => Oldest first, 2 => Alphabetical desc, 3 => Alphabetical asc

  _showAlertDilogue(String title, String message, Function onPress) {
    return showCupertinoDialog(
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

  _navigateToSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute<Widget>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return const settings.Settings();
        },
      ),
    );
  }

  _attachOrDetackPVKey(
    BuildContext topLevelContext,
    bool isPvKeyAttached,
  ) async {
    if (!isPvKeyAttached) {
      PickFileResp filePickResp = await FS.pickSingleFile(['pem']);
      if (!filePickResp.status) {
        return;
      }
      ReadFileResp readFileResp = await FS.readFileContents(filePickResp.file);
      if (!readFileResp.status) {
        return;
      }
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(topLevelContext).dispatch(AttachKeyAction(key: readFileResp.contents));
    } else {
      StoreProvider.of<AppState>(topLevelContext).dispatch(DetachKeyAction());
    }
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

  _showOTPBox(BuildContext context, TotpAccount account, String key) {
    TotpAccntCryptoResp decryptedData = account.decrypt(RSAPrivateKey.fromPEM(key));
    if (!decryptedData.status) {
      _showAlertDilogue('Alert!', 'An error occured while decryption!', () => null);
      return;
    }
    return showCupertinoDialog(
      context: context,
      builder: (context) => OtpView(accountData: decryptedData.data),
    );
  }

  PullDownButton _buildHeaderPullDownButton() {
    return PullDownButton(
      itemBuilder: (context) => [
        const PullDownMenuTitle(title: Text('Sorting Options')),
        PullDownMenuItem.selectable(
          title: 'Newest First',
          onTap: () => setState(() => _selectedSorting = 0),
          selected: _selectedSorting == 0,
          icon: CupertinoIcons.calendar_badge_minus,
        ),
        PullDownMenuItem.selectable(
          title: 'Oldest First',
          onTap: () => setState(() => _selectedSorting = 1),
          selected: _selectedSorting == 1,
          icon: CupertinoIcons.calendar_badge_plus,
        ),
        PullDownMenuItem.selectable(
          title: 'Service (A to Z)',
          selected: _selectedSorting == 3,
          onTap: () => setState(() => _selectedSorting = 3),
          icon: CupertinoIcons.text_badge_minus,
        ),
        PullDownMenuItem.selectable(
          title: 'Service (Z to A)',
          selected: _selectedSorting == 2,
          onTap: () => setState(() => _selectedSorting = 2),
          icon: CupertinoIcons.text_badge_plus,
        ),
        // const PullDownMenuDivider.large(),
      ],
      position: PullDownMenuPosition.automatic,
      buttonBuilder: (context, showMenu) => CupertinoButton(
        onPressed: showMenu,
        padding: const EdgeInsets.all(0.0),
        alignment: Alignment.centerRight,
        child: const Icon(CupertinoIcons.ellipsis_circle, size: 23),
      ),
    );
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
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            final bool isPVKeyAvailable = state.pvKey.isAttached;
            return NestedScrollView(
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  CupertinoSliverNavigationBar(
                    // backgroundColor:
                    //     CupertinoTheme.of(context).scaffoldBackgroundColor,
                    border: null,
                    leading: CupertinoButton(
                      onPressed: () => _navigateToSettings(),
                      padding: const EdgeInsets.all(0.0),
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        CupertinoIcons.settings,
                        size: 23,
                        color: isPVKeyAvailable ? null : CupertinoColors.systemRed,
                      ),
                    ),
                    largeTitle: const Text('Authenticator'),
                    trailing: _buildHeaderPullDownButton(),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
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
                            child: Text("Something went wrong ${snapshot.error.toString()}"),
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
                        List<TotpAccount> accounts = snapshot.data!.docs.map((DocumentSnapshot doc) {
                          Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
                          TotpAccount account = TotpAccount.fromJson(data, doc.id);
                          return account;
                        }).toList();
                        return SlidableAutoCloseBehavior(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(top: 0),
                            itemCount: accounts.length,
                            itemBuilder: (context, index) {
                              if (isPVKeyAvailable) {
                                return RenderAccountLocked(
                                  accountData: accounts[index],
                                  onPressed: () => _showOTPBox(context, accounts[index], state.pvKey.key),
                                  isTopElement: index == 0,
                                  isBottomElement: index == accounts.length - 1,
                                );
                              }
                              return RenderAccountLocked(
                                accountData: accounts[index],
                                onPressed: () => _showAlertDilogue(
                                  'Alert!',
                                  'Private Key not attached.\nDo you wnat to attach Private Key?',
                                  () => _attachOrDetackPVKey(context, isPVKeyAvailable),
                                ),
                                isTopElement: index == 0,
                                isBottomElement: index == accounts.length - 1,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  BottomContainer(onPress: _navigateToScanner),
                ],
              ),
            );
          }),
    );
  }
}
