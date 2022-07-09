import 'package:crypton/crypton.dart';

class CryptoResult {
  final bool status;
  final String data;
  CryptoResult({required this.data, required this.status});
}

class Encrypt {
  static RSAKeypair getKeyPair() {
    RSAKeypair rsaKeypair = RSAKeypair.fromRandom();
    return rsaKeypair;
  }

  static CryptoResult encryptText(String text, RSAPublicKey pubKey) {
    try {
      String encrypted = pubKey.encrypt(text);
      return CryptoResult(data: encrypted, status: true);
    } catch (err) {
      // print(err.toString());
      return CryptoResult(data: err.toString(), status: false);
    }
  }

  static CryptoResult decryptText(String encodedTxt, RSAPrivateKey pvKey) {
    try {
      String decoded = pvKey.decrypt(encodedTxt);
      return CryptoResult(data: decoded, status: true);
    } catch (err) {
      // print(err.toString());
      return CryptoResult(data: err.toString(), status: false);
    }
  }
}
