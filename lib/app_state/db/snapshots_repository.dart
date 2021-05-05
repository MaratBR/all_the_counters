import 'package:all_the_counters/app_state/db/records_repository.dart';
import 'package:all_the_counters/app_state/exceptions.dart';
import 'package:flutter/src/widgets/framework.dart';

import 'counters_repository.dart';

enum Period {
  day,
  month,
  year,
  week
}

/// Based on the period type set for given counter and the last date counter
/// was updated returns time of the beginning of last period.
/// i.e. is period set to month and lastUpdateAt is September 12, 2020 it'll
/// return September 1, 2020. If period is set to year it will return January 1, 2020 and so on
List<DateTime> _getPeriodBounds(Period period, DateTime lastUpdateAt) {
  switch (period) {
    case Period.day:
      var start = DateTime(lastUpdateAt.year, lastUpdateAt.month, lastUpdateAt.day);
      return [start, start.add(Duration(hours: 23, minutes: 59, seconds: 59))];
    case Period.month:
      return [
        DateTime(lastUpdateAt.year, lastUpdateAt.month, 1),
        DateTime(lastUpdateAt.year, lastUpdateAt.month + 1, 1).subtract(Duration(days: 1))
      ];
    case Period.year:
      return [
        DateTime(lastUpdateAt.year),
        DateTime(lastUpdateAt.year + 1).subtract(Duration(days: 1))
      ];
    case Period.week:
      // assume monday is the beginning of the week
      // TODO add option to use any day as the start of the period
      return [
        DateTime(lastUpdateAt.year, lastUpdateAt.month, lastUpdateAt.day)
            .subtract(Duration(days: (lastUpdateAt.weekday + 6) % 7)),
        DateTime(lastUpdateAt.year, lastUpdateAt.month, lastUpdateAt.day, 23, 59, 59)
            .add(Duration(days: 6 - (lastUpdateAt.weekday + 6) % 7))
      ];
  }
}

class IllegalResetType extends AppException {
  final ResetType resetType;

  IllegalResetType(this.resetType);


  @override
  String describe() => "$resetType is not a valid ResetType value for this operation";
}

Period _periodFromResetType(ResetType resetType) {
  switch (resetType) {
    case ResetType.day:
      return Period.day;
    case ResetType.month:
      return Period.month;
    case ResetType.week:
      return Period.week;
    case ResetType.year:
      return Period.year;
    case ResetType.none:
      throw new IllegalResetType(resetType);
  }
}

class Snapshot extends Model {
  final int counterId;
  final double value;
  final Period period;
  final DateTime periodStart;
  final DateTime periodEnd;

  Snapshot(
      this.counterId, this.value, this.period, this.periodStart, this.periodEnd,
      {int? id}) : super(id: id);

  factory Snapshot.fromCounter(Counter counter) {
    if (!counter.inserted) {
      throw new ModelNotYetInserted(counterDAODef.collectionName, counter);
    }
    final period = _periodFromResetType(counter.resetState.type);
    final periodBounds = _getPeriodBounds(period, counter.lastUpdateAt);
    return Snapshot(
        counter.id!,
        counter.value,
        period,
        periodBounds[0],
        periodBounds[1],
    );
  }

  static bool requiresSnapshot(Counter counter, DateTime now) {
    try {
      final period = _periodFromResetType(counter.resetState.type);
      final periodBounds = _getPeriodBounds(period, counter.lastUpdateAt);
      final periodBounds2 = _getPeriodBounds(period, now);
      return periodBounds[0] != periodBounds2[1];
    } catch (e) {
      // IllegalResetType is thrown
      if (e is IllegalResetType) {
        return false;
      }
      throw e;
    }
  }

  @override
  List<Object?> get props => [id, counterId, value, period, periodStart];
}

class _SnapshotDef extends DAODefinition<Snapshot> {
  @override
  String get collectionName => 'snapshots';

  @override
  Snapshot fromMap(int id, Map<String, dynamic> data) {
    return Snapshot(
      data['counterId'], 
      data['value'], 
      Period.values[data['period']], 
      DateTime.fromMillisecondsSinceEpoch(data['periodStart']), 
      DateTime.fromMillisecondsSinceEpoch(data['periodEnd']),
      id: data['id']
    );
  }

  @override
  Map<String, dynamic> toMap(Snapshot value) => {
    'counterId': value.counterId,
    'value': value.value,
    'period': value.period.index,
    'periodStart': value.periodStart.millisecondsSinceEpoch,
    'periodEnd': value.periodEnd.millisecondsSinceEpoch,
  };
}

final _snapshotsDef = _SnapshotDef();

class SnapshotsRepository extends RecordsRepository<Snapshot> {
  SnapshotsRepository(BuildContext context) : super(_snapshotsDef, context);

  Future createSnapshot(Counter counter) {
    return insert(Snapshot.fromCounter(counter));
  }
}