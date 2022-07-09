import 'package:authenticator/redux/pvKey/pv_key_action.dart';
import 'package:authenticator/redux/pvKey/pv_key_state.dart';
import 'package:redux/redux.dart';

Reducer<PrivateKeyState> privateKeyReducers = combineReducers(
    [attachPvKeyreducer, attachPvKeyErrReducer, detachPvKeyReducer]);

// Attach key
PrivateKeyState attachPvKeyreducer(PrivateKeyState prevState, dynamic action) {
  if (action is AttachKeyAction) {
    return PrivateKeyState.attachKey(prevState, action.key);
  }
  return prevState;
}

// Attach key Error
PrivateKeyState attachPvKeyErrReducer(
    PrivateKeyState prevState, dynamic action) {
  if (action is AttachKeyErrAction) {
    return PrivateKeyState.keyAttachError(prevState, action.errMess);
  }
  return prevState;
}

// Detach key
PrivateKeyState detachPvKeyReducer(PrivateKeyState prevState, dynamic action) {
  if (action is DetachKeyAction) {
    return PrivateKeyState.detachkey();
  }
  return prevState;
}
