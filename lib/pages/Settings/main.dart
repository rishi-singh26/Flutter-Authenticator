import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_redux/flutter_redux.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

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

  _logout(BuildContext context) {
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
              StoreProvider.of<AppState>(context).dispatch(LogoutAction());
              StoreProvider.of<AppState>(context).dispatch(DetachKeyAction());
              FirebaseAuth.instance.signOut();
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = CupertinoTheme.of(context).textTheme.textStyle.color ??
        CupertinoColors.white;
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, store) {
          bool isPvKeyAttached = store.pvKey.isAttached;

          return CupertinoPageScaffold(
            child: NestedScrollView(
              headerSliverBuilder: ((context, innerBoxIsScrolled) {
                return [
                  const CupertinoSliverNavigationBar(
                    border: null,
                    largeTitle: Text('Settings'),
                  ),
                ];
              }),
              body: ListView(
                // padding: EdgeInsets.zero,
                children: [
                  Tile(
                    title: isPvKeyAttached
                        ? 'Detach Private Key'
                        : 'Attach Private Key',
                    subtitle: isPvKeyAttached
                        ? 'Remove private key from the app, OTPs will not be available.'
                        : 'Add Private Key to decryptd your data and get OTPs',
                    onPress: () =>
                        _attachOrDetackPVKey(context, isPvKeyAttached),
                    isFirst: true,
                    icon: Icons.attachment,
                    iconColor: iconColor,
                  ),
                  Tile(
                    title: 'Download Private Key',
                    subtitle:
                        'This feature is helpful in scenearios where you attach the private key and delete it from your device.',
                    onPress: () {},
                    icon: CupertinoIcons.cloud_download,
                    iconColor: iconColor,
                  ),
                  Tile(
                    title: 'Downolad Public Key',
                    subtitle:
                        'You can always download your private key because we save a copy ot it with us.',
                    onPress: () {},
                    icon: CupertinoIcons.cloud_download,
                    iconColor: iconColor,
                  ),
                  Tile(
                    title: 'Logout',
                    subtitle:
                        'You will be logged-out and private key will be detached.',
                    onPress: () => _logout(context),
                    isLast: true,
                    icon: Icons.logout,
                    iconColor: CupertinoColors.systemRed,
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class Tile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function() onPress;
  final bool isFirst;
  final bool isLast;
  final IconData icon;
  final Color iconColor;
  const Tile({
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
    return GestureDetector(
      onTap: onPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CupertinoTheme.of(context).textTheme.textStyle,
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
                                .tabLabelTextStyle,
                          ),
                        ),
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
