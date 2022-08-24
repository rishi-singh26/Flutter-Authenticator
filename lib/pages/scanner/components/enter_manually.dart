import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/shared/components/advanced_options.dart';
import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/functions/file_system.dart';
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
  int _backupCodesLines = 5;
  bool _showLoader = false;
  _setLoader(bool val) => setState(() => _showLoader = val);
  _setBackupCodeLines(int val) => setState(() => _backupCodesLines = val);
  bool _isFavourite = false;
  _setIsFavourite(bool val) => setState(() => _isFavourite = val);

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
      _setLoader(true);
      Store<AppState> store = await AppStore.getAppStore();
      String serviceName = serviceNameController.text;
      String accountName = accountNameController.text;
      String secret = keyController.text;
      String host = 'totp';

      // ignore: use_build_context_synchronously
      if (!await _validateData(context)) {
        _setLoader(false);
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
          url:
              'otpauth://totp/$accountName?issuer=$serviceName&secret=${secret.toUpperCase()}&period=$_selectedInterval&digits=$_selectedDigitsCount&algorithm=$_selectedAlgorithm',
        ),
        id: '',
        name: serviceName,
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        options: TotpOptions(
          isEnabled: _advancedOptionsOn,
          selectedAlgorithm: _selectedAlgorithm,
          selectedDigitsCount: _selectedDigitsCount,
          selectedInterval: _selectedInterval,
        ),
        isFavourite: _isFavourite,
      );
      // print(accntData.data.url);
      TotpAccntCryptoResp encryptionResp = accntData.encrypt(
        RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
      );
      if (!encryptionResp.status) {
        _setLoader(false);
        // ignore: use_build_context_synchronously
        _showDilogue(
          context,
          'Alert!',
          'Error occured while encrypting account data',
          true,
        );
        return;
      }
      FirebaseFirestore.instance
          .collection('newTotpAccounts')
          .add(encryptionResp.data.toApiJson())
          .then(
            (value) =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
          );
    } catch (e) {
      _setLoader(false);
      _showDilogue(context, 'Alert!', e.toString(), true);
      return;
    }
  }

  _pickBackupCodesFromFile() async {
    try {
      PickFileResp filePickResp = await FS.pickSingleFile(['txt']);
      if (!filePickResp.status) {
        return;
      }
      ReadFileAsLineResp readFileResp =
          await FS.readFileLines(filePickResp.file);
      if (!readFileResp.status) {
        return;
      }
      backupCodesController.text = readFileResp.contents.join('\n');
      _setBackupCodeLines(readFileResp.contents.length);
    } catch (e) {
      return;
    }
  }

  _clearBackupCodes() {
    backupCodesController.text = '';
    _backupCodesLines = 5;
  }

  @override
  void initState() {
    serviceNameController = TextEditingController();
    accountNameController = TextEditingController();
    keyController = TextEditingController();
    backupCodesController = TextEditingController();
    backupCodesController.addListener(() => setState(() {}));
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

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = TextStyle(
      color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
      fontSize: 14,
    );
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
                onPressed: _showLoader ? null : () => _onSubmit(context),
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerRight,
                child: const Text('Save'),
              ),
            ),
          ];
        }),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 7.0,
                      top: 25.0,
                      left: 7.0,
                    ),
                    child: Text('BASE OPTIONS', style: labelStyle),
                  ),
                  Container(
                    padding: const EdgeInsets.only(
                      left: 12.0,
                      top: 8.0,
                      bottom: 8.0,
                    ),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(13.0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Tile(
                          label: 'Service',
                          leftImage: false,
                          leftImgName: 'account',
                          bottomBorder: true,
                          txtController: serviceNameController,
                          placeholder: 'ex.: Wikipedia',
                        ),
                        _Tile(
                          label: 'Account',
                          leftImage: false,
                          leftImgName: '',
                          bottomBorder: true,
                          txtController: accountNameController,
                          placeholder: 'ex.: user@example.com',
                        ),
                        _Tile(
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
                    child: Text('BACKUP CODES (OPTIONAL)', style: labelStyle),
                  ),
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(13.0)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (backupCodesController.text.isNotEmpty)
                              SizedBox(
                                height: 30,
                                child: CupertinoButton(
                                  padding: const EdgeInsets.only(
                                    bottom: 10,
                                    right: 10,
                                  ),
                                  alignment: Alignment.centerRight,
                                  onPressed: _clearBackupCodes,
                                  child: const Text('Clear'),
                                ),
                              )
                            else
                              const SizedBox.shrink(),
                            SizedBox(
                              height: 30,
                              child: CupertinoButton(
                                padding: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.centerRight,
                                onPressed: _pickBackupCodesFromFile,
                                child: const Text('Pick File (.txt)'),
                              ),
                            ),
                          ],
                        ),
                        CupertinoTextField(
                          placeholder:
                              'ex.:\n1) 5500 0251\n2)0021 5987\n3)4207 9510\n4)...',
                          padding: const EdgeInsets.only(bottom: 2),
                          decoration: const BoxDecoration(border: null),
                          controller: backupCodesController,
                          style: CupertinoTheme.of(context).textTheme.textStyle,
                          maxLines: _backupCodesLines,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 30.0),
                    padding: const EdgeInsets.only(left: 18.0, top: 10.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(13.0)),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Favourite',
                            style: CupertinoTheme.of(context)
                                .textTheme
                                .pickerTextStyle,
                          ),
                          CupertinoSwitch(
                            value: _isFavourite,
                            onChanged: (bool value) => _setIsFavourite(value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AdvancedOptions(
                    advancedOptionsOn: _advancedOptionsOn,
                    selectedAlgorithm: _selectedAlgorithm,
                    selectedDigitsCount: _selectedDigitsCount,
                    selectedInterval: _selectedInterval,
                    setAdvancedOptions: (bool value) {
                      setState(() {
                        _advancedOptionsOn ? resetOptions() : null;
                        _advancedOptionsOn = !_advancedOptionsOn;
                      });
                    },
                    setAlgorithm: (value) {
                      setState(() {
                        _selectedAlgorithm = value;
                        _advancedOptionsOn = true;
                      });
                    },
                    setDigits: (value) {
                      setState(() {
                        _selectedDigitsCount = value;
                        _advancedOptionsOn = true;
                      });
                    },
                    setPeriod: (value) {
                      setState(() {
                        _selectedInterval = value;
                        _advancedOptionsOn = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 12.0,
                top: 5.0,
              ),
              child: BottomButtons(currentPage: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final bool leftImage;
  final String leftImgName;
  final bool bottomBorder;
  final String placeholder;
  final TextEditingController txtController;

  const _Tile({
    Key? key,
    required this.bottomBorder,
    required this.label,
    required this.leftImage,
    required this.leftImgName,
    required this.placeholder,
    required this.txtController,
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
              Container(
                width: 250,
                height: 25,
                margin: const EdgeInsets.only(top: 5),
                child: CupertinoTextField(
                  placeholder: placeholder,
                  padding: const EdgeInsets.only(bottom: 2),
                  decoration: const BoxDecoration(border: null),
                  controller: txtController,
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
