import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:authenticator/modals/user_modal.dart' as user_modal;
import 'package:authenticator/redux/auth/auth_action.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:authenticator/shared/functions/crypto_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';

class KeypairPage extends StatefulWidget {
  final String email;
  final String password;

  const KeypairPage({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<KeypairPage> createState() => _KeypairPageState();
}

class _KeypairPageState extends State<KeypairPage> {
  TextEditingController pbKeyInpCtrl = TextEditingController();
  TextEditingController pvKeyInpCtrl = TextEditingController();
  late RSAKeypair keyPair;
  bool showSpinner = false;

  @override
  void initState() {
    pbKeyInpCtrl.text = 'PublicKey';
    pvKeyInpCtrl.text = 'PrivateKey';
    keyPair = CryptoService.getKeyPair();
    super.initState();
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

  downloadPublicKey(BuildContext context, String key, String filename, String type) async {
    if (filename.isEmpty) {
      _showAlert(context, 'Enter $type Key file name!');
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
    WriteFileResp writeFileResp = await FS.writeFileContents(File(pbKeyFilePath), key);
    if (!writeFileResp.status) {
      // ignore: use_build_context_synchronously
      _showAlert(
        context,
        'Error in saving file, try again: ${writeFileResp.message}.\n\nTry using another folder to save keys.',
      );
      return;
    }
  }

  void _startLogin(BuildContext context) async {
    setState(() {
      showSpinner = true;
    });
    try {
      UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: widget.email,
        password: widget.password,
      );

      final pbkfdSalt = CryptoService.generateRandomSalt();
      final pbkdfKey = CryptoService.generatePBKDF(widget.password, pbkfdSalt);

      final privateKeySalt = CryptoService.generateRandomSalt();
      final encryptedPrivateKey = CryptoService.encrypt(
        pbkdfKey,
        Uint8List.fromList(privateKeySalt.codeUnits),
        Uint8List.fromList(keyPair.privateKey.toFormattedPEM().codeUnits),
      );

      Map<String, dynamic> userData = {
        'userId': user.user!.uid,
        'publicKey': keyPair.publicKey.toFormattedPEM(),
        'email': widget.email,
        'pbkdfSalt': pbkfdSalt,
        'privateKey': const Latin1Codec().decode(encryptedPrivateKey),
        'pvtKeySalt': privateKeySalt,
      };
      await FirebaseFirestore.instance.collection('users').add(userData);

      user_modal.User newUser = user_modal.User.fromJson(userData);
      // ignore: use_build_context_synchronously
      StoreProvider.of<AppState>(context).dispatch(LoginAction(user: newUser));
    } catch (e) {
      StoreProvider.of<AppState>(context).dispatch(LoginErrAction(errMess: e.toString()));
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Signup Error'),
          content: Text(e.toString()),
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
    setState(() {
      showSpinner = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.canPop(context) ? Navigator.pop(context) : null;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Download keys'),
      ),
      child: ListView(
        children: [
          Image.asset('images/keys2.png'),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 13.0,
              horizontal: 10.0,
            ),
            child: RichText(
              text: TextSpan(
                text: 'Your encryption key pair has been generated.',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
            ),
          ),
          // Main Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: RichText(
              textScaleFactor: 0.9,
              text: TextSpan(
                text: 'The Keypair consists of ',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                children: const <TextSpan>[
                  TextSpan(
                    text: 'PUBLIC KEY',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' and '),
                  TextSpan(
                    text: 'PRIVATE KEY.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " The 'PUBLIC KEY' by name is public and is available to every ",
                  ),
                  TextSpan(
                    text: 'Encrypto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: " user, this key is used to encrypt your data, but to decrypt your data, the 'PRIVATE KEY' is required and",
                  ),
                  TextSpan(
                    text: ' only you have access to your private key',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: '\n\nTherefore the security of your peivate key is your responsiblity and you have to make sure you do not loose this key.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        '\n\nIf you lose your private key you will loose your data permanently as your data can only be decrypted using your private key!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        '\n\nDo NOT edit your private key, even an extra space in the key file will render it useless.\n\nNo one should have access to your private key.\n\nDo NOT store your Privete Key on any cloud storage.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // Public key header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: Text(
              '\n\nPUBLIC KEY',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
          ),
          // Public key body
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: RichText(
              textScaleFactor: 0.9,
              text: TextSpan(
                text: '',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'We will store your ',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'PUBLIC ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'key on our servers and use it to encrypt your data.',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  TextSpan(
                    text: '\n\nYou can keep a copy your public key. You can also download your public key later.',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            ),
          ),
          // Public key file name input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoTextField(
              controller: pbKeyInpCtrl,
              placeholder: 'Enter file name ex. PublicKey',
              suffix: CupertinoButton(
                onPressed: () => downloadPublicKey(context, keyPair.publicKey.toFormattedPEM(), pbKeyInpCtrl.text, 'Public'),
                child: const Icon(CupertinoIcons.cloud_download),
              ),
            ),
          ),
          // Private key header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: Text(
              '\n\nPRIVATE KEY',
              style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
            ),
          ),
          // Private key body
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 10.0,
            ),
            child: RichText(
              textScaleFactor: 0.9,
              text: TextSpan(
                text: '',
                style: CupertinoTheme.of(context).textTheme.textStyle,
                children: <TextSpan>[
                  TextSpan(
                    text: 'We do ',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'NOT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: "store your ",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'PRIVATE KEY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " anywhere.",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  TextSpan(
                    text: '\n\nYou will need a copy your private key. Without it you will',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: ' NOT ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: "be able to access your data. It is your responsiblity to manage",
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: ' SECURITY, AVAILABLITY ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: 'and ',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  const TextSpan(
                    text: 'ACCESSIBILITY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                  ),
                  TextSpan(
                    text: ' of your private key.',
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                ],
              ),
            ),
          ),
          // Private key file name input
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CupertinoTextField(
              controller: pvKeyInpCtrl,
              placeholder: 'Enter file name ex. PrivateKey',
              suffix: CupertinoButton(
                onPressed: () => downloadPublicKey(context, keyPair.privateKey.toFormattedPEM(), pvKeyInpCtrl.text, 'Private'),
                child: const Icon(CupertinoIcons.cloud_download),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: CupertinoButton.filled(
              onPressed: () => _startLogin(context),
              child: showSpinner
                  ? const CupertinoActivityIndicator()
                  : const Text(
                      'Sign Up',
                      style: TextStyle(color: CupertinoColors.white),
                    ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
