import 'package:all_the_counters/app_state/db/counters_repository.dart';

class EditCounterState {
  final Counter? counter;
  final bool isLoading;
  final String? message;

  EditCounterState(this.counter, this.isLoading, this.message);
  EditCounterState.initial() : counter = null, isLoading = false, message = null;

  EditCounterState copyWith({Counter? counter, bool? isLoading, String? message}) {
    return EditCounterState(
        counter ?? this.counter,
        isLoading ?? this.isLoading,
        message ?? this.message);
  }
}