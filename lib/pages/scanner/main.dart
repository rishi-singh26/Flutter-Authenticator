import 'package:authenticator/pages/scanner/components/qr_scanner.dart';
import 'package:flutter/cupertino.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      navigationBar: const CupertinoNavigationBar(
        previousPageTitle: 'Home',
        middle: Text('Scan QR Code'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(CupertinoIcons.qrcode, size: 20)),
            BottomNavigationBarItem(
              icon: Icon(
                CupertinoIcons.text_badge_plus,
                size: 20,
              ),
            ),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.link, size: 20)),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return CupertinoTabView(
              builder: (BuildContext context) {
                return const QRScanner();
              },
            );
          }
          return CupertinoTabView(
            builder: (BuildContext context) {
              return Center(
                child: Text('Content of tab $index'),
              );
            },
          );
        },
      ),
    );
  }
}
