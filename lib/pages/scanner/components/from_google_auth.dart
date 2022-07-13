import 'package:flutter/cupertino.dart';
// import 'package:otpauth_migration/otpauth_migration.dart';

class FromGoogleAuth extends StatefulWidget {
  const FromGoogleAuth({Key? key}) : super(key: key);

  @override
  State<FromGoogleAuth> createState() => _FromGoogleAuthState();
}

class _FromGoogleAuthState extends State<FromGoogleAuth> {
  _decode() {
    try {
      // final OtpAuthMigration otpAuthParser = OtpAuthMigration();
      // List<String> otp_uris = otpAuthParser.decode(
      //   // urlDecoded,
      //   'otpauth-migration://offline?data=CiQKCAAAAAwOAA5FEgtyaXNoaS1zaW5naBoFQXBwbGUgASgBMAIQARgBIAAo2pOLmvz%2F%2F%2F%2F%2FAQ%3D%3D',
      //   // "otpauth-migration://offline?data=CjEKCkhlbGxvId6tvu8SGEV4YW1wbGU6YWxpY2VAZ29vZ2xlLmNvbRoHRXhhbXBsZTAC",
      // );
      // print(otp_uris);
      // otp_uris = ["otpauth://totp/Example:alice@google.com?secret=JBSWY3DPEHPK3PXP&issuer=Example"]);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: NestedScrollView(
        headerSliverBuilder: ((context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              border: null,
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                padding: const EdgeInsets.all(0.0),
                alignment: Alignment.centerLeft,
                child: const Text('Cancel'),
              ),
              largeTitle: const Text('From Google'),
            ),
          ];
        }),
        body: SingleChildScrollView(
          child: Column(
            children: [
              CupertinoButton.filled(
                onPressed: _decode,
                child: const Text('Decode'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
