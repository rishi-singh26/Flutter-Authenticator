import 'dart:typed_data';
import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/pages/scanner/components/select_accounts.dart';
import 'package:authenticator/pages/scanner/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool flashState = false;
  bool backCam = true;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  late MobileScannerController cameraController;

  @override
  void initState() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: backCam ? CameraFacing.back : CameraFacing.front,
      torchEnabled: flashState,
    );
    super.initState();
  }

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
      // fit: BoxFit.contain,
      controller: cameraController,
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        final Uint8List? image = capture.image;
        for (final barcode in barcodes) {
          _onQRCodeDetect(barcode.rawValue ?? '', cameraController);
        }
      },
    );
  }

  _onQRCodeDetect(String scanResult, MobileScannerController controller) {
    try {
      final Uri uriComponents = Uri.parse(scanResult);
      if (uriComponents.isScheme('otpauth')) {
        controller.stop();
        String issuer = uriComponents.queryParameters.containsKey('issuer') ? uriComponents.queryParameters['issuer'].toString() : '';
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
        controller.stop();
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
  }

  Future<bool> addAccount(BuildContext context, String result, Uri uri) async {
    try {
      AddAccountResp addAccountResp = await addAccountToFirebase(
        result,
        uri,
        () => Navigator.canPop(context) ? Navigator.pop(context) : null,
      );
      return addAccountResp.status;
    } catch (e) {
      return false;
    }
  }

  _showDilogue(BuildContext topContext, String title, String content, Function onPress) {
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
                cameraController.start();
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
    cameraController.dispose();
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
                            setState(() {
                              backCam = !backCam;
                            });
                          },
                          onFlashPress: () async {
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
