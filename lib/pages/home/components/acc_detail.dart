import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:flutter/cupertino.dart';

class AccountDetails extends StatefulWidget {
  final TotpAccount account;
  const AccountDetails({Key? key, required this.account}) : super(key: key);

  @override
  State<AccountDetails> createState() => _AccountDetailsState();
}

class _AccountDetailsState extends State<AccountDetails> {
  bool _advancedOptionsOn = false;
  Object _selectedAlgorithm = 'SHA1';
  Object _selectedDigitsCount = '6';
  Object _selectedInterval = '30';

  resetOptions() {
    setState(() {
      _selectedAlgorithm = 'SHA1';
      _selectedDigitsCount = '6';
      _selectedInterval = '30';
    });
  }

  @override
  void initState() {
    TotpOptions options = widget.account.options;
    _advancedOptionsOn = options.isEnabled;
    _selectedAlgorithm = options.selectedAlgorithm;
    _selectedDigitsCount = options.selectedDigitsCount;
    _selectedInterval = options.selectedInterval;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(widget.account.data.issuer);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Account'),
        leading: CupertinoButton(
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.centerRight,
          child: Text(
            'Cancel',
            style: CupertinoTheme.of(context).textTheme.navActionTextStyle,
          ),
        ),
        trailing: CupertinoButton(
          onPressed: () => {},
          padding: const EdgeInsets.all(0.0),
          alignment: Alignment.centerRight,
          child: Text(
            'Save',
            style: CupertinoTheme.of(context).textTheme.navActionTextStyle,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 7.0,
                top: 30.0,
                left: 7.0,
              ),
              child: Text(
                'BASE OPTIONS',
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .color,
                  fontSize: 14,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                left: 12.0,
                top: 8.0,
                bottom: 8.0,
              ),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(13.0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Tile(
                    content: widget.account.data.issuer,
                    label: 'Service',
                    leftImage: imageName != 'account',
                    leftImgName: imageName,
                    bottomBorder: true,
                  ),
                  Tile(
                    content: Uri.decodeComponent(
                      widget.account.data.name,
                    ),
                    label: 'Account',
                    leftImage: false,
                    leftImgName: '',
                    bottomBorder: true,
                  ),
                  Tile(
                    content: widget.account.data.secret,
                    label: 'Key',
                    leftImage: false,
                    leftImgName: '',
                    bottomBorder: false,
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 40.0),
              padding: const EdgeInsets.only(left: 18.0, top: 10.0),
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).barBackgroundColor,
                borderRadius: const BorderRadius.all(Radius.circular(13.0)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoTheme.of(context)
                                  .textTheme
                                  .tabLabelTextStyle
                                  .color ??
                              CupertinoColors.opaqueSeparator,
                          width: 0.1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Advanced Options',
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .pickerTextStyle,
                        ),
                        CupertinoSwitch(
                          value: _advancedOptionsOn,
                          onChanged: (bool value) {
                            setState(() {
                              _advancedOptionsOn ? resetOptions() : null;
                              _advancedOptionsOn = !_advancedOptionsOn;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      bottom: 15.0,
                      top: 15.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoTheme.of(context)
                                  .textTheme
                                  .tabLabelTextStyle
                                  .color ??
                              CupertinoColors.opaqueSeparator,
                          width: 0.1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Algorithm',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .pickerTextStyle,
                          ),
                        ),
                        Expanded(
                          child: CupertinoSlidingSegmentedControl(
                            backgroundColor: CupertinoColors.systemGrey2,
                            thumbColor: CupertinoTheme.of(context)
                                    .textTheme
                                    .tabLabelTextStyle
                                    .color ??
                                CupertinoColors.white,
                            // This represents the currently selected segmented control.
                            groupValue: _selectedAlgorithm,
                            // Callback that sets the selected segmented control.
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedAlgorithm = value;
                                  _advancedOptionsOn = true;
                                });
                              }
                            },
                            children: const {
                              'SHA1': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'SHA1',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              'SHA2': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'SHA256',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              'SHA3': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'SHA512',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      bottom: 15.0,
                      top: 15.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoTheme.of(context)
                                  .textTheme
                                  .tabLabelTextStyle
                                  .color ??
                              CupertinoColors.opaqueSeparator,
                          width: 0.1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Digits',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .pickerTextStyle,
                          ),
                        ),
                        Expanded(
                          child: CupertinoSlidingSegmentedControl(
                            backgroundColor: CupertinoColors.systemGrey2,
                            thumbColor: CupertinoTheme.of(context)
                                    .textTheme
                                    .tabLabelTextStyle
                                    .color ??
                                CupertinoColors.white,
                            // This represents the currently selected segmented control.
                            groupValue: _selectedDigitsCount,
                            // Callback that sets the selected segmented control.
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedDigitsCount = value;
                                  _advancedOptionsOn = true;
                                });
                              }
                            },
                            children: const {
                              '6': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  '6',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              '8': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 30),
                                child: Text(
                                  '8',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      right: 10.0,
                      bottom: 15.0,
                      top: 15.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            'Interval (Sec.)',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .pickerTextStyle,
                          ),
                        ),
                        Expanded(
                          child: CupertinoSlidingSegmentedControl(
                            backgroundColor: CupertinoColors.systemGrey2,
                            thumbColor: CupertinoTheme.of(context)
                                    .textTheme
                                    .tabLabelTextStyle
                                    .color ??
                                CupertinoColors.white,
                            // This represents the currently selected segmented control.
                            groupValue: _selectedInterval,
                            // Callback that sets the selected segmented control.
                            onValueChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedInterval = value;
                                  _advancedOptionsOn = true;
                                });
                              }
                            },
                            children: const {
                              '30': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '30',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              '60': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '60',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                              '90': Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '90',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  final String label;
  final String content;
  final bool leftImage;
  final String leftImgName;
  final bool bottomBorder;

  const Tile({
    Key? key,
    required this.content,
    required this.label,
    required this.leftImage,
    required this.leftImgName,
    required this.bottomBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 9.0, bottom: 12.0, left: 7.0),
      decoration: BoxDecoration(
        border: bottomBorder
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
      child: Row(
        children: [
          leftImage
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: leftImgName == 'account'
                      ? const Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 45,
                          color: CupertinoColors.secondaryLabel,
                        )
                      : Image.asset(leftImgName, height: 40, width: 40),
                )
              : const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .color,
                  fontSize: 14,
                ),
              ),
              SizedBox(
                width: 310.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    content,
                    style: CupertinoTheme.of(context).textTheme.pickerTextStyle,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
