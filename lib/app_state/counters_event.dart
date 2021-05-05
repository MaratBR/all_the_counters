import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:equatable/equatable.dart';

abstract class CountersEvent extends Equatable {
  const CountersEvent();
}

class CountersEventNewCounter extends CountersEvent {
  final Counter counter;

  const CountersEventNewCounter(this.counter);

  @override
  List<Object?> get props => [counter];
}

class CountersEventList extends CountersEvent {
  final List<Counter> counters;

  const CountersEventList(this.counters);

  @override
  List<Object?> get props => [counters];
}

class CountersEventLoading extends CountersEvent {
  @override
  List<Object?> get props => [];
}

class CountersEventError extends CountersEvent {
  final String message;

  CountersEventError(this.message);

  @override
  List<Object?> get props => [message];
}