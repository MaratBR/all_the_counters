import 'dart:async';
import 'dart:developer';

import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/screens/edit_counter/edit_couner_state.dart';
import 'package:all_the_counters/screens/edit_counter/edit_counter_bloc.dart';
import 'package:all_the_counters/screens/edit_counter/edit_counter_form.dart';
import 'package:all_the_counters/widgets/basic_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCounterScreen extends StatefulWidget {
  final int counterId;

  const EditCounterScreen({Key? key, required this.counterId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EditCounterScreenState();
  }
}

class _EditCounterScreenState extends State<EditCounterScreen> {
  late EditCounterBloc _editCounterBloc;
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return BasicUI(
        child: BlocBuilder(
            bloc: _editCounterBloc,
            builder: _build
        )
    );
  }

  Widget _build(BuildContext context, EditCounterState state) {
    if (state.isLoading)
      return CircularProgressIndicator();

    final theme = Theme.of(context);
    final counter = state.counter;

    List<Widget> widgets = [
      Padding(
        padding: EdgeInsets.only(top: 35, bottom: 45),
        child: Text("Counter", style: theme.textTheme.headline2),
      )
    ];

    if (state.message != null)
      widgets.add(Text(state.message!));


    if (counter != null)
      widgets += [
        Container(
          padding: EdgeInsets.fromLTRB(9, 15, 9, 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            color: theme.cardColor,
          ),
          child: EditCounterForm(
            initialValue: counter,
            callback: (newValue) => _editCounterBloc.updateCounter(newValue),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 35, right: 20),
          alignment: Alignment.center,
          child: MaterialButton(
            onPressed: () {
              _showDeleteDialog(counter);
            },
            color: Colors.red,
            textColor: Colors.white,
            child: Text("Delete"),
            splashColor: Colors.red.shade600,
            highlightColor: Colors.red.shade900,
          ),
        )
      ];

    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(children: widgets),
    );
  }

  @override
  void initState() {
    super.initState();
    _editCounterBloc = EditCounterBloc(context, widget.counterId);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _showDeleteDialog(Counter counter) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('You are about to delete this counter'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text((counter.label ?? "Unnamed counter") + ' will be deleted'),
                Text('Are you sure?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Nope, cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Yep, delete that!', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                if (await _editCounterBloc.deleteCounter()) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        )
    );
  }

}