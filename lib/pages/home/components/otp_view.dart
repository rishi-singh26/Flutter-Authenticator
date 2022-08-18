import 'dart:typed_data';

import 'package:authenticator/modals/otp_modal.dart';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:base32/base32.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:ootp/ootp.dart';
import 'package:otp/otp.dart' as otp;
import 'package:flutter/services.dart';

class OtpView extends StatefulWidget {
  final TotpAccount accountData;
  const OtpView({
    Key? key,
    required this.accountData,
  }) : super(key: key);

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> with TickerProviderStateMixin {
  OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);
  CountDownController countdownControl = CountDownController();

  getOtp() {
    try {
      String accountSecret =
          stripSpaces(widget.accountData.data.secret.toUpperCase());
      // final code = otp.OTP.generateTOTPCodeString(
      otp.OTP.generateTOTPCodeString(
        accountSecret,
        DateTime.now().millisecondsSinceEpoch,
      );
      Uint8List uiInt8Secret = base32.decode(accountSecret);
      final TOTP totp2 = TOTP.secret(uiInt8Secret);
      setState(() {
        otpData = OTPdata(
          otp: totp2.make(),
          remainingTime: otp.OTP.remainingSeconds() + 2,
        );
      });
    } catch (e) {
      setState(() {
        otpData = OTPdata(
          otp: 'Error:',
          remainingTime: otp.OTP.remainingSeconds() + 2,
        );
      });
    }
  }

  @override
  void initState() {
    getOtp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(widget.accountData.data.issuer),
      content: Column(
        children: [
          Text(
            Uri.decodeComponent(
              (widget.accountData.data.name).split(':').last,
            ),
            style: CupertinoTheme.of(context)
                .textTheme
                .tabLabelTextStyle
                .copyWith(fontSize: 14),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularCountDownTimer(
                  width: 50,
                  height: 50,
                  strokeCap: StrokeCap.round,
                  duration: 30,
                  initialDuration: 30 - otpData.remainingTime,
                  controller: countdownControl,
                  // ringColor: const Color.fromARGB(255, 26, 192, 54),
                  ringColor: CupertinoTheme.of(context).barBackgroundColor,
                  // ringColor: CupertinoTheme.of(context).barBackgroundColor,
                  fillColor: const Color(0xFF2dcc70),
                  strokeWidth: 4.0,
                  textStyle:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                  textFormat: CountdownTextFormat.S,
                  isReverse: true,
                  isReverseAnimation: true,
                  autoStart: true,
                  onComplete: () {
                    getOtp();
                    countdownControl.restart();
                  },
                ),
                const SizedBox(width: 20),
                Text(
                  splitStringInHalf(otpData.otp),
                  style:
                      CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2.0,
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <CupertinoDialogAction>[
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () {
            Clipboard.setData(ClipboardData(text: otpData.otp))
                .then((_) => null);
          },
          child: const Text('Copy'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
