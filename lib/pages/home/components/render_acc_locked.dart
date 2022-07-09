import 'package:authenticator/modals/otp_modal.dart';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:flutter/cupertino.dart';

class RenderAccountLocked extends StatefulWidget {
  final TotpAccount accountData;
  final Function onPressed;
  final bool isBottomElement;
  final bool isTopElement;
  const RenderAccountLocked({
    Key? key,
    required this.accountData,
    required this.onPressed,
    required this.isBottomElement,
    required this.isTopElement,
  }) : super(key: key);

  @override
  State<RenderAccountLocked> createState() => _RenderAccountLockedState();
}

class _RenderAccountLockedState extends State<RenderAccountLocked> {
  OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(widget.accountData.data.issuer);
    BorderRadius borderRadius = BorderRadius.only(
      topLeft: widget.isTopElement ? const Radius.circular(13.0) : Radius.zero,
      topRight: widget.isTopElement ? const Radius.circular(13.0) : Radius.zero,
      bottomLeft:
          widget.isBottomElement ? const Radius.circular(13.0) : Radius.zero,
      bottomRight:
          widget.isBottomElement ? const Radius.circular(13.0) : Radius.zero,
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15.0),
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: GestureDetector(
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
                      borderRadius:
                          const BorderRadius.all(Radius.circular(6.0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: imageName == 'account'
                          ? const Icon(
                              CupertinoIcons.person_crop_circle,
                              size: 35,
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
      ),
    );
  }
}
