import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class OTPService {
  static String generateTOTP(secret, [int interval = 30, int codeLength = 6]) {
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    int counter = currentTimestamp ~/ interval;
    String counterHex = counter.toRadixString(16).padLeft(16, '0');

    List<int> decodedKey = base32.decode(secret);
    List<int> hmacSha1Bytes = Hmac(sha1, decodedKey).convert(utf8.encode(counterHex)).bytes;
    int offset = hmacSha1Bytes.last & 0xf;
    int otp = ((hmacSha1Bytes[offset] & 0x7f) << 24) |
        ((hmacSha1Bytes[offset + 1] & 0xff) << 16) |
        ((hmacSha1Bytes[offset + 2] & 0xff) << 8) |
        (hmacSha1Bytes[offset + 3] & 0xff);

    String totpCode = (otp % pow(10, codeLength)).toString().padLeft(codeLength, '0');
    return totpCode;
  }
}
