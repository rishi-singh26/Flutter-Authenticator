import 'dart:math';

import 'package:crypton/crypton.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/block/aes.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/padded_block_cipher/padded_block_cipher_impl.dart';
import 'package:pointycastle/paddings/pkcs7.dart';
import 'dart:convert';
import 'package:pointycastle/pointycastle.dart' hide RSAPublicKey, RSAPrivateKey;

class CryptoResult {
  final bool status;
  final String data;
  CryptoResult({required this.data, required this.status});
}

class CryptoService {
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

  static String generateRandomSalt({int length = 16}) {
    final random = Random.secure();
    final saltCodeUnits = List<int>.generate(length, (_) => random.nextInt(256));
    return String.fromCharCodes(saltCodeUnits);
  }

  static Uint8List generatePBKDF(String password, String salt, {int iterations = 10000, int derivedKeyLength = 32}) {
    final passwordBytes = utf8.encode(password);
    final saltBytes = utf8.encode(salt);

    final params = Pbkdf2Parameters(Uint8List.fromList(saltBytes), iterations, derivedKeyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));

    pbkdf2.init(params);

    return pbkdf2.process(Uint8List.fromList(passwordBytes));
  }

  static Uint8List encrypt(Uint8List key, Uint8List iv, Uint8List plaintext) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(true, params);
    return cipher.process(plaintext);
  }

  static Uint8List decrypt(Uint8List key, Uint8List iv, Uint8List ciphertext) {
    final cipher = PaddedBlockCipherImpl(PKCS7Padding(), AESEngine());
    final params = PaddedBlockCipherParameters(
      KeyParameter(key),
      ParametersWithIV<KeyParameter>(KeyParameter(key), iv),
    );
    cipher.init(false, params);
    return cipher.process(ciphertext);
  }
}
