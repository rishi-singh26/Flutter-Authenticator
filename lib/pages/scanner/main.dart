import 'dart:developer';
import 'dart:io';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/pages/scanner/components/select_accounts.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:redux/redux.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  QRViewController? controller;
  bool flashState = false;
  bool backCam = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: (controller) => _onQRViewCreated(controller, context),
      overlay: QrScannerOverlayShape(
        borderColor: CupertinoTheme.of(context).primaryColor,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller, BuildContext context) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      try {
        final String scanResult = scanData.code ?? '';
        final Uri uriComponents = Uri.parse(scanResult);
        if (uriComponents.isScheme('otpauth')) {
          controller.pauseCamera();
          String issuer = uriComponents.queryParameters.containsKey('issuer')
              ? uriComponents.queryParameters['issuer'].toString()
              : '';
          _showDilogue(
            context,
            'Account detected!',
            "Do you want to add \"${issuer.isEmpty ? 'this account' : issuer}\"?",
            () {
              addAccount(context, scanResult, uriComponents);
            },
          );
        }
        if (uriComponents.isScheme('otpauth-migration')) {
          controller.pauseCamera();
          _showDilogue(
            context,
            'Multiple accounts detected!',
            "Do you want to continue?",
            () {
              Navigator.of(context).pushReplacement(
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => SelectAccounts(scanResult: scanResult),
                ),
              );
            },
          );
        }
      } catch (e) {
        return;
        // print(e);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          title: Text('Alert!'),
          content: Text('Camera permission denied'),
        ),
      );
    }
  }

  Future<bool> addAccount(BuildContext context, String result, Uri uri) async {
    try {
      Store<AppState> store = await AppStore.getAppStore();

      String issuer = uri.queryParameters.containsKey('issuer')
          ? uri.queryParameters['issuer'].toString()
          : '';
      String host = uri.host;
      String name =
          uri.pathSegments.isNotEmpty ? uri.pathSegments[0].toString() : '';
      String protocol = uri.scheme;
      String secret = uri.queryParameters.containsKey('secret')
          ? uri.queryParameters['secret'].toString()
          : '';
      String algorithm = uri.queryParameters.containsKey('algorithm')
          ? uri.queryParameters['algorithm'].toString()
          : 'SHA1';
      String digits = uri.queryParameters.containsKey('digits')
          ? uri.queryParameters['digits'].toString()
          : '6';
      String period = uri.queryParameters.containsKey('period')
          ? uri.queryParameters['period'].toString()
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
          url: result,
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
      TotpAccntCryptoResp encryptedAccount = account.encrypt(
        RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
      );
      if (!encryptedAccount.status) {
        return false;
      }
      await FirebaseFirestore.instance
          .collection('newTotpAccounts')
          .add(encryptedAccount.data.toApiJson());
      // ignore: use_build_context_synchronously
      Navigator.canPop(context) ? Navigator.pop(context) : null;
      return true;
    } catch (e) {
      // print(e.toString());
      return false;
    }
  }

  _showDilogue(
      BuildContext topContext, String title, String content, Function onPress) {
    showCupertinoDialog(
      context: topContext,
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
                controller?.resumeCamera();
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

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
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
              largeTitle: const Text('Scan QR Code'),
            ),
          ];
        }),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: 400,
                    child: Stack(
                      children: <Widget>[
                        SizedBox(child: _buildQrView(context)),
                        ScannerButtons(
                          flashState: flashState,
                          onCamPress: () async {
                            await controller?.flipCamera();
                            setState(() {
                              backCam = !backCam;
                            });
                          },
                          onFlashPress: () async {
                            await controller?.toggleFlash();
                            setState(() {
                              flashState = !flashState;
                            });
                          },
                        ),
                      ],
                    ),
                    // child: _buildQrView(context),
                  ),
                  const BottomSection(),
                ],
              ),
            ),
            const BottomButtons(currentPage: 0),
          ],
        ),
      ),
    );
  }
}

class ScannerButtons extends StatelessWidget {
  final bool flashState;
  final Function() onFlashPress;
  final Function() onCamPress;
  const ScannerButtons({
    Key? key,
    required this.flashState,
    required this.onCamPress,
    required this.onFlashPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 0.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CupertinoButton(
              onPressed: onFlashPress,
              child: flashState
                  ? const Icon(
                      CupertinoIcons.lightbulb_fill,
                      color: CupertinoColors.white,
                    )
                  : const Icon(
                      CupertinoIcons.lightbulb_slash_fill,
                      color: CupertinoColors.white,
                    ),
            ),
            CupertinoButton(
              onPressed: onCamPress,
              child: const Icon(
                CupertinoIcons.camera_rotate,
                color: CupertinoColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomSection extends StatelessWidget {
  const BottomSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).barBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(13.0)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Drag Authenticator App over your QR Code',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            const SizedBox(height: 35.0),
            Text(
              'You dont know where to find the 2FA QR Code?',
              style: CupertinoTheme.of(context).textTheme.textStyle,
            ),
            CupertinoButton(
              child: const Text('Check 2FA Guides'),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
