import 'package:all_the_counters/screens/main_screen/current_counter_event.dart';
import 'package:all_the_counters/screens/main_screen/current_counter_state.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/snapshots_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrentCounterBloc extends Bloc<CurrentCounterEvent, CurrentCounterState> {
  final BuildContext context;

  CurrentCounterBloc(this.context) : super(CurrentCounterState.initial()) {}

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
        yield CurrentCounterState.fromCounter(counter, event.snapshotsCount);
      else
        yield CurrentCounterState.noCounter();
    } else if (event is CurrentCounterLoading) {
      yield CurrentCounterState.loading();
    } else if (event is CurrentCounterMessage) {
      yield CurrentCounterState.withMessage(event.message);
    }
  }

  void addToCounter(double value) async {
    final counter = state.counter;
    if (counter != null) {
      add(CurrentCounterNewValue(state.value + value));
      final repo = RepositoryProvider.of<CountersRepository>(context);

      repo.setCounterValue(counter, state.value + value);

      final needsSnapshot = Snapshot.requiresSnapshot(counter, DateTime.now());
      if (needsSnapshot) {
        final newCounter = await repo.createSnapshot(counter);
        if (newCounter != null)
          add(CurrentCounterNewValue(newCounter.value));
      }
    }
  }

  Future getCurrentCounter() async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final snapRepo = RepositoryProvider.of<SnapshotsRepository>(context);
      var counter = await repo.getSelectedOrSet();
      if (counter != null && Snapshot.requiresSnapshot(counter, DateTime.now())) {
        counter = await repo.createSnapshot(counter);
      }
      final snapshotsCount = counter == null ? 0 :
        await snapRepo.countSnapshotsOf(counter.requireId());
      add(CurrentCounterNewCounter(counter, snapshotsCount: snapshotsCount));
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