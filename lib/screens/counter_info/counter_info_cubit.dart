import 'package:all_the_counters/app_state/db/counters_repository.dart';
import 'package:all_the_counters/app_state/db/snapshots_repository.dart';
import 'package:all_the_counters/screens/counter_info/counter_info_state.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CounterInfoCubit extends Cubit<CounterInfoBaseState> {
  final BuildContext context;

  CounterInfoCubit(this.context) : super(CounterInfoLoadingState());

  Future loadCounter(int counterId) async {
    try {
      emit(CounterInfoLoadingState());
      final snapshotsRepo = RepositoryProvider.of<SnapshotsRepository>(context);
      final counterRepo = RepositoryProvider.of<CountersRepository>(context);

      final counter = await counterRepo.getById(counterId);
      if (counter == null) {

      } else {
        final snapshots = await snapshotsRepo.getSnapshotsOf(counterId);
        emit(CounterInfoState(counter, snapshots));
      }
    } catch (e) {

    }

  }
}