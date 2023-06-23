import 'package:flutter/cupertino.dart';

class CustomActivityIndicator extends StatelessWidget {
  final Widget? content;
  const CustomActivityIndicator({Key? key, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CupertinoAlertDialog(
            title: content,
            content: const Column(
              children: [
                SizedBox(height: 20.0),
                CupertinoActivityIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
