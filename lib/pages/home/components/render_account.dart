import 'package:authenticator/modals/otp_modal.dart';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/components/acc_detail.dart';
import 'package:authenticator/pages/home/functions.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/cupertino.dart';
import 'package:otp/otp.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RenderAccount extends StatefulWidget {
  final TotpAccount accountData;
  final bool bottomBorder;
  const RenderAccount({
    Key? key,
    required this.accountData,
    required this.bottomBorder,
  }) : super(key: key);

  @override
  State<RenderAccount> createState() => _RenderAccountState();
}

class _RenderAccountState extends State<RenderAccount> {
  OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);
  CountDownController countdownControl = CountDownController();

  getOtp() {
    final code8 = OTP.generateTOTPCodeString('TULF5VNGGE267KF7BVZ3FGWBB7TELLIL',
        DateTime.now().millisecondsSinceEpoch);
    // print(widget.accountData.data.url);
    setState(() {
      otpData = OTPdata(otp: code8, remainingTime: OTP.remainingSeconds());
    });
  }

  @override
  void initState() {
    getOtp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getOtp();
    String imageName = getImageName(widget.accountData.data.issuer);
    return Container(
      decoration: BoxDecoration(
        border: widget.bottomBorder
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
      child: GestureDetector(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(13.0)),
          child: Slidable(
            key: const ValueKey(0),
            // The start action pane is the one at the left or the top side.
            endActionPane: ActionPane(
              // A motion is a widget used to control how the pane animates.
              motion: const ScrollMotion(),
              // A pane can dismiss the Slidable.
              dismissible: DismissiblePane(
                closeOnCancel: true,
                confirmDismiss: () async {
                  return await showCupertinoDialog(
                    context: context,
                    builder: (contxt) => CupertinoAlertDialog(
                      title: const Text('Alert!'),
                      content:
                          const Text('Do you want to delete this account?'),
                      actions: <CupertinoDialogAction>[
                        CupertinoDialogAction(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                          },
                          child: const Text('Cancel'),
                        ),
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Ok'),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: () {
                  // print('Dismissed');
                },
              ),
              // All actions are defined in the children parameter.
              children: [
                // A SlidableAction can have an icon and/or a label.
                SlidableAction(
                  onPressed: (contxt) {
                    Navigator.push(
                      context,
                      CupertinoPageRoute<Widget>(
                        fullscreenDialog: true,
                        builder: (BuildContext context) {
                          return AccountDetails(account: widget.accountData);
                        },
                      ),
                    );
                  },
                  // backgroundColor: const Color(0xFF21B7CA),
                  backgroundColor: CupertinoColors.systemGrey,
                  foregroundColor: CupertinoColors.white,
                  icon: CupertinoIcons.info,
                  // label: 'Info',
                ),
                SlidableAction(
                  onPressed: (contxt) {},
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: CupertinoColors.white,
                  icon: CupertinoIcons.delete,
                  // label: 'Delete',
                ),
              ],
            ),

            // The end action pane is the one at the right or the bottom side.
            // startActionPane: ActionPane(
            //   motion: const ScrollMotion(),
            //   children: [
            //     SlidableAction(
            //       // An action can be bigger than the others.
            //       // flex: 2,
            //       onPressed: (doNothing) {},
            //       backgroundColor: const Color(0xFF7BC043),
            //       foregroundColor: CupertinoColors.white,
            //       icon: CupertinoIcons.archivebox,
            //       label: 'Archive',
            //     ),
            //     SlidableAction(
            //       onPressed: (doNothing) {},
            //       backgroundColor: const Color(0xFF0392CF),
            //       foregroundColor: CupertinoColors.white,
            //       icon: CupertinoIcons.floppy_disk,
            //       label: 'Save',
            //     ),
            //   ],
            // ),

            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                              padding: const EdgeInsets.all(5.0),
                              child: imageName == 'account'
                                  ? const Icon(
                                      CupertinoIcons.person_crop_circle,
                                      size: 45,
                                      // color: CupertinoColors.placeholderText,
                                      color: CupertinoColors.secondaryLabel,
                                    )
                                  : Image.asset(imageName,
                                      height: 35, width: 35),
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
                                  Uri.decodeComponent(
                                      widget.accountData.data.name),
                                  style: CupertinoTheme.of(context)
                                      .textTheme
                                      .tabLabelTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // CountdownTimer(
                      //   textStyle:
                      //       CupertinoTheme.of(context).textTheme.textStyle,
                      //   initialTime: otpData.remainingTime,
                      // ),
                      CircularCountDownTimer(
                        duration: 30,
                        initialDuration: 30 - otpData.remainingTime,
                        controller: countdownControl,
                        width: 30,
                        height: 30,
                        ringColor: const Color.fromARGB(255, 26, 192, 54),
                        // ringGradient: null,
                        fillColor: CupertinoColors.systemGrey,
                        // fillGradient: null,
                        // backgroundColor: CupertinoColors.systemPurple,
                        strokeWidth: 3.0,
                        textStyle:
                            CupertinoTheme.of(context).textTheme.textStyle,
                        textFormat: CountdownTextFormat.S,
                        isReverse: true,
                        isReverseAnimation: false,
                        isTimerTextShown: true,
                        autoStart: true,
                        // onStart: () {
                        //   debugPrint('Countdown Started');
                        // },
                        onComplete: () {
                          getOtp();
                          countdownControl.restart();
                          // debugPrint('Countdown Ended');
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 12.0,
                      bottom: 7.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Digit(digit: otpData.otp[0]),
                        Digit(digit: otpData.otp[1]),
                        Digit(digit: otpData.otp[2]),
                        const SizedBox(width: 10.0),
                        Digit(digit: otpData.otp[3]),
                        Digit(digit: otpData.otp[4]),
                        Digit(digit: otpData.otp[5]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Digit extends StatelessWidget {
  final String digit;
  const Digit({Key? key, required this.digit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
      margin: const EdgeInsets.only(left: 5.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(30, 3, 116, 230),
        borderRadius: BorderRadius.all(Radius.circular(7.0)),
      ),
      child: Text(
        digit,
        style: TextStyle(
          color: CupertinoTheme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
