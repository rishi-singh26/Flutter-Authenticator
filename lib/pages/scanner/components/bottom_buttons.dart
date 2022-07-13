import 'package:authenticator/pages/scanner/components/enter_manually.dart';
import 'package:authenticator/pages/scanner/components/enter_url.dart';
import 'package:authenticator/pages/scanner/components/from_google_auth.dart';
import 'package:flutter/cupertino.dart';

class BottomButtons extends StatelessWidget {
  const BottomButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomBtn(
          icon: CupertinoIcons.text_badge_plus,
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
          icon: CupertinoIcons.link,
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
