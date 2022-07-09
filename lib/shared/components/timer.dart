import 'dart:async';
import 'package:flutter/cupertino.dart';

class CountdownTimer extends StatefulWidget {
  final TextStyle textStyle;
  final int initialTime;

  const CountdownTimer({
    Key? key,
    required this.textStyle,
    required this.initialTime,
  }) : super(key: key);

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  late int _start;

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            _start = 30;
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  @override
  void initState() {
    _start = widget.initialTime;
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _start.toString(),
      style: widget.textStyle,
    );
  }
}
