import 'dart:developer';
import 'dart:io';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:redux/redux.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({Key? key}) : super(key: key);

  @override
  State<QRScanner> createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  Barcode? result;
  Uri uri = Uri.parse('https://www.google.com');
  QRViewController? controller;
  bool flashState = false;
  bool backCam = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
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
      onQRViewCreated: _onQRViewCreated,
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

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.resumeCamera();
    controller.scannedDataStream.listen((scanData) {
      try {
        final Uri uriComponents = Uri.parse(scanData.code ?? '');
        if (uriComponents.isScheme('otpauth')) {
          controller.pauseCamera();
          setState(() {
            result = scanData;
            uri = uriComponents;
          });
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

  Future<bool> addAccount(BuildContext context) async {
    try {
      Store<AppState> store = await AppStore.getAppStore();

      String issuer = result != null
          ? uri.queryParameters.containsKey('issuer')
              ? uri.queryParameters['issuer'].toString()
              : ''
          : '';
      String host = uri.host;
      String name =
          uri.pathSegments.isNotEmpty ? uri.pathSegments[0].toString() : '';
      String protocol = uri.scheme;
      String secret = result != null
          ? uri.queryParameters.containsKey('secret')
              ? uri.queryParameters['secret'].toString()
              : ''
          : '';

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
          url: result?.code ?? '',
        ),
        id: 'id',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        options: TotpOptions(
          isEnabled: false,
          selectedAlgorithm: 'SHA1',
          selectedDigitsCount: '6',
          selectedInterval: '30',
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
      Navigator.canPop(context) ? Navigator.pop(context) : null;
      return true;
    } catch (e) {
      // print(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(uri.queryParameters['issuer'].toString());
    String serviceName = result != null
        ? uri.queryParameters.containsKey('issuer')
            ? uri.queryParameters['issuer'].toString()
            : ''
        : '';
    return Column(
      children: <Widget>[
        SizedBox(
          height: 500,
          child: Stack(
            children: <Widget>[
              SizedBox(child: _buildQrView(context)),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      CupertinoButton(
                        onPressed: () async {
                          await controller?.toggleFlash();
                          setState(() {
                            flashState = !flashState;
                          });
                        },
                        child: FutureBuilder(
                          future: controller?.getFlashStatus(),
                          builder: (context, snapshot) {
                            return flashState
                                ? const Icon(
                                    CupertinoIcons.lightbulb_fill,
                                    color: CupertinoColors.white,
                                  )
                                : const Icon(
                                    CupertinoIcons.lightbulb_slash_fill,
                                    color: CupertinoColors.white,
                                  );
                          },
                        ),
                      ),
                      CupertinoButton(
                        onPressed: () async {
                          await controller?.flipCamera();
                          setState(() {
                            backCam = !backCam;
                          });
                        },
                        child: const Icon(
                          CupertinoIcons.camera_rotate,
                          color: CupertinoColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
          // child: _buildQrView(context),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12.0),
            margin: const EdgeInsets.only(bottom: 45.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(13.0)),
                    ),
                    child: Column(
                      children: [
                        // print(uriComponents.host);
                        // print(uriComponents.hasQuery);
                        // print(uriComponents.query);
                        // print(uriComponents.queryParameters);
                        // print(uriComponents.scheme);
                        // print(uriComponents.pathSegments);
                        Tile(
                          content: serviceName,
                          label: 'Service',
                          leftImage: result != null && imageName != 'account'
                              ? true
                              : false,
                          leftImgName: imageName,
                          bottomBorder: true,
                        ),
                        Tile(
                          content: result != null
                              ? uri.pathSegments[0].toString()
                              : '',
                          label: 'Account',
                          leftImage: false,
                          leftImgName: '',
                          bottomBorder: true,
                        ),
                        Tile(
                          content: result != null
                              ? uri.queryParameters['secret'].toString()
                              : '',
                          label: 'Secret',
                          leftImage: false,
                          leftImgName: '',
                          bottomBorder: true,
                        ),
                      ],
                    ),
                  ),
                ),
                CupertinoButton.filled(
                  onPressed: () => addAccount(context),
                  child: uri.isScheme('otpauth')
                      ? const Text(
                          'Add Account',
                          style: TextStyle(color: CupertinoColors.white),
                        )
                      : const CupertinoActivityIndicator(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Tile extends StatelessWidget {
  final String label;
  final String content;
  final bool leftImage;
  final String leftImgName;
  final bool bottomBorder;

  const Tile({
    Key? key,
    required this.content,
    required this.label,
    required this.leftImage,
    required this.leftImgName,
    required this.bottomBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 9.0, bottom: 12.0, left: 7.0),
      decoration: BoxDecoration(
        border: bottomBorder
            ? Border(
                bottom: BorderSide(
                  color: CupertinoTheme.of(context)
                          .textTheme
                          .tabLabelTextStyle
                          .color ??
                      CupertinoColors.opaqueSeparator,
                  width: 0.1,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          leftImage
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: leftImgName == 'account'
                      ? const Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 45,
                          color: CupertinoColors.secondaryLabel,
                        )
                      : Image.asset(leftImgName, height: 40, width: 40),
                )
              : const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .color,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 310.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    content,
                    style: CupertinoTheme.of(context).textTheme.pickerTextStyle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
