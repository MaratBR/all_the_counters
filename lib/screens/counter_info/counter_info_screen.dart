import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/snapshots_repository.dart';
import 'package:all_the_counters/screens/counter_info/counter_info_cubit.dart';
import 'package:all_the_counters/screens/counter_info/counter_info_state.dart';
import 'package:all_the_counters/widgets/basic_ui.dart';
import 'package:all_the_counters/widgets/counter_value_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CounterInfo {
  final List<Counter> snapshots;
  final Counter counter;

  CounterInfo(this.counter, this.snapshots);
}

class CounterInfoScreen extends StatefulWidget {
  final int counterId;

  CounterInfoScreen({Key? key, required this.counterId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CounterInfoScreenState();
  }
}

class _CounterInfoScreenState extends State<CounterInfoScreen> {
  late CounterInfoCubit _counterInfoCubit;

  @override
  Widget build(BuildContext context) {
    return BasicUI(
      child: _ui(),
    );
  }

  Widget _ui() {
    // TODO exception, not found UI
    return BlocBuilder<CounterInfoCubit, CounterInfoBaseState>(
      bloc: _counterInfoCubit,
      builder: (context, value) {
        if (value is CounterInfoLoadingState)
          return Center(child: CircularProgressIndicator());
        else if (value is CounterInfoState)
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 40, bottom: 10),
                child: Column(
                  children: [
                    Text(
                        value.counter.label ?? "Unknown",
                        style: Theme.of(context).textTheme.headline2
                    ),
                    Text(
                        "Snapshots",
                        style: Theme.of(context).textTheme.bodyText2
                    )
                  ],
                ),
              ),

              Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: value.snapshots.length + 1,
                    padding: EdgeInsets.only(top: 40),
                    itemBuilder: (
                            (context, index) => index == 0 ?
                        _buildItem(context, value.counter, value.counter.value, "Now") :
                        _buildItem(context, value.counter, value.snapshots[index - 1].value,
                            _snapshotToString(value.snapshots[index - 1]))
                    ),
                  ),
                ),
              )
            ],
          );
        else
          return Text("123");
      },
    );
  }

  Widget _buildItem(BuildContext context, Counter counter, double value, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),

      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(Radius.circular(30))
        ),
        child: Row(
          children: [
            Padding(
                padding: EdgeInsets.only(right: 15, left: 15),
                child: CounterValueDisplay(
                  value: value,
                  type: counter.type,
                  showSign: false,
                )
            ),

            Text(
              title,
              style: Theme.of(context).textTheme.subtitle1
            )
          ],
        ),
      ),
    );
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  static int _numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  static int _weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = _numOfWeeks(date.year - 1);
    } else if (woy > _numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  String _snapshotToString(Snapshot snapshot) {
    switch (snapshot.period) {
      case Period.year:
        return DateFormat.y().format(snapshot.periodStart);
      case Period.month:
        return DateFormat.yMMM().format(snapshot.periodStart);
      case Period.day:
        return DateFormat.yMMMMEEEEd().format(snapshot.periodStart);
      case Period.week:
        return DateFormat.yMMM().format(snapshot.periodStart) + " (week ${_weekNumber(snapshot.periodStart)})";
    }
  }

  @override
  void initState() {
    super.initState();
    _counterInfoCubit = CounterInfoCubit(context);
    _counterInfoCubit.loadCounter(widget.counterId);
  }
}