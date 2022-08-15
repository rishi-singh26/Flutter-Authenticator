import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/pages/scanner/main.dart';
import 'package:flutter/cupertino.dart';

class FromGoogleAuth extends StatefulWidget {
  const FromGoogleAuth({Key? key}) : super(key: key);

  @override
  State<FromGoogleAuth> createState() => _FromGoogleAuthState();
}

class _FromGoogleAuthState extends State<FromGoogleAuth> {
  TextStyle stepsStyle(BuildContext context) => CupertinoTheme.of(context)
      .textTheme
      .tabLabelTextStyle
      .copyWith(fontSize: 14);

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
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 15.0),
                children: [
                  Text(
                    'This feature is not functional yet',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle
                        .copyWith(
                          fontSize: 15,
                          color: CupertinoColors.systemRed,
                        ),
                  ),
                  Text(
                    'How to import accounts from Google Authenticator:',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle
                        .copyWith(
                          fontSize: 15,
                        ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Column(
                      children: [
                        InfoTile(
                          infoNumber: '1',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text: 'Tap the overflow button ',
                              style: stepsStyle(context),
                            ),
                          ),
                        ),
                        InfoTile(
                          infoNumber: '2',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text: 'Tap the overflow button ',
                              style: stepsStyle(context),
                              children: const [
                                WidgetSpan(
                                  child:
                                      Icon(CupertinoIcons.ellipsis, size: 14),
                                ),
                                TextSpan(text: ' at the top right of the app.'),
                              ],
                            ),
                          ),
                        ),
                        InfoTile(
                          infoNumber: '3',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text: 'Find "Export Accounts"',
                              style: stepsStyle(context),
                            ),
                          ),
                        ),
                        InfoTile(
                          infoNumber: '4',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text: 'Select the accounts you want to export',
                              style: stepsStyle(context),
                            ),
                          ),
                        ),
                        InfoTile(
                          infoNumber: '5',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text:
                                  'A QR Code will appear, which you can scan.',
                              style: stepsStyle(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 20),
                    child: CupertinoButton.filled(
                      child: const Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          CupertinoPageRoute<Widget>(
                            fullscreenDialog: true,
                            builder: (BuildContext context) {
                              return const Scanner();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    'If you are importing from thie device, you will need to follow the steps below',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .tabLabelTextStyle
                        .copyWith(
                          fontSize: 15,
                        ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).barBackgroundColor,
                      borderRadius:
                          const BorderRadius.all(Radius.circular(12.0)),
                    ),
                    child: Column(
                      children: [
                        InfoTile(
                          infoNumber: '6',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text:
                                  'Take a screenshot of the QR Code and save it to ',
                              style: stepsStyle(context),
                              children: const [
                                WidgetSpan(
                                  child: Icon(CupertinoIcons.folder, size: 18),
                                ),
                                TextSpan(text: ' Files'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30.0, vertical: 20),
                    child: CupertinoButton.filled(
                      child: const Text(
                        'Import from Files',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: BottomButtons(currentPage: 3),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String infoNumber;
  final Widget text;
  const InfoTile({
    Key? key,
    required this.infoNumber,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: NumberBadge(data: infoNumber),
            ),
          ),
          Expanded(flex: 10, child: text),
        ],
      ),
    );
  }
}

class NumberBadge extends StatelessWidget {
  final String data;
  const NumberBadge({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      width: 22,
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(15)),
      ),
      child: Center(
        child: Text(
          data,
          style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                color: CupertinoColors.white,
              ),
        ),
      ),
    );
  }
}
