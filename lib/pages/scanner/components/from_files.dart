import 'package:authenticator/pages/scanner/components/bottom_buttons.dart';
import 'package:authenticator/shared/components/info_tile.dart';
import 'package:flutter/cupertino.dart';

class FromFiles extends StatefulWidget {
  const FromFiles({Key? key}) : super(key: key);

  @override
  State<FromFiles> createState() => _FromFilesState();
}

class _FromFilesState extends State<FromFiles> {
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
              largeTitle: const Text('From Files'),
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
                    'How to import QR Code from Files:',
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
                        InfoTile(
                          infoNumber: '2',
                          text: RichText(
                            maxLines: 3,
                            text: TextSpan(
                              text:
                                  'Tap on "Import from Files" and choose the screenshots with QR Code.',
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
              child: BottomButtons(currentPage: 4),
            ),
          ],
        ),
      ),
    );
  }
}
