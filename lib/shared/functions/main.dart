String getImageName(String issuer) {
  if (issuer.toLowerCase().contains('discord')) {
    return 'images/discord.png';
  }
  if (issuer.toLowerCase().contains('google')) {
    return 'images/google.png';
  }
  if (issuer.toLowerCase().contains('github')) {
    return 'images/github.png';
  }
  if (issuer.toLowerCase().contains('twitter')) {
    return 'images/twitter.png';
  }
  if (issuer.toLowerCase().contains('npm')) {
    return 'images/npm.png';
  }
  if (issuer.toLowerCase().contains('mega')) {
    return 'images/mega.png';
  }
  if (issuer.toLowerCase().contains('heroku')) {
    return 'images/heroku.png';
  }
  if (issuer.toLowerCase().contains('mongodb')) {
    return 'images/mongodb.png';
  }
  if (issuer.toLowerCase().contains('algolia')) {
    return 'images/algolia.png';
  }
  if (issuer.toLowerCase().contains('instagram')) {
    return 'images/instagram.png';
  }
  if (issuer.toLowerCase().contains('samsung')) {
    return 'images/samsung.png';
  }
  if (issuer.toLowerCase().contains('figma')) {
    return 'images/figma.png';
  }
  if (issuer.toLowerCase().contains('slack')) {
    return 'images/slack.png';
  }
  return 'account';
}

/// Check if [n] is power of 2
///
/// 23 => false
///
/// 24 => false
///
/// 32 => true
bool isPowerOfTwo(int n) {
  double num = n.toDouble();
  if (num == 0) return false;
  while (num != 1) {
    if (num % 2 != 0) return false;
    num = num / 2;
  }
  return true;
}

/// Get highest power of 2 smaller than or equal to [n].
///
/// IP = 37; OP = 32;
///
/// IP = 23; OP = 16;
int highestPowerof2(int n) {
  int res = 0;
  for (int i = n; i >= 1; i--) {
    if ((i & (i - 1)) == 0) {
      res = i;
      break;
    }
  }
  return res;
}

/// Split a string in half
///
/// I/P = '123456'; O/P = '123 456'
///
/// I/P = '1234567'; O/P = '123 4567'
///
/// I/P = '12345678'; O/P = '1234 5678'
String splitStringInHalf(String str) {
  return '${str.substring(0, (str.length / 2).floor())} ${str.substring((str.length / 2).floor())}';
}

/// Remove spaces from a string
///
/// IP = '123 456'; OP = '123456';
String stripSpaces(String str) {
  return str.replaceAll(' ', '');
}

/// Return the next multiple of eight for the given [num]
///
/// IP = 50; OP = 56;
///
/// IP = 21; OP = 24;
int nextMultipleOfEight(int num) {
  int result = -1;
  for (int i = num; i < num + 8; i++) {
    if (i % 8 == 0) {
      result = i;
      return result;
    }
  }
  return result;
}
