import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

class EnterManually extends StatefulWidget {
  const EnterManually({Key? key}) : super(key: key);

  @override
  State<EnterManually> createState() => _EnterManuallyState();
}

class _EnterManuallyState extends State<EnterManually> {
  bool _advancedOptionsOn = false;
  Object _selectedAlgorithm = 'SHA1';
  Object _selectedDigitsCount = '6';
  Object _selectedInterval = '30';

  late TextEditingController serviceNameController;
  late TextEditingController accountNameController;
  late TextEditingController keyController;
  late TextEditingController backupCodesController;

  resetOptions() {
    setState(() {
      _selectedAlgorithm = 'SHA1';
      _selectedDigitsCount = '6';
      _selectedInterval = '30';
    });
  }

  @override
  void initState() {
    serviceNameController = TextEditingController();
    accountNameController = TextEditingController();
    keyController = TextEditingController();
    backupCodesController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    serviceNameController.dispose();
    accountNameController.dispose();
    keyController.dispose();
    backupCodesController.dispose();
    super.dispose();
  }

  _showDilogue(
    BuildContext context,
    String title,
    String content,
    bool isDestructive,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            child: const Text('Ok'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _validateData(BuildContext context) async {
    String serviceName = serviceNameController.text;
    String accountName = accountNameController.text;
    String secret = keyController.text;
    String host = 'totp';

    if (serviceName.isEmpty) {
      // ignore: use_build_context_synchronously
      _showDilogue(context, 'Alert', 'Enter the service', true);
      return false;
    }

    if (accountName.isEmpty) {
      // ignore: use_build_context_synchronously
      _showDilogue(context, 'Alert', 'Enter the account', true);
      return false;
    }

    if (secret.isEmpty) {
      // ignore: use_build_context_synchronously
      _showDilogue(context, 'Alert', 'Enter the secret', true);
      return false;
    }

    if (_advancedOptionsOn) {
      // ignore: use_build_context_synchronously
      return await showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Alert'),
          content:
              const Text('Advanced options are on, Do you want to continue?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        ),
      );
    }
    return true;
  }

  _onSubmit(BuildContext context) async {
    try {
      Store<AppState> store = await AppStore.getAppStore();
      String serviceName = serviceNameController.text;
      String accountName = accountNameController.text;
      String secret = keyController.text;
      String host = 'totp';

      // ignore: use_build_context_synchronously
      if (!await _validateData(context)) {
        return;
      }
      TotpAccount accntData = TotpAccount(
        createdOn: DateTime.now(),
        data: TotpAccountDetail(
          backupCodes: backupCodesController.text,
          host: host,
          issuer: serviceName,
          name: accountName,
          protocol: 'otpauth',
          secret: secret,
          tags: [],
          url: 'otpauth://totp/$accountName?secret=$secret&issuer=$serviceName',
        ),
        id: '',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        options: TotpOptions(
          isEnabled: _advancedOptionsOn,
          selectedAlgorithm: _selectedAlgorithm,
          selectedDigitsCount: _selectedDigitsCount,
          selectedInterval: _selectedInterval,
        ),
        isFavourite: false,
      );
      TotpAccntCryptoResp encryptionResp = accntData.encrypt(
        RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
      );
      if (!encryptionResp.status) {
        // ignore: use_build_context_synchronously
        _showDilogue(
          context,
          'Alert!',
          'Error occured while encrypting account data',
          true,
        );
      }
      FirebaseFirestore.instance
          .collection('newTotpAccounts')
          .add(encryptionResp.data.toApiJson())
          .then(
            (value) =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
          );
    } catch (e) {
      _showDilogue(
        context,
        'Alert!',
        e.toString(),
        true,
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              border: null,
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerLeft,
                child: const Text('Cancel'),
              ),
              largeTitle: const Text('Manually'),
              trailing: CupertinoButton(
                onPressed: () => _onSubmit(context),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerRight,
                child: const Text('Save'),
              ),
            ),
          ];
        }),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: ListView(
            padding: const EdgeInsets.only(top: 0),
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7.0,
                  top: 25.0,
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
                      label: 'Service',
                      leftImage: false,
                      leftImgName: 'account',
                      bottomBorder: true,
                      txtController: serviceNameController,
                      placeholder: 'ex.: Wikipedia',
                    ),
                    Tile(
                      label: 'Account',
                      leftImage: false,
                      leftImgName: '',
                      bottomBorder: true,
                      txtController: accountNameController,
                      placeholder: 'ex.: user@example.com',
                    ),
                    Tile(
                      label: 'Key',
                      leftImage: false,
                      leftImgName: '',
                      bottomBorder: false,
                      txtController: keyController,
                      placeholder: 'ex.: JSDF33RFSFR389',
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 7.0,
                  top: 25.0,
                  left: 7.0,
                ),
                child: Text(
                  'BACKUP CODES (OPTIONAL)',
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
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(13.0)),
                ),
                child: CupertinoTextField(
                  placeholder:
                      'ex.:\n1) 5500 0251\n2)0021 5987\n3)4207 9510\n4)...',
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    border: null,
                  ),
                  controller: backupCodesController,
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                  maxLines: 5,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30.0),
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
                                'SHA256': Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'SHA256',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 14.0,
                                    ),
                                  ),
                                ),
                                'SHA512': Padding(
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
      ),
    );
  }
}

class Tile extends StatefulWidget {
  final String label;
  final bool leftImage;
  final String leftImgName;
  final bool bottomBorder;
  final String placeholder;
  final TextEditingController txtController;

  const Tile({
    Key? key,
    required this.bottomBorder,
    required this.label,
    required this.leftImage,
    required this.leftImgName,
    required this.placeholder,
    required this.txtController,
  }) : super(key: key);

  @override
  State<Tile> createState() => _TileState();
}

class _TileState extends State<Tile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 9.0, bottom: 12.0, left: 7.0),
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
      child: Row(
        children: [
          widget.leftImage
              ? Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: widget.leftImgName == 'account'
                      ? const Icon(
                          CupertinoIcons.person_crop_circle,
                          size: 45,
                          color: CupertinoColors.secondaryLabel,
                        )
                      : Image.asset(widget.leftImgName, height: 40, width: 40),
                )
              : const SizedBox(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: CupertinoTheme.of(context)
                      .textTheme
                      .tabLabelTextStyle
                      .color,
                  fontSize: 14,
                ),
              ),
              Container(
                width: 250,
                height: 25,
                margin: const EdgeInsets.only(top: 5),
                child: CupertinoTextField(
                  placeholder: widget.placeholder,
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: CupertinoTheme.of(context).barBackgroundColor,
                    border: null,
                  ),
                  controller: widget.txtController,
                  style: CupertinoTheme.of(context).textTheme.textStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
