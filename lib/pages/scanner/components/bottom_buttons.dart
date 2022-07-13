import 'package:authenticator/pages/scanner/components/enter_manually.dart';
import 'package:authenticator/pages/scanner/components/enter_url.dart';
import 'package:authenticator/pages/scanner/main.dart';
import 'package:flutter/cupertino.dart';

class BottomButtons extends StatelessWidget {
  final int curretnPage;
  const BottomButtons({Key? key, required this.curretnPage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBtn(
          icon: CupertinoIcons.qrcode_viewfinder,
          onPress: () {
            if (curretnPage == 0) {
              return;
            }
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
          icon: CupertinoIcons.text_badge_plus,
          onPress: () {
            if (curretnPage == 1) {
              return;
            }
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
          icon: CupertinoIcons.link,
          onPress: () {
            if (curretnPage == 2) {
              return;
            }
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
      ],
    );
  }
}

class CustomBtn extends StatelessWidget {
  final Function onPress;
  final IconData icon;

  const CustomBtn({
    Key? key,
    required this.icon,
    required this.onPress,
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
            padding: const EdgeInsets.symmetric(vertical: 14.0),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              color: CupertinoTheme.of(context).barBackgroundColor,
            ),
            child: Icon(
              icon,
              color: CupertinoTheme.of(context).primaryColor,
            ),
          ),
        ),
      ),
    );
  }
}
