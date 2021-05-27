import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/snapshots_repository.dart';

abstract class CounterInfoBaseState {}

class CounterInfoLoadingState extends CounterInfoBaseState {}

class CounterInfoState extends CounterInfoBaseState {
  final Counter counter;
  final List<Snapshot> snapshots;

  CounterInfoState(this.counter, this.snapshots);
}