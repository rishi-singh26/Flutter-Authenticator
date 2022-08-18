import 'package:flutter/cupertino.dart';

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
