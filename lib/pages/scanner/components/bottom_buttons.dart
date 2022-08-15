import 'package:authenticator/pages/scanner/components/enter_manually.dart';
import 'package:authenticator/pages/scanner/components/enter_url.dart';
import 'package:authenticator/pages/scanner/components/from_files.dart';
import 'package:authenticator/pages/scanner/components/from_google_auth.dart';
import 'package:authenticator/pages/scanner/main.dart';
import 'package:flutter/cupertino.dart';

class BottomButtons extends StatelessWidget {
  final int currentPage;
  const BottomButtons({Key? key, required this.currentPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBtn(
          icon: CupertinoIcons.qrcode_viewfinder,
          title: 'Scan QR',
          onPress: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Widget>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return const Scanner();
                },
              ),
            );
          },
        ),
        CustomBtn(
          icon: CupertinoIcons.pencil_circle,
          title: 'Manually',
          onPress: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Widget>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return const EnterManually();
                },
              ),
            );
          },
        ),
        CustomBtn(
          icon: CupertinoIcons.globe,
          title: 'URL',
          onPress: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Widget>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return const EnterUrl();
                },
              ),
            );
          },
        ),
        CustomBtn(
          icon: CupertinoIcons.shield_fill,
          title: 'Google',
          onPress: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Widget>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return const FromGoogleAuth();
                },
              ),
            );
          },
        ),
        CustomBtn(
          icon: CupertinoIcons.folder,
          title: 'Files',
          onPress: () {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute<Widget>(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return const FromFiles();
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class CustomBtn extends StatelessWidget {
  final Function onPress;
  final IconData icon;
  final String title;

  const CustomBtn({
    Key? key,
    required this.icon,
    required this.onPress,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: (() => onPress()),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: CupertinoTheme.of(context).barBackgroundColor,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
