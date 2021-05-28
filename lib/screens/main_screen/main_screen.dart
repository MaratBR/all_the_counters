import 'dart:math';

import 'package:all_the_counters/screens/main_screen/current_counter_bloc.dart';
import 'package:all_the_counters/screens/main_screen/current_counter_state.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/screens/counters_list/counters_list_screen.dart';
import 'package:all_the_counters/widgets/basic_ui.dart';
import 'package:all_the_counters/widgets/buttons.dart';
import 'package:all_the_counters/widgets/counter_buttons_palette.dart';
import 'package:all_the_counters/widgets/counter_value_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../app.dart';

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with RouteAware {
  late CurrentCounterBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() async {
    await _bloc.getCurrentCounter();
  }

  @override
  void didPopNext() async {
    await _bloc.getCurrentCounter();
    // Covering route was popped off the navigator.
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bloc = CurrentCounterBloc(context);
  }

  @override
  Widget build(BuildContext context) {
    return BasicUI(child: _ui(context));
  }

  Widget _ui(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<CurrentCounterBloc, CurrentCounterState>(
      bloc: _bloc,
      builder: (context, state) => Stack(
        children: [
          // settings button
          Align(
            child: Padding(
                padding: EdgeInsets.only(top: 20, right: 20),
                child: IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CounterListScreen()
                          )
                      );
                    }
                )
            ),
            alignment: Alignment.topRight,
          ),

          Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildMainArea(state),
                ),
              )
          ),

          if (state.counter != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                child: CounterButtonPalette(
                  gradation: _getGradationForCounter(state.counter!),
                  onClick: (value) { _bloc.addToCounter(value); },
                  type: state.type,
                ),
              ),
            )
        ],
      ),
    );
  }

  List<Widget> _buildMainArea(CurrentCounterState state) {
    final theme = Theme.of(context);

    if (state.stateType == CurrentCounterStateType.noCounter) {
      return [
        Container(
          padding: EdgeInsets.fromLTRB(50, 70, 50, 50),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            children: [
              Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('No counters found')
              ),

              TextButton(
                onPressed: () {
                  _bloc.createNewCounter();
                },
                child: Text('Create counter'),
              )
            ],
          ),
        )
      ];
    } else if (state.stateType == CurrentCounterStateType.counter) {
      final counter = state.counter!;

      return [
        Text(counter.label ?? "Unnamed counter"),
        Row(
            children: [
              IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () => { _bloc.addToCounter(-1) }
              ),

              Container(
                child: CounterValueDisplay(
                  value: state.value,
                  type: state.type,
                  showSign: false,
                  fontSize: 38,
                ),
              ),


              IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => { _bloc.addToCounter(1) }
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly
        ),
        if (state.snapshotsCount > 0)
          Container(
            margin: EdgeInsets.only(top: 15),
            child: Text(state.snapshotsCount.toString() + " " + (state.snapshotsCount == 1 ? "snapshot" : "snapshots")),
          ),

      ];
    } else if (state.stateType == CurrentCounterStateType.loading) {
      return [
        CircularProgressIndicator()
      ];
    }
    return [
      Text(state.toString())
    ];
  }

  List<double> _getGradationForCounter(Counter counter) {
    if (counter.type == CounterType.time)
      return [1, .25, .5, 2, 3, 4];
    return [1, 2, 3, 4, 5, 6];
  }
}