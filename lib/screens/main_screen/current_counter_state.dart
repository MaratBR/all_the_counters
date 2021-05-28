import 'package:all_the_counters/app_state/db/counters_repository.dart';

enum CurrentCounterStateType {
  loading,
  message,
  counter,
  noCounter
}

class CurrentCounterState {
  final Counter? counter;
  final double value;
  final CounterType type;
  final String? label;
  final String? message;
  final CurrentCounterStateType stateType;
  final int snapshotsCount;

  CurrentCounterState({
    this.value = 0,
    this.type = CounterType.unset,
    this.label,
    this.counter,
    this.message,
    this.snapshotsCount = 0,
    this.stateType = CurrentCounterStateType.noCounter
  });

  factory CurrentCounterState.withMessage(String message) {
    return CurrentCounterState(message: message);
  }

  factory CurrentCounterState.fromCounter(Counter counter, int? snapshotsCount) {
    return CurrentCounterState(
      type: counter.type,
      value: counter.value,
      label: counter.label,
      stateType: CurrentCounterStateType.counter,
      counter: counter,
      snapshotsCount: snapshotsCount ?? 0
    );
  }

  factory CurrentCounterState.initial() {
    return CurrentCounterState.loading();
  }

  factory CurrentCounterState.noCounter() {
    return CurrentCounterState(
      stateType: CurrentCounterStateType.noCounter
    );
  }

  factory CurrentCounterState.loading() {
    return CurrentCounterState(
      stateType: CurrentCounterStateType.loading
    );
  }

}