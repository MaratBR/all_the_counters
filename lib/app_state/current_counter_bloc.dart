import 'package:all_the_counters/app_state/current_counter_event.dart';
import 'package:all_the_counters/app_state/current_counter_state.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/snapshots_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentCounterBloc extends Bloc<CurrentCounterEvent, CurrentCounterState> {
  final BuildContext context;

  CurrentCounterBloc(this.context) : super(CurrentCounterState.initial()) {
    getCurrentCounter();
  }

  @override
  Stream<CurrentCounterState> mapEventToState(CurrentCounterEvent event) async* {
    if (event is CurrentCounterNewValue) {
      yield CurrentCounterState(
        value: event.newValue,
        type: state.type,
        label: state.label,
        stateType: CurrentCounterStateType.counter,
        counter: state.counter
      );
    } else if (event is CurrentCounterNewCounter) {
      final counter = event.counter;
      if (counter != null)
        yield CurrentCounterState.fromCounter(counter);
      else
        yield CurrentCounterState.noCounter();
    } else if (event is CurrentCounterLoading) {
      yield CurrentCounterState.loading();
    } else if (event is CurrentCounterMessage) {
      yield CurrentCounterState.withMessage(event.message);
    }
  }

  addToCounter(double value) {
    add(CurrentCounterNewValue(state.value + value));
    final counter = state.counter;
    if (counter != null) {
      final repo = RepositoryProvider.of<CountersRepository>(context);

      if (Snapshot.requiresSnapshot(counter, DateTime.now())) {
        final repo = RepositoryProvider.of<SnapshotsRepository>(context);
        repo.createSnapshot(counter);
      }

      repo.setCounterValue(counter, state.value + value);
    }
  }

  Future getCurrentCounter() async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = await repo.getSelectedOrSet();
      add(CurrentCounterNewCounter(counter));
    } catch (e) {
      add(CurrentCounterMessage(e.toString()));
    }
  }

  void createNewCounter() async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = await repo.getSelectedOrCreate();
      add(CurrentCounterNewCounter(counter));
    } catch (e) {
      add(CurrentCounterMessage(e.toString()));
    }
  }

}