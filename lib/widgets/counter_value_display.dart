import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:flutter/material.dart';

class CounterValueDisplay extends StatelessWidget {
  final double value;
  final CounterType type;
  final double fontSize;
  final bool showSign;

  const CounterValueDisplay({
    Key? key,
    required this.value,
    required this.type,
    this.fontSize = 25,
    this.showSign = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context ) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showSign)
            Container(
              width: 24,
              height: 24,
              child: Icon(value < 0 ? Icons.remove : Icons.add),
            ),
          Text(_toString(),
              style: Theme.of(context).textTheme.button!.copyWith(fontSize: fontSize)
          )
        ],
      ),
    );
  }

  String _toString() {
    var v = value < 0 ? -value : value;
    switch (type) {
      case CounterType.number:
        return (value < 0 && !showSign ? '-' : '') + (v.floorToDouble() == v ? v.floor().toString() : v.toString());
      case CounterType.time:
        return (value < 0 && !showSign ? '-' : '') + '${v.floor()}:${(60 * (v - v.floor())).floor().toString().padLeft(2, '0')}';
      default:
        return value.toString();
    }
  }

}