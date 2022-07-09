import 'package:authenticator/modals/otp_modal.dart';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/functions.dart';
import 'package:flutter/cupertino.dart';

class RenderAccountLocked extends StatefulWidget {
  final TotpAccount accountData;
  final Function onPressed;
  const RenderAccountLocked({
    Key? key,
    required this.accountData,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<RenderAccountLocked> createState() => _RenderAccountLockedState();
}

class _RenderAccountLockedState extends State<RenderAccountLocked> {
  OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(widget.accountData.data.issuer);
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10.0),
                  padding: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: CupertinoColors.separator,
                      width: 0.5,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: imageName == 'account'
                        ? const Icon(
                            CupertinoIcons.person_crop_circle,
                            size: 45,
                            // color: CupertinoColors.placeholderText,
                            color: CupertinoColors.secondaryLabel,
                          )
                        : Image.asset(imageName, height: 35, width: 35),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.accountData.data.issuer,
                      style: CupertinoTheme.of(context)
                          .textTheme
                          .navTitleTextStyle,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3.0),
                      child: Text(
                        Uri.decodeComponent(widget.accountData.data.name),
                        style: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            CupertinoButton(
              onPressed: () => widget.onPressed(),
              child: const Icon(CupertinoIcons.right_chevron, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
