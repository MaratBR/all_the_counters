import 'dart:developer';

import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sembast/sembast.dart';

import '../exceptions.dart';
import 'db.dart';

abstract class Model extends Equatable {
  final int? id;

  get inserted => id != null;

  int requireId() {
    if (id == null)
      throw new ModelNotYetInserted(null, this);
    return id!;
  }

  Model({this.id});
}

abstract class DAODefinition<T extends Model> {
  Map<String, dynamic> toMap(T value);
  T fromMap(int id, Map<String, dynamic> data);
  String get collectionName;
}

class ModelNotYetInserted extends AppException {
  String? collectionName;
  Model model;

  ModelNotYetInserted(this.collectionName, this.model);

  @override
  String describe() => collectionName == null ? "model $model is not yet inserted in the collection" : "model $model is not yet inserted in the collection '$collectionName'";
}

class RecordsRepository<T extends Model> {
  final DAODefinition<T> _def;

  @protected
  final StoreRef<int, Map<String, dynamic>> storeRef;
  final BuildContext context;

  get collectionName => _def.collectionName;

  RecordsRepository(this._def, this.context) : storeRef = intMapStoreFactory.store(_def.collectionName);

  Future<int> count() async {
    return await storeRef.count(await AppDatabase.instance.database);
  }

  Future<T> insert(T value, {bool forceInsert = false}) async {
    if (value.inserted && !forceInsert) {
      this.update(value);
    } else {
      if (value.inserted && forceInsert) {
        throw new ModelNotYetInserted(_def.collectionName, value);
      }
      var id = await storeRef.add(
          await AppDatabase.instance.database,
          _def.toMap(value));
      var inserted = await getById(id);
      assert(inserted != null);
      return inserted!;
    }
    return value;
  }

  Future<T?> getById(int id) async {
    var record = await storeRef.record(id).get(await AppDatabase.instance.database);
    return record != null ? _def.fromMap(id, record) : null;
  }

  Future<T> update(T value) async {
    if (!value.inserted)
      throw ModelNotYetInserted(_def.collectionName, value);
    var map = await storeRef.record(value.id!).put(
      await AppDatabase.instance.database,
      _def.toMap(value)
    );
    return _def.fromMap(value.id!, map);
  }

  @protected
  Future<T> updateRaw(int id, Map<String, dynamic> update) async {
    var map = await storeRef.record(id).put(
      await AppDatabase.instance.database,
      update,
      merge: true
    );
    return _def.fromMap(id, map);
  }

  Future<bool> delete(T instance) async {
    return await deleteBy(Filter.byKey(instance.id)) > 0;
  }

  Future<int> deleteBy(Filter filter) async {
    return await storeRef.delete(
        await AppDatabase.instance.database,
        finder: Finder(filter: filter)
    );
  }

  Future<int> deleteAll() async {
    return await storeRef.delete(await AppDatabase.instance.database);
  }

  @protected
  Future<List<T>> getAllSortedBy(String field, {bool ascending = true}) {
    return find(Finder(sortOrders: [
      SortOrder(field, ascending),
    ]));
  }

  @protected
  Future<List<T>> find(Finder finder) async {
    final recordSnapshots = await storeRef.find(
      await AppDatabase.instance.database,
      finder: finder,
    );

    List<T> list = [];

    // Making a List<Subject> out of List<RecordSnapshot>
    for (var snap in recordSnapshots)
      try {
        list.add(_def.fromMap(snap.key, snap.value));
      } on TypeError catch (e) {
        log(e.toString());
      }
    return list;
  }

}