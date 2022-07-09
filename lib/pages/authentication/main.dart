import 'package:authenticator/pages/authentication/login.dart';
import 'package:authenticator/pages/authentication/reset_pass.dart';
import 'package:authenticator/pages/authentication/signup.dart';
import 'package:flutter/cupertino.dart';

class Authentication extends StatefulWidget {
  const Authentication({Key? key}) : super(key: key);

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController();
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Authenticator'),
      ),
      child: PageView(
        /// [PageView.scrollDirection] defaults to [Axis.horizontal].
        /// Use [Axis.vertical] to scroll vertically.
        controller: controller,
        children: const <Widget>[
          Center(
            // child: Login(controller: controller),
            child: Login(),
          ),
          Center(
            child: SignUp(),
          ),
          Center(
            child: ResetPassword(),
          )
        ],
      ),
    );
  }
}
