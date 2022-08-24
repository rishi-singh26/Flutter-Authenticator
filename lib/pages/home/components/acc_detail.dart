import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:authenticator/shared/components/advanced_options.dart';
import 'package:authenticator/shared/functions/file_system.dart';
import 'package:authenticator/shared/functions/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';

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
  bool _isFavourite = false;
  _setIsFavourite(bool val) => setState(() => _isFavourite = val);
  bool _backupCodesReadOnly = true;
  _setBackupCodeReadOnly(bool val) =>
      setState(() => _backupCodesReadOnly = val);
  int _backupCodesLines = 5;
  _setBackupCodeLines(int val) => setState(() => _backupCodesLines = val);
  bool _showLoader = false;
  _setLoader(bool val) => setState(() => _showLoader = val);

  late TextEditingController backupCodesController;

  _resetOptions() {
    setState(() {
      _selectedAlgorithm = 'SHA1';
      _selectedDigitsCount = '6';
      _selectedInterval = '30';
    });
  }

  _backupCodesEditOrReset() {
    if (_backupCodesReadOnly) {
      _setBackupCodeReadOnly(false);
    } else {
      backupCodesController.text = widget.account.data.backupCodes;
      _setBackupCodeReadOnly(true);
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

  Future<bool> _confirmAdvancedOptions(BuildContext context) async {
    if (_advancedOptionsOn) {
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
      String serviceName = widget.account.data.issuer;
      String accountName = widget.account.data.name;
      String secret = widget.account.data.secret;
      String host = 'totp';

      // ignore: use_build_context_synchronously
      if (!await _confirmAdvancedOptions(context)) {
        _setLoader(false);
        return;
      }
      TotpAccount accntData = TotpAccount(
        createdOn: widget.account.createdOn,
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
      // print(accntData.isFavourite);
      TotpAccntCryptoResp encryptionResp = accntData.encrypt(
        RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
      );
      // print(encryptionResp.data.isFavourite);
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
          .doc(widget.account.id)
          .update(encryptionResp.data.toApiJson())
          .then(
            (value) =>
                Navigator.canPop(context) ? Navigator.pop(context) : null,
          )
          .catchError((err) {
        _setLoader(false);
        _showDilogue(context, 'Alert!', err.toString(), true);
      });
    } catch (e) {
      _setLoader(false);
      _showDilogue(context, 'Alert!', e.toString(), true);
      return;
    }
  }

  @override
  void initState() {
    backupCodesController = TextEditingController();
    backupCodesController.text = widget.account.data.backupCodes;
    _backupCodesLines = widget.account.data.backupCodes.split('\n').length;
    _isFavourite = widget.account.isFavourite;
    TotpOptions options = widget.account.options;
    _advancedOptionsOn = options.isEnabled;
    _selectedAlgorithm = options.selectedAlgorithm;
    _selectedDigitsCount = options.selectedDigitsCount;
    _selectedInterval = options.selectedInterval;
    super.initState();
  }

  @override
  void dispose() {
    backupCodesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String imageName = getImageName(widget.account.data.issuer);
    TextStyle labelStyle = TextStyle(
      color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
      fontSize: 14,
    );
    final bool hasEditedBackupCodes =
        widget.account.data.backupCodes != backupCodesController.text;
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
              largeTitle: const Text('Edit Account'),
              trailing: CupertinoButton(
                onPressed: _showLoader ? null : () => _onSubmit(context),
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
                padding: const EdgeInsets.only(top: 20.0, left: 7.0, bottom: 7),
                child: Text('BASE OPTIONS  (UNEDITABLE)', style: labelStyle),
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
                    _Tile(
                      content: widget.account.data.issuer,
                      label: 'Service',
                      leftImage: imageName != 'account',
                      leftImgName: imageName,
                      bottomBorder: true,
                    ),
                    _Tile(
                      content: Uri.decodeComponent(
                        widget.account.data.name,
                      ),
                      label: 'Account',
                      leftImage: false,
                      leftImgName: '',
                      bottomBorder: true,
                    ),
                    _Tile(
                      content: widget.account.data.secret,
                      label: 'Key',
                      leftImage: false,
                      leftImgName: '',
                      bottomBorder: false,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 7.0, bottom: 7),
                child: Text('BACKUP CODES (OPTIONAL)', style: labelStyle),
              ),
              Container(
                padding: const EdgeInsets.all(15.0),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(13.0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _BackupCodeBtn(
                          onPress: _backupCodesEditOrReset,
                          title: 'Edit',
                          showButton: _backupCodesReadOnly,
                        ),
                        _BackupCodeBtn(
                          onPress: _backupCodesEditOrReset,
                          title: 'Reset',
                          showButton: hasEditedBackupCodes,
                        ),
                        _BackupCodeBtn(
                          onPress: _pickBackupCodesFromFile,
                          title: 'Pick File (.txt)',
                          showButton: true,
                        ),
                      ],
                    ),
                    CupertinoTextField(
                      placeholder: 'ex.: 55000251 00215987 42079510...',
                      padding: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(border: null),
                      controller: backupCodesController,
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                      maxLines: _backupCodesLines,
                      readOnly: _backupCodesReadOnly,
                      onChanged: (value) => setState(() {}),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30.0),
                padding: const EdgeInsets.only(left: 18.0, top: 10.0),
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).barBackgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(13.0)),
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
                    _advancedOptionsOn ? _resetOptions() : null;
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
      ),
    );
  }
}

class _BackupCodeBtn extends StatelessWidget {
  final Function() onPress;
  final String title;
  final bool showButton;
  const _BackupCodeBtn({
    Key? key,
    required this.onPress,
    required this.title,
    required this.showButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showButton) {
      return const SizedBox();
    }
    return SizedBox(
      height: 30,
      child: CupertinoButton(
        padding: const EdgeInsets.only(bottom: 10, right: 10),
        alignment: Alignment.centerRight,
        onPressed: onPress,
        child: Text(title),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final String label;
  final String content;
  final bool leftImage;
  final String leftImgName;
  final bool bottomBorder;

  const _Tile({
    Key? key,
    required this.bottomBorder,
    required this.content,
    required this.label,
    required this.leftImage,
    required this.leftImgName,
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
                style: CupertinoTheme.of(context)
                    .textTheme
                    .tabLabelTextStyle
                    .copyWith(fontSize: 14),
              ),
              SizedBox(
                width: 310.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: Text(
                    content,
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .pickerTextStyle
                        .copyWith(fontSize: 18),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    maxLines: 2,
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
