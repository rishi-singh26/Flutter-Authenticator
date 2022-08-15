import 'package:authenticator/modals/totp_acc_modal.dart';
import 'package:authenticator/redux/combined_store.dart';
import 'package:authenticator/redux/store/app.state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:otpauth_migration/otpauth_migration.dart';
import 'package:redux/redux.dart';

class AddAccountResp {
  final bool status;
  final String message;
  const AddAccountResp({
    required this.message,
    required this.status,
  });
}

Future<AddAccountResp> addAccountToFirebase(
  String result,
  Uri uri,
  Function() onSuccess,
) async {
  try {
    Store<AppState> store = await AppStore.getAppStore();

    String issuer = uri.queryParameters.containsKey('issuer')
        ? uri.queryParameters['issuer'].toString()
        : '';
    String host = uri.host;
    String name =
        uri.pathSegments.isNotEmpty ? uri.pathSegments[0].toString() : '';
    String protocol = uri.scheme;
    String secret = uri.queryParameters.containsKey('secret')
        ? uri.queryParameters['secret'].toString()
        : '';
    String algorithm = uri.queryParameters.containsKey('algorithm')
        ? uri.queryParameters['algorithm'].toString()
        : 'SHA1';
    String digits = uri.queryParameters.containsKey('digits')
        ? uri.queryParameters['digits'].toString()
        : '6';
    String period = uri.queryParameters.containsKey('period')
        ? uri.queryParameters['period'].toString()
        : '30';

    TotpAccount account = TotpAccount(
      createdOn: DateTime.now(),
      data: TotpAccountDetail(
        backupCodes: '',
        host: host,
        issuer: issuer,
        name: name,
        protocol: protocol,
        secret: secret,
        tags: [],
        url: result,
      ),
      id: 'id',
      name: issuer.toUpperCase(),
      userId: FirebaseAuth.instance.currentUser?.uid ?? '',
      options: TotpOptions(
        isEnabled: false,
        selectedAlgorithm: algorithm,
        selectedDigitsCount: digits,
        selectedInterval: period,
      ),
      isFavourite: false,
    );
    TotpAccntCryptoResp encryptedAccount = account.encrypt(
      RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
    );
    if (!encryptedAccount.status) {
      return AddAccountResp(message: encryptedAccount.message, status: false);
    }
    await FirebaseFirestore.instance
        .collection('newTotpAccounts')
        .add(encryptedAccount.data.toApiJson());
    onSuccess();
    return const AddAccountResp(message: 'Success', status: true);
  } catch (e) {
    // print(e.toString());
    return AddAccountResp(message: e.toString(), status: false);
  }
}

class DecodeGoogleUriResp {
  final bool status;
  final String message;
  final List<TotpAccount> accounts;
  const DecodeGoogleUriResp({
    required this.message,
    required this.status,
    required this.accounts,
  });
}

Future<DecodeGoogleUriResp> decodeGoogleMigration(String migrationUri) async {
  List<TotpAccount> accounts = [];
  try {
    final OtpAuthMigration otpAuthParser = OtpAuthMigration();
    final String decodedUri = Uri.decodeComponent(migrationUri);
    // print(decodedUri);
    List<String> accountsURIs = otpAuthParser.decode(decodedUri);
    // print(accountsURIs);
    Store<AppState> store = await AppStore.getAppStore();

    for (String accountUri in accountsURIs) {
      final Uri uriComponents = Uri.parse(accountUri);
      String issuer = uriComponents.queryParameters.containsKey('issuer')
          ? uriComponents.queryParameters['issuer'].toString()
          : '';
      String host = uriComponents.host;
      String name = uriComponents.pathSegments.isNotEmpty
          ? uriComponents.pathSegments[0].toString()
          : '';
      String protocol = uriComponents.scheme;
      String secret = uriComponents.queryParameters.containsKey('secret')
          ? uriComponents.queryParameters['secret'].toString()
          : '';
      String algorithm = uriComponents.queryParameters.containsKey('algorithm')
          ? uriComponents.queryParameters['algorithm'].toString()
          : 'SHA1';
      String digits = uriComponents.queryParameters.containsKey('digits')
          ? uriComponents.queryParameters['digits'].toString()
          : '6';
      String period = uriComponents.queryParameters.containsKey('period')
          ? uriComponents.queryParameters['period'].toString()
          : '30';

      TotpAccount account = TotpAccount(
        createdOn: DateTime.now(),
        data: TotpAccountDetail(
          backupCodes: '',
          host: host,
          issuer: issuer,
          name: name,
          protocol: protocol,
          secret: secret,
          tags: [],
          url: accountUri,
        ),
        id: 'id',
        name: issuer.toUpperCase(),
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        options: TotpOptions(
          isEnabled: false,
          selectedAlgorithm: algorithm,
          selectedDigitsCount: digits,
          selectedInterval: period,
        ),
        isFavourite: false,
      );
      TotpAccntCryptoResp accountEncryptionResp = account.encrypt(
        RSAPublicKey.fromPEM(store.state.auth.userData.publicKey),
      );
      accounts.add(accountEncryptionResp.data);
    }
    return DecodeGoogleUriResp(
      message: 'Success',
      status: true,
      accounts: accounts,
    );
  } catch (e) {
    return DecodeGoogleUriResp(
      message: e.toString(),
      status: true,
      accounts: [],
    );
  }
}
