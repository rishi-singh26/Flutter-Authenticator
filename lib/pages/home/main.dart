import 'dart:io';

import 'package:authenticator/pages/scanner/main.dart';
import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late TextEditingController _textController;
  String keys = 'No data';

  @override
  initState() {
    super.initState();
    _textController = TextEditingController(text: '');
  }

  @override
  Widget build(BuildContext context) {
    _showActionSheet() async {
      Store<AppState> store = await AppStore.getAppStore();
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: const Text('Title'),
          message: const Text('Message'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute<Widget>(
                    fullscreenDialog: true,
                    builder: (BuildContext context) {
                      return const Scanner();
                    },
                  ),
                );
              },
              child: const Text('Add account'),
            ),
            CupertinoActionSheetAction(
              onPressed: () async {
                Navigator.pop(context);
                String fileDir = await FS.getDocumentDirPath;
                String filePath = '$fileDir/Dummy.txt';
                print('Here is the filepath: $filePath');
                WriteFileResp writeFile = await FS.writeFileContents(
                    File(filePath), 'This is some secret');
                if (writeFile.status) {
                  print('file saved');
                }
              },
              child: const Text('Add account manually'),
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

    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            leading: CupertinoButton(
              onPressed: () => _showActionSheet(),
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerLeft,
              child: const Icon(CupertinoIcons.person_2, size: 26),
            ),
            largeTitle: const Text('Authenticator'),
            trailing: CupertinoButton(
              onPressed: () => _showActionSheet(),
              padding: const EdgeInsets.all(0.0),
              alignment: Alignment.centerRight,
              child: const Icon(CupertinoIcons.ellipsis, size: 26),
            ),
          ),
          SliverFillRemaining(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15.0,
                      vertical: 10.0,
                    ),
                    child:
                        CupertinoSearchTextField(controller: _textController),
                  ),
                  Text(
                    keys,
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  StoreConnector<AppState, AppState>(
                    converter: (store) => store.state,
                    builder: (context, state) => Text(
                      state.auth.userData.toString(),
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
