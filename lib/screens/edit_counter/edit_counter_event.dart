import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:equatable/equatable.dart';

abstract class EditCounterEvent extends Equatable {}

class EditCounterEventLoading extends EditCounterEvent {
  @override
  List<Object?> get props => [];
}

class EditCounterEventCounter extends EditCounterEvent {
  final Counter counter;

  EditCounterEventCounter(this.counter);

  @override
  List<Object?> get props => [counter];
}

class EditCounterEventError extends EditCounterEvent {
  final String message;

  EditCounterEventError(this.message);

  @override
  List<Object?> get props => [message];
}