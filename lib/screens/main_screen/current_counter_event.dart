import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:equatable/equatable.dart';

abstract class CurrentCounterEvent extends Equatable {
  const CurrentCounterEvent();
}

class CurrentCounterNewValue extends CurrentCounterEvent {
  const CurrentCounterNewValue(this.newValue);

  final double newValue;

  @override
  List<Object?> get props => [newValue];
}

class CurrentCounterNewCounter extends CurrentCounterEvent {
  const CurrentCounterNewCounter(this.counter, {this.snapshotsCount = 0});

  final Counter? counter;
  final int snapshotsCount;

  @override
  List<Object?> get props => [counter];
}

class CurrentCounterLoading extends CurrentCounterEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}

class CurrentCounterMessage extends CurrentCounterEvent {
  final String message;

  CurrentCounterMessage(this.message);

  @override
  List<Object?> get props => [message];
}