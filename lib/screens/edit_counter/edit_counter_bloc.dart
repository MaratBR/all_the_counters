import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/screens/edit_counter/edit_couner_state.dart';
import 'package:all_the_counters/screens/edit_counter/edit_counter_event.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditCounterBloc extends Bloc<EditCounterEvent, EditCounterState> {
  final BuildContext context;
  final int counterId;

  EditCounterBloc(this.context, this.counterId) : super(EditCounterState.initial()) {
    loadCounter();
  }

  @override
  Stream<EditCounterState> mapEventToState(EditCounterEvent event) async* {
    if (event is EditCounterEventLoading) {
      yield state.copyWith(isLoading: true);
    } else if (event is EditCounterEventCounter) {
      yield EditCounterState(event.counter, false, null);
    } else if (event is EditCounterEventError) {
      yield state.copyWith(message: event.message);
    }
  }

  void loadCounter() async {
    add(EditCounterEventLoading());

    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = await repo.getById(counterId);
      if (counter == null) {
        // TODO
      } else {
        add(EditCounterEventCounter(counter));
      }
    } catch (e) {
      add(EditCounterEventError(e.toString()));
    }
  }

  void setType(CounterType v) async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = state.counter;
      if (counter != null) {
        final newCounter = counter.copyWith(type: v);
        await repo.update(newCounter);
        add(EditCounterEventCounter(newCounter));
      }
    } catch (e) {
      add(EditCounterEventError(e.toString()));
    }
  }

  void setLabel(String v) async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = state.counter;
      if (counter != null) {
        final newCounter = counter.copyWith(label: v.isEmpty ? null : v);
        await repo.update(newCounter);
        add(EditCounterEventCounter(newCounter));
      }
    } catch (e) {
      add(EditCounterEventError(e.toString()));
    }
  }

  void updateCounter(Counter newValue) async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = state.counter;
      if (counter != null) {
        await repo.update(newValue);
        add(EditCounterEventCounter(newValue));
      }
    } catch (e) {
      add(EditCounterEventError(e.toString()));
    }
  }

  Future<bool> deleteCounter() async {
    try {
      final repo = RepositoryProvider.of<CountersRepository>(context);
      final counter = state.counter;
      if (counter != null) {
        await repo.delete(counter);
        return true;
      }
      return false;
    } catch (e) {
      add(EditCounterEventError(e.toString()));
      return false;
    }
  }

}