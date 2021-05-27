import 'package:all_the_counters/screens/counters_list/counters_event.dart';
import 'package:all_the_counters/screens/counters_list/counters_state.dart';
import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/event_bus.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CountersBloc extends Bloc<CountersEvent, CountersState> {
  final BuildContext context;

  CountersBloc(this.context) : super(CountersState.initial()) {
    reload();
  }

  @override
  Stream<CountersState> mapEventToState(CountersEvent event) async* {
    if (event is CountersEventLoading) {
      yield CountersState.loading();
    } else if (event is CountersEventList) {
      yield CountersState.counters(event.counters);
    } else if (event is CountersEventError) {
      yield state.withMessage(event.message);
    }
  }

  Future reload({bool silent = false}) async {
    if (!silent)
      add(CountersEventLoading());

    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counters = await repo.getAll();
      add(CountersEventList(counters));
    } catch (e) {
      add(CountersEventError(e.toString()));
    }
  }
  
  Future<Counter> createNewCounter() async {
    final repo = RepositoryProvider.of<CountersRepository>(context);
    final counter = await repo.createNew();
    add(CountersEventList([]..add(counter)..addAll(state.counters)));
    return counter;
  }

  Future deleteAll() async {
    await RepositoryProvider.of<CountersRepository>(context).deleteAll();
    applicationEventBus.fire(AllCountersDeleted());
  }

  Future select(Counter counter) async {
    await RepositoryProvider.of<CountersRepository>(context).setSelected(counter);
    await reload(silent: true);
  }
}

class NewCounterSelected {
  final Counter counter;

  NewCounterSelected(this.counter);
}

class CounterDeleted {
  final Counter counter;

  CounterDeleted(this.counter);
}

class AllCountersDeleted {}