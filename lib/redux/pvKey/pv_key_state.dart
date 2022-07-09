class PrivateKeyState {
  final bool isAttached;
  final String key;
  final String message;
  final String attachedOn;

  PrivateKeyState({
    required this.isAttached,
    required this.key,
    required this.attachedOn,
    required this.message,
  });

  PrivateKeyState.fromJson(json)
      : isAttached = json['isAttached'],
        key = json['key'],
        attachedOn = json['attachedOn'],
        message = json['message'];

  Map<String, dynamic> toJson() => {
        'isAttached': isAttached,
        'key': key,
        'attachedOn': attachedOn,
        'message': message,
      };

  PrivateKeyState.initialState()
      : isAttached = false,
        key = '',
        attachedOn = DateTime.now().toString(),
        message = 'Not attached';

  PrivateKeyState.attachKey(PrivateKeyState prev, String privateKey)
      : isAttached = true,
        key = privateKey,
        attachedOn = DateTime.now().toString(),
        message = 'Successfully attached';

  PrivateKeyState.keyAttachError(PrivateKeyState prev, String error)
      : isAttached = false,
        key = '',
        attachedOn = DateTime.now().toString(),
        message = error;

  PrivateKeyState.detachkey()
      : isAttached = false,
        key = '',
        attachedOn = DateTime.now().toString(),
        message = 'Successfully detached';
}
