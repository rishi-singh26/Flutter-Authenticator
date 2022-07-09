import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypton/crypton.dart';

class TotpAccount {
  final String id;
  final String userId;
  final DateTime createdOn;
  final TotpAccountDetail data;
  final TotpOptions options;
  final bool isFavourite;

  TotpAccount({
    required this.createdOn,
    required this.data,
    required this.id,
    required this.userId,
    required this.options,
    required this.isFavourite,
  });

  static DateTime _firebaseDateToDate(Timestamp date) {
    // print('Here id date from firebase in Farmer modal$date');
    return DateTime.fromMillisecondsSinceEpoch(date.seconds * 1000);
  }

  TotpAccount.defaultValues()
      : createdOn = DateTime.now(),
        data = TotpAccountDetail.defaultValues(),
        id = '',
        userId = '',
        options = TotpOptions.defaultValues(),
        isFavourite = false;

  TotpAccount.fromJson(Map<String, dynamic> json, String docId)
      : createdOn = _firebaseDateToDate(json['createdOn']),
        data = TotpAccountDetail.fromJson(json['data']),
        id = docId,
        userId = json['userId'],
        options = json.containsKey('options')
            ? TotpOptions.fromJson(json['options'])
            : TotpOptions.defaultValues(),
        isFavourite = json['isFavourite'];

  // TotpAccout.fromFireStoreQuerySnapShot(QuerySnapshot snap)
  // : _id = snap.docs.first.id,
  //   aadhar = snap.docs.first.get('aadhar'),
  //   aadharLinkMessage = snap.docs.first.get('aadharLinkMessage'),
  //   aadharLinkStatus = snap.docs.first.get('aadharLinkStatus'),
  //   accessLevel = snap.docs.first.get('accessLevel'),
  //   fullName = snap.docs.first.get('fullName'),
  //   userId = snap.docs.first.get('userId'),
  //   farmerDocument = snap.docs.first.get('farmerDocument'),
  //   email = snap.docs.first.get('email'),
  //   photoURL = snap.docs.first.get('photoURL'),
  //   emailVerified = snap.docs.first.get('emailVerified'),
  //   signUpDate = _firebaseDateToDate(snap.docs.first.get('signUpDate')),
  //   isAdmin = snap.docs.first.get('isAdmin'),
  //   phoneNumber = snap.docs.first.get('phoneNumber'),
  //   subUsers = _formArrayStringJsonToList(snap.docs.first.get('subUsers')),
  //   adminId = snap.docs.first.get('adminId');

  Map<String, dynamic> toJson() => {
        'createdOn': createdOn,
        'data': data.toJson(),
        'id': id,
        'userId': userId,
        'options': options.toJson(),
        'isFavourite': isFavourite,
      };

  Map<String, dynamic> toApiJson() => {
        'createdOn': createdOn,
        'data': data.toJson(),
        'userId': userId,
        'options': options.toJson(),
        'isFavourite': isFavourite,
      };

  @override
  String toString() =>
      "{'createdOn': $createdOn, 'data': ${data.toString()}, 'userId': $userId, 'options': ${options.toString()}, 'isFavourite': $isFavourite}";

  TotpAccntCryptoResp encrypt(RSAPublicKey key) {
    try {
      TotpAccntDetailCryptoOprResp encryptedResp = data.encrypt(key);

      if (!encryptedResp.status) {
        return TotpAccntCryptoResp(
          data: TotpAccount.defaultValues(),
          message: encryptedResp.message,
          status: false,
        );
      }

      return TotpAccntCryptoResp(
        data: TotpAccount(
          createdOn: createdOn,
          data: encryptedResp.data,
          id: id,
          userId: userId,
          options: options,
          isFavourite: isFavourite,
        ),
        message: 'Success',
        status: true,
      );
    } catch (e) {
      return TotpAccntCryptoResp(
        data: TotpAccount.defaultValues(),
        message: e.toString(),
        status: false,
      );
    }
  }

  TotpAccntCryptoResp decrypt(RSAPrivateKey key) {
    try {
      TotpAccntDetailCryptoOprResp decryptedResp = data.decrypt(key);

      if (!decryptedResp.status) {
        return TotpAccntCryptoResp(
          data: TotpAccount.defaultValues(),
          message: decryptedResp.message,
          status: false,
        );
      }
      return TotpAccntCryptoResp(
        data: TotpAccount(
          createdOn: createdOn,
          data: decryptedResp.data,
          id: id,
          userId: userId,
          options: options,
          isFavourite: isFavourite,
        ),
        message: 'Success',
        status: true,
      );
    } catch (e) {
      return TotpAccntCryptoResp(
        data: TotpAccount.defaultValues(),
        message: e.toString(),
        status: false,
      );
    }
  }
}

class TotpAccountDetail {
  final String host;
  final String issuer;
  final String name;
  final String protocol;
  final String secret;
  final String url;
  final List<String> tags;
  final String backupCodes;

