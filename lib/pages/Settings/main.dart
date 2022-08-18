import 'dart:io';

import 'package:authenticator/pages/Settings/components/export_accouts.dart';
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

  _downloadKeyFile(BuildContext context, String key, String filename) async {
    if (filename.isEmpty) {
      _showAlert(context, 'Enter file name!');
      return;
    }
    PickDirResp dirResp = await FS.pickDirectory();
    if (!dirResp.status) {
      dirResp.path == ''
          ? null
          // ignore: use_build_context_synchronously
          : _showAlert(context, 'Error in picking directory');
      return;
    }
    String pbKeyFilePath = '${dirResp.path}/$filename.pem';
    WriteFileResp writeFileResp =
        await FS.writeFileContents(File(pbKeyFilePath), key);
    if (!writeFileResp.status) {
      // ignore: use_build_context_synchronously
      _showAlert(
        context,
        'Error in saving file, try again: ${writeFileResp.message}.\n\nTry using another folder to save keys.',
      );
      return;
    }
    // ignore: use_build_context_synchronously
    _showAlert(context, writeFileResp.message);
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

  _navigateToExportAccounts(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        fullscreenDialog: true,
        builder: ((context) => const ExportAccounts()),
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
                    icon: Icons.attachment_outlined,
                    iconColor: iconColor,
                  ),
                  !isPvKeyAttached
                      ? const SizedBox()
                      : Tile(
                          title: 'Download Private Key',
                          subtitle:
                              'This feature is helpful in scenearios where you attach the private key and delete it from your device.',
                          onPress: () => _downloadKeyFile(
                            context,
                            store.pvKey.key,
                            'PrivateKey_${store.auth.userData.userId}',
                          ),
                          icon: CupertinoIcons.download_circle,
                          iconColor: iconColor,
                        ),
                  Tile(
                    title: 'Downolad Public Key',
                    subtitle:
                        'You can always download your private key because we save a copy ot it with us.',
                    onPress: () => _downloadKeyFile(
                      context,
                      store.auth.userData.publicKey,
                      'PublicKey_${store.auth.userData.userId}',
                    ),
                    isLast: true,
                    icon: CupertinoIcons.download_circle,
                    iconColor: iconColor,
                  ),
                  SizedBox(height: isPvKeyAttached ? 20.0 : 0.0),
                  !isPvKeyAttached
                      ? const SizedBox()
                      : Tile(
                          title: 'Export Data',
                          subtitle:
                              'You can always export your data if you wish to use another app.',
                          onPress: () => _navigateToExportAccounts(context),
                          isFirst: true,
                          isLast: true,
                          icon: CupertinoIcons.share,
                          iconColor: iconColor,
                        ),
                  const SizedBox(height: 20),
                  Tile(
                    title: 'Logout',
                    subtitle:
                        'You will be logged-out and private key will be detached.',
                    onPress: () => _logout(context),
                    isFirst: true,
                    isLast: true,
                    icon: Icons.logout_rounded,
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
