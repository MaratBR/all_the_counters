import '../../app_state/db/counters_repository.dart';

class CountersState {
  final List<Counter> counters;
  final String message;
  final bool isLoading;

  CountersState(this.counters, this.message, this.isLoading);

  factory CountersState.initial() => CountersState([], "", false);
  factory CountersState.loading() => CountersState([], "", true);
  factory CountersState.counters(List<Counter> counters) => CountersState(counters, "", false);

  CountersState withMessage(String message) {
    return CountersState(counters, message, false);
  }
}