  TotpAccountDetail({
    required this.backupCodes,
    required this.host,
    required this.issuer,
    required this.name,
    required this.protocol,
    required this.secret,
    required this.tags,
    required this.url,
  });

  static List<String> _formJsonlistToList(json) {
    try {
      List<String> list = [];
      for (var item in json) {
        list.add(item);
      }
      return list;
    } catch (e) {
      // print(
      //   'Error in convertion json to list in farmer modal: ${e.toString()}',
      // );
      return [];
    }
  }

  TotpAccountDetail.defaultValues()
      : backupCodes = '',
        host = '',
        issuer = '',
        name = '',
        protocol = '',
        secret = '',
        tags = [],
        url = '';

  TotpAccountDetail.fromJson(Map<String, dynamic> json)
      : backupCodes = json['backupCodes'],
        host = json['host'],
        issuer = json['issuer'],
        name = json['name'],
        protocol = json['protocol'],
        secret = json['secret'],
        tags =
            json.containsKey('tags') ? _formJsonlistToList(json['tags']) : [],
        url = json['url'];

  Map<String, dynamic> toJson() => {
        'backupCodes': backupCodes,
        'host': host,
        'issuer': issuer,
        'name': name,
        'protocol': protocol,
        'secret': secret,
        'tags': tags,
        'url': url,
      };

  @override
  String toString() =>
      "{'backupCodes': $backupCodes, 'host': $host, 'issuer': $issuer, 'name:: $name 'protocol': $protocol, 'secret': $secret, 'tags': $tags, 'url': $url}";

  TotpAccntDetailCryptoOprResp encrypt(RSAPublicKey key) {
    try {
      String encryptedSecret = key.encrypt(secret);
      String encryptedUrl = key.encrypt(url);
      String encryptedBackupCodes = key.encrypt(backupCodes);
      return TotpAccntDetailCryptoOprResp(
        data: TotpAccountDetail(
          backupCodes: encryptedBackupCodes,
          host: host,
          issuer: issuer,
          name: name,
          protocol: protocol,
          secret: encryptedSecret,
          tags: tags,
          url: encryptedUrl,
        ),
        message: 'Success',
        status: true,
      );
    } catch (e) {
      return TotpAccntDetailCryptoOprResp(
        data: TotpAccountDetail.defaultValues(),
        message: e.toString(),
        status: false,
      );
    }
  }

  TotpAccntDetailCryptoOprResp decrypt(RSAPrivateKey key) {
    try {
      String decryptedSecret = key.decrypt(secret);
      String decryptedUrl = key.decrypt(url);
      String decryptedBackupCodes = key.decrypt(backupCodes);
      return TotpAccntDetailCryptoOprResp(
        data: TotpAccountDetail(
          backupCodes: decryptedBackupCodes,
          host: host,
          issuer: issuer,
          name: name,
          protocol: protocol,
          secret: decryptedSecret,
          tags: tags,
          url: decryptedUrl,
        ),
        message: 'Success',
        status: true,
      );
    } catch (e) {
      return TotpAccntDetailCryptoOprResp(
        data: TotpAccountDetail.defaultValues(),
        message: e.toString(),
        status: false,
      );
    }
  }
}

class TotpOptions {
  final bool isEnabled;
  final Object selectedAlgorithm;
  final Object selectedDigitsCount;
  final Object selectedInterval;

  TotpOptions({
    required this.isEnabled,
    required this.selectedAlgorithm,
    required this.selectedDigitsCount,
    required this.selectedInterval,
  });

  TotpOptions.defaultValues()
      : isEnabled = false,
        selectedAlgorithm = 'SHA1',
        selectedDigitsCount = '6',
        selectedInterval = '30';

  TotpOptions.fromJson(Map<String, dynamic> json)
      : isEnabled = json['isEnabled'],
        selectedAlgorithm = json['selectedAlgorithm'],
        selectedDigitsCount = json['selectedDigitsCount'],
        selectedInterval = json['selectedInterval'];

  Map<String, dynamic> toJson() => {
        'isEnabled': isEnabled,
        'selectedAlgorithm': selectedAlgorithm,
        'selectedDigitsCount': selectedDigitsCount,
        'selectedInterval': selectedInterval,
      };

  @override
  String toString() =>
      "{'isEnabled': $isEnabled, 'selectedAlgorithm': $selectedAlgorithm, 'selectedDigitsCount:: $selectedDigitsCount 'selectedInterval': $selectedInterval}";
}

class TotpAccntCryptoResp {
  final bool status;
  final String message;
  final TotpAccount data;

  TotpAccntCryptoResp({
    required this.data,
    required this.message,
    required this.status,
  });
}

class TotpAccntDetailCryptoOprResp {
  final bool status;
  final String message;
  final TotpAccountDetail data;

  TotpAccntDetailCryptoOprResp({
    required this.data,
    required this.message,
    required this.status,
  });
}
