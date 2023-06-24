class User {
  final String email;
  final String publicKey;
  final String userId;
  final String pbkdfSalt;
  final String pvtKeySalt;
  final String privateKey;
  User({
    required this.email,
    required this.publicKey,
    required this.userId,
    required this.pbkdfSalt,
    required this.privateKey,
    required this.pvtKeySalt,
  });

  User.defaultValues()
      : email = '',
        publicKey = '',
        userId = '',
        pbkdfSalt = '',
        privateKey = '',
        pvtKeySalt = '';

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        publicKey = json['publicKey'],
        userId = json['userId'],
        pbkdfSalt = json['pbkdfSalt'],
        privateKey = json['privateKey'],
        pvtKeySalt = json['pvtKeySalt'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'publicKey': publicKey,
        'userId': userId,
        'pbkdfSalt': pbkdfSalt,
        'privateKey': privateKey,
        'pvtKeySalt': pvtKeySalt,
      };

  @override
  String toString() =>
      "{'email': $email, 'publicKey': $publicKey, 'userId': $userId, 'pbkdfSalt': $pbkdfSalt, 'privateKey': $privateKey, 'pvtKeySalt': $pvtKeySalt,}";
}
