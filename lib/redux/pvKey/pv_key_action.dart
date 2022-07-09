abstract class PrivateKeyAction {}

class AttachKeyAction extends PrivateKeyAction {
  final String key;

  AttachKeyAction({required this.key});
}

class AttachKeyErrAction extends PrivateKeyAction {
  final String errMess;

  AttachKeyErrAction({required this.errMess});
}

class DetachKeyAction extends PrivateKeyAction {}
