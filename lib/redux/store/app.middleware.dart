
import 'package:redux/redux.dart';
import './app.state.dart';

List<Middleware<AppState>> appMiddleware() {
//   final Middleware<AppState> _login = login(_repo);

return [
    // TypedMiddleware<AppState, LoginAction>(_login),
]; 
}
	