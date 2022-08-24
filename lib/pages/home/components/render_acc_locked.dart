import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/pages/home/components/acc_detail.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

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
  _showAlert(BuildContext context, String content) {
    return showCupertinoDialog(
      context: context,
      builder: (contxt) => CupertinoAlertDialog(
        title: const Text('Alert!'),
        content: Text(content),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  Future<dynamic> canDeleteAccount(
      BuildContext context, AppState state, String name) async {
    final bool isPVKeyAvailable = state.pvKey.isAttached;
    if (!isPVKeyAvailable) {
      return _showAlert(context, 'Private key is not attached');
    }
    return showCupertinoDialog(
      context: context,
      builder: (contxt) => CupertinoAlertDialog(
        title: const Text('Alert!'),
        content: Text('$name\nDo you want to delete this account?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Ok'),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  _onEditPress(BuildContext context, AppState state) {
    final bool isPVKeyAvailable = state.pvKey.isAttached;
    if (!isPVKeyAvailable) {
      return _showAlert(context, 'Private key is not attached');
    }
    TotpAccntCryptoResp totpAccntCryptoResp =
        widget.accountData.decrypt(RSAPrivateKey.fromPEM(state.pvKey.key));
    if (!totpAccntCryptoResp.status) {
      return _showAlert(context, totpAccntCryptoResp.message);
    }
    Navigator.push(
      context,
      CupertinoPageRoute<Widget>(
        fullscreenDialog: true,
        builder: (BuildContext context) {
          return AccountDetails(account: totpAccntCryptoResp.data);
        },
      ),
    );
  }

  // _onExportPress(BuildContext context, AppState state) {
  //   final bool isPVKeyAvailable = state.pvKey.isAttached;
  //   if (!isPVKeyAvailable) {
  //     return _showAlert(context, 'Private key is not attached');
  //   }
  //   return _showAlert(context, 'Show qr');
  // }

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
    return StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return GestureDetector(
          onTap: () => widget.onPressed(),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15.0),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              color: CupertinoTheme.of(context).barBackgroundColor,
            ),
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Slidable(
                groupTag: 'uniqueKeyForAccountsList',
                key: const ValueKey(0),
                // startActionPane: ActionPane(
                //   extentRatio: 0.3,
                //   motion: const ScrollMotion(),
                //   children: [
                //     SlidableAction(
                //       onPressed: (contxt) => _onExportPress(context, state),
                //       backgroundColor: CupertinoColors.systemBlue,
                //       foregroundColor: CupertinoColors.white,
                //       icon: CupertinoIcons.share,
                //       label: 'Export',
                //     ),
                //   ],
                // ),
                endActionPane: ActionPane(
                  extentRatio: 0.6,
                  motion: const ScrollMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (contxt) async {
                        if (await canDeleteAccount(
                            context, state, widget.accountData.name)) {
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
                      onPressed: (contxt) => _onEditPress(context, state),
                      backgroundColor: CupertinoColors.systemGrey,
                      foregroundColor: CupertinoColors.white,
                      icon: CupertinoIcons.pencil_circle,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
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
                                child: SizedBox(
                                  width: 200,
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
                        ],
                      ),
                      const Icon(CupertinoIcons.right_chevron, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
