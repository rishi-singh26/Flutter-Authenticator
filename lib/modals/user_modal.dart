class User {
  final String email;
  final String publicKey;
  final String userId;
  User({required this.email, required this.publicKey, required this.userId});

  User.defaultValues()
      : email = '',
        publicKey = '',
        userId = '';

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        publicKey = json['publicKey'],
        userId = json['userId'];

  Map<String, dynamic> toJson() => {
        'email': email,
        'publicKey': publicKey,
        'userId': userId,
      };

  @override
  String toString() =>
      "{'email': $email, 'publicKey': $publicKey, 'userId': $userId}";
}
