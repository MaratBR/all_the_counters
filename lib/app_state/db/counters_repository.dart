import 'dart:developer';

import 'package:all_the_counters/app_state/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/timestamp.dart';

import 'records_repository.dart';

enum CounterType {
  unset,
  number,
  time
}

enum ResetType {
  none,
  day,
  month,
  year,
  week,
}

class ResetState {
  final ResetType type;
  final int offset;

  ResetState(this.type, this.offset);

  factory ResetState.none() => ResetState(ResetType.none, 0);
}

class Counter extends Model {
  final String? label;
  final Timestamp? createdAt;
  final CounterType type;
  final double value;
  final bool isSelected;
  final ResetState resetState;
  final DateTime lastUsedAt;
  final DateTime lastUpdateAt;

  Counter({
    Timestamp? createdAt,
    int? id,
    this.label,
    this.value = 0.0,
    this.type = CounterType.number,
    this.isSelected = false,
    DateTime? lastUsedAt,
    DateTime? lastUpdateAt,
    ResetState? resetState
  }) : this.createdAt = createdAt ?? Timestamp.now(),
        this.resetState = resetState ?? ResetState.none(),
        this.lastUpdateAt = lastUpdateAt ?? DateTime.now(),
        this.lastUsedAt = lastUsedAt ?? DateTime.now(),
        super(id: id);

  Counter copyWith({
    Timestamp? createdAt, String? label, DateTime? lastUsedAt,
    CounterType? type, double? value, bool? isSelected, int? id,
    ResetState? resetState, DateTime? lastUpdateAt
  }) {
    return Counter(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
      isSelected: isSelected ?? this.isSelected,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      resetState: resetState ?? this.resetState,
      lastUpdateAt: lastUpdateAt ?? this.lastUpdateAt
    );
  }

  @override
  List<Object?> get props => [id, label, createdAt, type, value, isSelected, lastUsedAt, resetState];
}

class _CounterDef extends DAODefinition<Counter> {
  @override
  String get collectionName => "counters";

  @override
  Counter fromMap(int id, Map<String, dynamic> data) {
    return Counter(
      label: data['label'],
      createdAt: data['createdAt'],
      id: id,
      value: data['value'],
      isSelected: data['isSelected'] ?? false,
      type: CounterType.values[data['type'] ?? 0],
      lastUpdateAt: DateTime.fromMillisecondsSinceEpoch(data['lastUpdateAt'] ?? 0),
      lastUsedAt: DateTime.fromMillisecondsSinceEpoch(data['lastUsedAt'] ?? 0),
      resetState: data['reset'] == null ? ResetState.none() : new ResetState(
        ResetType.values[data['reset']['type'] ?? 0],
        data['reset']['offset'] ?? 0
      )
    );
  }

  @override
  Map<String, dynamic> toMap(Counter value) {
    return {
      'label': value.label,
      'createdAt': value.createdAt,
      'value': value.value,
      'isSelected': value.isSelected,
      'type': value.type.index,
      'lastUsedAt': value.lastUsedAt.millisecondsSinceEpoch,
      'lastUpdateAt': value.lastUpdateAt.millisecondsSinceEpoch,
      'reset': {
        'offset': value.resetState.offset,
        'type': value.resetState.type.index
      }
    };
  }
}

final DAODefinition<Counter> counterDAODef = _CounterDef();

class CountersRepository extends RecordsRepository<Counter> {
  CountersRepository(BuildContext context) : super(counterDAODef, context);

  Future<List<Counter>> getAll() => getAllSortedBy('lastUsedAt', ascending: false);

  Future reset() async {
    await deleteAll();
    await insert(Counter(label: 'New counter'));
  }

  Future<Counter> createNew() => insert(Counter());

  Future<Counter> setCounterValue(Counter counter, double value) {
    return update(counter.copyWith(value: value, lastUpdateAt: DateTime.now()));
  }

  Future<Counter> getFirst() async {
    var counters = await getAll();
    if (counters.length > 0) {
      return counters[0];
    }

    return await createNew();
  }

  Future<Counter?> getSelected() async {
    final selected = await find(Finder(filter: Filter.equals('isSelected', true), limit: 1));
    if (selected.isEmpty)
      return null;
    return selected[0];
  }

  Future<Counter?> getSelectedOrSet() async {
    var counter = await getSelected();
    if (counter == null) {
      final all = await getAll();
      if (all.length == 0)
        return null;
      counter = all[0];
      await setSelected(counter);
    }
    return counter;
  }

  Future setSelected(Counter counter) async {
    final selected = await getSelected();
    if (selected != null)
      await update(selected.copyWith(isSelected: false));
    await update(counter.copyWith(isSelected: true));
  }

  Future touchCounter(Counter counter) {
    return update(counter.copyWith(lastUsedAt: DateTime.now()));
  }

  Future<Counter> getSelectedOrCreate() async {
    var counter = await getSelected();
    if (counter == null) {
      counter = await getFirst();
      await setSelected(counter);
      return counter;
    }
    return counter;
  }
}