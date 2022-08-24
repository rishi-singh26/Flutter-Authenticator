import 'package:flutter/cupertino.dart';

class AdvancedOptions extends StatelessWidget {
  final bool advancedOptionsOn;
  final Object selectedAlgorithm;
  final Object selectedDigitsCount;
  final Object selectedInterval;
  final Function(bool) setAdvancedOptions;
  final Function(Object) setAlgorithm;
  final Function(Object) setDigits;
  final Function(Object) setPeriod;

  const AdvancedOptions({
    Key? key,
    required this.advancedOptionsOn,
    required this.selectedAlgorithm,
    required this.selectedDigitsCount,
    required this.selectedInterval,
    required this.setAdvancedOptions,
    required this.setAlgorithm,
    required this.setDigits,
    required this.setPeriod,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle styleOne = CupertinoTheme.of(context)
        .textTheme
        .pickerTextStyle
        .copyWith(fontSize: 18);
    TextStyle labelStyle = TextStyle(
      color: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.color,
      fontSize: 14,
    );

    return Container(
      margin: const EdgeInsets.only(top: 30.0),
      padding: const EdgeInsets.only(left: 18.0, top: 10.0),
      decoration: BoxDecoration(
        color: CupertinoTheme.of(context).barBackgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(13.0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoTheme.of(context)
                          .textTheme
                          .tabLabelTextStyle
                          .color ??
                      CupertinoColors.opaqueSeparator,
                  width: 0.1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advanced Options',
                      style:
                          CupertinoTheme.of(context).textTheme.pickerTextStyle,
                    ),
                    SizedBox(
                      width: 240,
                      child: Text(
                        'Only change these options if you know what you are doing.',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                  ],
                ),
                CupertinoSwitch(
                  value: advancedOptionsOn,
                  onChanged: (bool value) => setAdvancedOptions(value),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              right: 10.0,
              bottom: 15.0,
              top: 15.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoTheme.of(context)
                          .textTheme
                          .tabLabelTextStyle
                          .color ??
                      CupertinoColors.opaqueSeparator,
                  width: 0.1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Algorithm', style: styleOne),
                ),
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: CupertinoColors.systemGrey2,
                    thumbColor: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle
                            .color ??
                        CupertinoColors.white,
                    // This represents the currently selected segmented control.
                    groupValue: selectedAlgorithm,
                    // Callback that sets the selected segmented control.
                    onValueChanged: (value) {
                      if (value != null) {
                        setAlgorithm(value);
                      }
                    },
                    children: const {
                      'SHA1': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'SHA1',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      'SHA256': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'SHA256',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      'SHA512': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'SHA512',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              right: 10.0,
              bottom: 15.0,
              top: 15.0,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: CupertinoTheme.of(context)
                          .textTheme
                          .tabLabelTextStyle
                          .color ??
                      CupertinoColors.opaqueSeparator,
                  width: 0.1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Digits', style: styleOne),
                ),
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: CupertinoColors.systemGrey2,
                    thumbColor: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle
                            .color ??
                        CupertinoColors.white,
                    // This represents the currently selected segmented control.
                    groupValue: selectedDigitsCount,
                    // Callback that sets the selected segmented control.
                    onValueChanged: (value) {
                      if (value != null) {
                        setDigits(value);
                      }
                    },
                    children: const {
                      '6': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          '6',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      '8': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          '8',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(
              right: 10.0,
              bottom: 15.0,
              top: 15.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Text('Interval (Sec.)', style: styleOne),
                ),
                Expanded(
                  child: CupertinoSlidingSegmentedControl(
                    backgroundColor: CupertinoColors.systemGrey2,
                    thumbColor: CupertinoTheme.of(context)
                            .textTheme
                            .tabLabelTextStyle
                            .color ??
                        CupertinoColors.white,
                    // This represents the currently selected segmented control.
                    groupValue: selectedInterval,
                    // Callback that sets the selected segmented control.
                    onValueChanged: (value) {
                      if (value != null) {
                        setPeriod(value);
                      }
                    },
                    children: const {
                      '30': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '30',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      '60': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '60',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      '90': Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '90',
                          style: TextStyle(
                            color: CupertinoColors.white,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
