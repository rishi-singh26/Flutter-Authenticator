import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:base32/base32.dart';

class OTP {
  static int millisecondsSinceEpoch = 0;

  static int generateTOTPCode(String secret, int time, {int length = 6}) {
    time = (((time ~/ 1000).round()) ~/ 30).floor();
    //time = (time ~/30).floor();
    millisecondsSinceEpoch = time;
    return _generateCode(secret, time, length);
  }

  static int generateHOTPCode(String secret, int counter, {int length = 6}) {
    return _generateCode(secret, counter, length);
  }

  static int _generateCode(String secret, int time, int length) {
    length = (length <= 8 && length > 0) ? length : 6;

    var secretList = base32.decode(secret);
    var timebytes = _int2bytes(time);

    var hmac = Hmac(sha1, secretList);
    var hash = hmac.convert(timebytes).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) |
        ((hash[offset + 1] & 0xff) << 16) |
        ((hash[offset + 2] & 0xff) << 8) |
        (hash[offset + 3] & 0xff);
    // NOTE: casting here
    return binary % pow(10, length) as int;
  }

  static String randomSecret() {
    var rand = Random();
    // NOTE: Static list size
    var bytes = Uint8List(10);

    for (int i = 0; i < 10; i++) {
      bytes.add(rand.nextInt(256));
    }

    return base32.encode(bytes);
  }

  // static String _dec2hex(int s) {
  //   var st = s.round().toRadixString(16);
  //   return (st.length % 2 == 0) ? st : '0$st';
  // }

  // static String _leftpad(String str, int len, String pad) {
  //   var padded = '';
  //   for (int i = str.length; i < len; i++) {
  //     padded = padded + pad;
  //   }
  //   return padded + str;
  // }

  // static List _hex2bytes(hex) {
  //   List bytes = Uint8List(hex.length ~/ 2);
  //   for (int i = 0; i < hex.length; i += 2) {
  //     var hexBit = "0x${hex[i]}${hex[i + 1]}";
  //     int parsed = int.parse(hexBit);
  //     bytes[i ~/ 2] = parsed;
  //   }
  //   return bytes;
  // }

  static List<int> _int2bytes(int long) {
    // we want to represent the input as a 8-bytes array
    var byteArray = [0, 0, 0, 0, 0, 0, 0, 0];
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }

  // static int _bytes2int(/*byte[]*/ byteArray) {
  //   var value = 0;
  //   for (var i = byteArray.length - 1; i >= 0; i--) {
  //     // NOTE: casting here
  //     value = (value * 256) + byteArray[i] as int;
  //   }
  //   return value;
  // }

  static int remainingSeconds({int interval = 30}) {
    return interval -
        (((millisecondsSinceEpoch ~/ 1000).round()) % interval).floor();
  }
}

// class TOTP {
//   static dec2hex(int s) {
//     return "${s < 15.5 ? '0' : ''}s.round().toString(16)";
//   }

//   static hex2dec(String s) {
//     return int.parse(s, radix: 16);
//   }

//   static leftpad(String s, int l, String p) {
//     if (l + 1 >= s.length) {
//       s = List.generate(l + 1 - s.length, (index) => '').join(p) + s;
//     }
//     return s;
//   }

//   static base32tohex(base32) {
//     String base32chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567";
//     String bits = "";
//     String hex = "";
//     for (int i = 0; i < base32.length; i++) {
//       var val = base32chars.indexOf(base32[i].toUpperCase());
//       bits += leftpad(val.toString(), 5, '0');
//     }
//     for (var i = 0; i + 4 <= bits.length; i += 4) {
//       var chunk = bits.substring(i, 4);
//       hex = hex + int.parse(chunk, radix: 2).toString();
//     }
//     return hex;
//   }

//   static OTPResponse getOTP(secret) {
//     try {
//       var epoch = (DateTime.now().millisecondsSinceEpoch / 1000.0).round();
//       var time = leftpad(dec2hex((epoch / 30).round()), 16, "0");
//       var hmacObj = Hmac(time, "HEX");
//       var hmac = hmacObj.getHMAC(base32tohex(secret), "HEX", "SHA-1", "HEX");
//       var offset = hex2dec(hmac.substring(hmac.length - 1));
//       var otp =
//           (hex2dec(hmac.substr(offset * 2, 8)) & hex2dec("7fffffff")) + "";
//       otp = (otp).substr(otp.length - 6, 6);
//       return OTPResponse(status: true, otp: otp);
//     } catch (error) {
//       return OTPResponse(status: false, otp: error.toString());
//     }
//   }
// }

// class OTPResponse {
//   final bool status;
//   final String otp;

//   OTPResponse({required this.status, required this.otp});
// }
