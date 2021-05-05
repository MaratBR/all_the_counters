import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'counter_value_display.dart';

typedef void OnCounterButtonPaletteClicked(double value);

class CounterButtonPalette extends StatefulWidget {
  final List<double> gradation;
  final CounterType type;
  final OnCounterButtonPaletteClicked onClick;

  CounterButtonPalette({
    required this.gradation,
    required this.type,
    required this.onClick});

  @override
  State<StatefulWidget> createState() {
    return _CounterButtonPaletteState();
  }
}

class _CounterButtonPaletteState extends State<CounterButtonPalette> {
  bool _isNegative = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: IconButton(
                      onPressed: () => {
                        setState(() {
                          _isNegative = !_isNegative;
                        })
                      },
                      icon: Icon(_isNegative ? Icons.remove : Icons.add),
                    )
                ),

                for (int i = 0; i < widget.gradation.length; i++)
                  Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: MaterialButton(
                      elevation: 0,
                      color: theme.cardColor,
                      onPressed: () => {
                        widget.onClick(_isNegative ? -widget.gradation[i] : widget.gradation[i])
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10, left: 5, right: 5),
                        child: CounterValueDisplay(
                          value: _isNegative ? -widget.gradation[i] : widget.gradation[i],
                          type: widget.type,
                        ),
                      ),
                    ),
                  )
              ],
            )
        )
      ],
    );
  }

}