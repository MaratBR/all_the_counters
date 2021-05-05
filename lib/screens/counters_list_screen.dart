import 'package:all_the_counters/app_state/counters_bloc.dart';
import 'package:all_the_counters/app_state/counters_state.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/screens/edit_counter/edit_counter_screen.dart';
import 'package:all_the_counters/widgets/basic_ui.dart';
import 'package:all_the_counters/widgets/buttons.dart';
import 'package:all_the_counters/widgets/counter_value_display.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../app.dart';

class CounterListScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _CounterListScreenState();
  }
}

class _CounterListScreenState extends State<CounterListScreen> with RouteAware {
  late CountersBloc _countersBloc;

  @override
  void initState() {
    super.initState();
    _countersBloc = CountersBloc(context);
  }

  @override
  void didChangeDependencies() {
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _countersBloc.reload(silent: true);
  }

  @override
  Widget build(BuildContext context) {
    return BasicUI(child: _ui());
  }

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  Widget _ui() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 40, bottom: 10),
          child: Text(
              "Counters",
              style: Theme.of(context).textTheme.headline2
          ),
        ),

        BlocBuilder<CountersBloc, CountersState>(
          bloc: _countersBloc,
          builder: (context, countersState) {
            if (countersState.isLoading)
              return CircularProgressIndicator();
            return Expanded(child: _buildCountersList(countersState));
          }
        ),

        Padding(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          child: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _countersBloc.createNewCounter()
                .then((c) => _openEditCounter(c.id!));
          }
          ),
        )

      ],
    );
  }

  Widget _buildItem(BuildContext context, Counter counter) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: RoundedListItemButton(
        onPressed: () {
          _countersBloc.select(counter).whenComplete(() => Navigator.pop(context));
        },
        onLongPress: () {
          final id = counter.id;
          if (id != null)
            _openEditCounter(id);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(10, 20, 10, 20),
          child: Row(
            children: [
              if (counter.isSelected)
                Padding(
                    padding: EdgeInsets.only(left: 6, right: 6),
                    child: Icon(Icons.circle, size: 3, color: Theme.of(context).primaryColor)
                ),

              Padding(
                  padding: EdgeInsets.only(right: 15, left: counter.isSelected ? 0 : 15),
                  child: CounterValueDisplay(
                    value: counter.value,
                    type: counter.type,
                    showSign: false,
                  )
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      counter.label ?? "Unnamed counter",
                      style: Theme.of(context).textTheme.subtitle1
                  ),
                  Text(
                      counter.createdAt == null ? "" : "Created ${DateFormat.yMMMd().format(counter.createdAt!.toDateTime())}",
                      style: Theme.of(context).textTheme.bodyText2
                  )
                ],
              ),

              Spacer(),
              IconButton(
                icon: Icon(Icons.edit, size: 20),
                onPressed: () {
                  final id = counter.id;
                  if (id != null)
                    _openEditCounter(id);
                })
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountersList(CountersState countersState) {
    var count = countersState.counters.length;
    count = count == 0 ? 1 : count;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(30))
      ),
      child: ListView.builder(
        key: _listKey,
        itemCount: count,
        padding: EdgeInsets.only(top: 40),
        itemBuilder: (
            countersState.counters.length == 0 ?
                (context, index) => Text('No counters found', textAlign: TextAlign.center,) :
                (context, index) => _buildItem(context, countersState.counters[index])
        ),
      ),
    );
  }

  void _openEditCounter(int id) {
    if (id != null)
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditCounterScreen(counterId: id)
          )
      );
  }
}