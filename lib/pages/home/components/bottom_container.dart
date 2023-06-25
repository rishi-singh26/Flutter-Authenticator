import 'dart:io';

import 'package:flutter/cupertino.dart';

class BottomContainer extends StatelessWidget {
  final Function() onPress;
  const BottomContainer({Key? key, required this.onPress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        border: const Border(
          top: BorderSide(width: 0.1, color: CupertinoColors.separator),
        ),
      ),
      padding: EdgeInsets.only(
        top: 10.0,
        bottom: Platform.isIOS ? 40 : 10,
        left: 15.0,
        right: 15.0,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                CupertinoIcons.circle_fill,
                color: CupertinoColors.systemGreen,
                size: 10,
              ),
              const SizedBox(width: 4.0),
              Text(
                'Synchronised',
                style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onPress,
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: CupertinoTheme.of(context).primaryColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    CupertinoIcons.add,
                    color: CupertinoColors.white,
                    size: 20.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
