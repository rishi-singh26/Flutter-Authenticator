import 'dart:typed_data';

import 'package:authenticator/modals/otp_modal.dart';
import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/components/acc_detail.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:base32/base32.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:otp/otp.dart' as otp;
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:ootp/ootp.dart';

class RenderAccount extends StatefulWidget {
  final TotpAccount accountData;
  final bool isTopElement;
  final bool isBottomElement;
  const RenderAccount({
    Key? key,
    required this.accountData,
    required this.isBottomElement,
    required this.isTopElement,
  }) : super(key: key);

  @override
  State<RenderAccount> createState() => _RenderAccountState();
}

class _RenderAccountState extends State<RenderAccount>
    with TickerProviderStateMixin {
  OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);
  CountDownController countdownControl = CountDownController();
  // late AnimationController _controller;
  // late Animation<double> _offsetFloat;

  getOtp() {
    try {
      String accountSecret = stripSpaces(widget.accountData.data.secret);
      // final code = otp.OTP.generateTOTPCodeString(
      otp.OTP.generateTOTPCodeString(
        accountSecret,
        DateTime.now().millisecondsSinceEpoch,
      );
      Uint8List uiInt8Secret = base32.decode(accountSecret.toUpperCase());
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
      print(e);
    }
  }

  @override
  void initState() {
    getOtp();
    super.initState();
  }

  Future<dynamic> canDeleteAccount(
      BuildContext context, String accountName) async {
    return showCupertinoDialog(
      context: context,
      builder: (contxt) => CupertinoAlertDialog(
        title: const Text('Alert!'),
        content: const Text('Do you want to delete this account?'),
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
  }

  @override
  Widget build(BuildContext context) {
    getOtp();
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
        color: CupertinoTheme.of(context).barBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Slidable(
          groupTag: 'uniqueKeyForAccountsList',
          key: const ValueKey(0),
          endActionPane: ActionPane(
            extentRatio: 0.6,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (contxt) async {
                  if (await canDeleteAccount(context, 'Name')) {
                    FirebaseFirestore.instance
                        .collection('newTotpAccounts')
                        .doc(widget.accountData.id)
                        .delete();
                  }
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: CupertinoColors.white,
                icon: CupertinoIcons.delete,
              ),
              SlidableAction(
                onPressed: (contxt) {
                  FirebaseFirestore.instance
                      .collection('newTotpAccounts')
                      .doc(widget.accountData.id)
                      .update(
                    {'isFavourite': !widget.accountData.isFavourite},
                  );
                },
                backgroundColor: CupertinoColors.activeOrange,
                foregroundColor: CupertinoColors.white,
                icon: widget.accountData.isFavourite
                    ? CupertinoIcons.star_slash_fill
                    : CupertinoIcons.star,
              ),
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
                backgroundColor: CupertinoColors.systemGrey,
                foregroundColor: CupertinoColors.white,
                icon: CupertinoIcons.pencil_circle,
              ),
            ],
          ),
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
                        SizedBox(
                          width: 200,
                          child: Column(
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
                                child: SizedBox(
                                  width: 250,
                                  child: Text(
                                    Uri.decodeComponent(
                                      (widget.accountData.data.name)
                                          .split(':')
                                          .last,
                                    ),
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: CupertinoTheme.of(context)
                                          .textTheme
                                          .tabLabelTextStyle
                                          .color,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          splitStringInHalf(otpData.otp),
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                              ),
                        ),
                        CircularCountDownTimer(
                          duration: 30,
                          initialDuration: 30 - otpData.remainingTime,
                          controller: countdownControl,
                          width: 20,
                          height: 30,
                          // ringColor: const Color.fromARGB(255, 26, 192, 54),
                          // fillColor: CupertinoColors.systemGrey,
                          ringColor:
                              CupertinoTheme.of(context).barBackgroundColor,
                          fillColor:
                              CupertinoTheme.of(context).barBackgroundColor,
                          strokeWidth: 0.0,
                          textStyle: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                          textFormat: CountdownTextFormat.S,
                          isReverse: true,
                          isReverseAnimation: false,
                          autoStart: true,
                          onComplete: () {
                            getOtp();
                            countdownControl.restart();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
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

// class RenderAccount extends StatefulWidget {
//   final TotpAccount accountData;
//   final bool isTopElement;
//   final bool isBottomElement;
//   const RenderAccount({
//     Key? key,
//     required this.accountData,
//     required this.isBottomElement,
//     required this.isTopElement,
//   }) : super(key: key);
//   @override
//   State<RenderAccount> createState() => _RenderAccountState();
// }
// class _RenderAccountState extends State<RenderAccount> {
//   OTPdata otpData = OTPdata(otp: '      ', remainingTime: 15);
//   CountDownController countdownControl = CountDownController();
//   getOtp() {
//     final code = OTP.generateTOTPCodeString(
//       widget.accountData.data.secret,
//       DateTime.now().millisecondsSinceEpoch,
//       algorithm: Algorithm.SHA512,
//     );
//     setState(() {
//       otpData = OTPdata(
//         otp: code,
//         remainingTime: OTP.remainingSeconds() + 2,
//       );
//     });
//   }
//   @override
//   void initState() {
//     getOtp();
//     super.initState();
//   }
//   Future<dynamic> canDeleteAccount(
//       BuildContext context, String accountName) async {
//     return showCupertinoDialog(
//       context: context,
//       builder: (contxt) => CupertinoAlertDialog(
//         title: const Text('Alert!'),
//         content: const Text('Do you want to delete this account?'),
//         actions: <CupertinoDialogAction>[
//           CupertinoDialogAction(
//             onPressed: () {
//               Navigator.of(context).pop(false);
//             },
//             child: const Text('Cancel'),
//           ),
//           CupertinoDialogAction(
//             isDestructiveAction: true,
//             onPressed: () {
//               Navigator.of(context).pop(true);
//             },
//             child: const Text('Ok'),
//           ),
//         ],
//       ),
//     );
//   }
//   @override
//   Widget build(BuildContext context) {
//     getOtp();
//     String imageName = getImageName(widget.accountData.data.issuer);
//     BorderRadius borderRadius = BorderRadius.only(
//       topLeft: widget.isTopElement ? const Radius.circular(13.0) : Radius.zero,
//       topRight: widget.isTopElement ? const Radius.circular(13.0) : Radius.zero,
//       bottomLeft:
//           widget.isBottomElement ? const Radius.circular(13.0) : Radius.zero,
//       bottomRight:
//           widget.isBottomElement ? const Radius.circular(13.0) : Radius.zero,
//     );
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 15.0),
//       decoration: BoxDecoration(
//         color: CupertinoTheme.of(context).barBackgroundColor,
//         borderRadius: borderRadius,
//       ),
//       child: GestureDetector(
//         child: ClipRRect(
//           borderRadius: borderRadius,
//           child: Slidable(
//             groupTag: '0',
//             key: const ValueKey(0),
//             startActionPane: ActionPane(
//               motion: const ScrollMotion(),
//               children: [
//                 SlidableAction(
//                   onPressed: (contxt) async {
//                     if (await canDeleteAccount(context, 'Name')) {
//                       FirebaseFirestore.instance
//                           .collection('newTotpAccounts')
//                           .doc(widget.accountData.id)
//                           .delete();
//                     }
//                   },
//                   backgroundColor: const Color(0xFFFE4A49),
//                   foregroundColor: CupertinoColors.white,
//                   icon: CupertinoIcons.delete,
//                 ),
//               ],
//             ),
//             endActionPane: ActionPane(
//               motion: const ScrollMotion(),
//               children: [
//                 SlidableAction(
//                   onPressed: (contxt) {
//                     FirebaseFirestore.instance
//                         .collection('newTotpAccounts')
//                         .doc(widget.accountData.id)
//                         .update(
//                       {'isFavourite': !widget.accountData.isFavourite},
//                     );
//                   },
//                   backgroundColor: CupertinoColors.activeOrange,
//                   foregroundColor: CupertinoColors.white,
//                   icon: widget.accountData.isFavourite
//                       ? CupertinoIcons.star_slash
//                       : CupertinoIcons.star,
//                 ),
//                 SlidableAction(
//                   onPressed: (contxt) {
//                     Navigator.push(
//                       context,
//                       CupertinoPageRoute<Widget>(
//                         fullscreenDialog: true,
//                         builder: (BuildContext context) {
//                           return AccountDetails(account: widget.accountData);
//                         },
//                       ),
//                     );
//                   },
//                   backgroundColor: CupertinoColors.systemGrey,
//                   foregroundColor: CupertinoColors.white,
//                   icon: CupertinoIcons.info,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(right: 10.0),
//                             padding: const EdgeInsets.all(1.0),
//                             decoration: BoxDecoration(
//                               border: Border.all(
//                                 color: CupertinoColors.separator,
//                                 width: 0.5,
//                               ),
//                               borderRadius:
//                                   const BorderRadius.all(Radius.circular(6.0)),
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(5.0),
//                               child: imageName == 'account'
//                                   ? const Icon(
//                                       CupertinoIcons.person_crop_circle,
//                                       size: 35,
//                                       // color: CupertinoColors.placeholderText,
//                                       color: CupertinoColors.secondaryLabel,
//                                     )
//                                   : Image.asset(imageName,
//                                       height: 35, width: 35),
//                             ),
//                           ),
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 widget.accountData.data.issuer,
//                                 style: CupertinoTheme.of(context)
//                                     .textTheme
//                                     .navTitleTextStyle,
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 3.0),
//                                 child: Text(
//                                   Uri.decodeComponent(
//                                     widget.accountData.data.name,
//                                   ),
//                                   style: TextStyle(
//                                     color: CupertinoTheme.of(context)
//                                         .textTheme
//                                         .tabLabelTextStyle
//                                         .color,
//                                     fontSize: 13,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.end,
//                         children: [
//                           Padding(
//                             padding: const EdgeInsets.only(bottom: 5.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: [
//                                 Digit(digit: otpData.otp[0]),
//                                 Digit(digit: otpData.otp[1]),
//                                 Digit(digit: otpData.otp[2]),
//                                 Digit(digit: otpData.otp[3]),
//                                 Digit(digit: otpData.otp[4]),
//                                 Digit(digit: otpData.otp[5]),
//                               ],
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.only(right: 6.0),
//                             child: CircularCountDownTimer(
//                               duration: 30,
//                               initialDuration: 30 - otpData.remainingTime,
//                               controller: countdownControl,
//                               width: 25,
//                               height: 25,
//                               ringColor: const Color.fromARGB(255, 26, 192, 54),
//                               // ringGradient: null,
//                               fillColor: CupertinoColors.systemGrey,
//                               // fillGradient: null,
//                               // backgroundColor: CupertinoColors.systemPurple,
//                               strokeWidth: 2.5,
//                               textStyle: CupertinoTheme.of(context)
//                                   .textTheme
//                                   .textStyle,
//                               textFormat: CountdownTextFormat.S,
//                               isReverse: true,
//                               isReverseAnimation: false,
//                               isTimerTextShown: true,
//                               autoStart: true,
//                               // onStart: () {
//                               //   debugPrint('Countdown Started');
//                               // },
//                               onComplete: () {
//                                 getOtp();
//                                 countdownControl.restart();
//                                 // debugPrint('Countdown Ended');
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// class Digit extends StatelessWidget {
//   final String digit;
//   const Digit({Key? key, required this.digit}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Text(
//         digit,
//         style: TextStyle(
//           color: CupertinoTheme.of(context).textTheme.textStyle.color,
//           fontWeight: FontWeight.bold,
//           fontSize: 27,
//         ),
//       ),
//     );
//   }
// }
