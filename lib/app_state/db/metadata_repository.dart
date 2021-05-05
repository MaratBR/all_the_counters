import 'package:all_the_counters/app_state/db/db.dart';
import 'package:flutter/cupertino.dart';
import 'package:sembast/sembast.dart';

class MetadataRepository {
  final StoreRef<String, dynamic> ref = StoreRef("metadata");
  final BuildContext context;

  MetadataRepository(this.context);

  Future<String?> getString(String key) async {
    var obj = await get(key);
    if (obj is String)
      return obj;
    return null;
  }

  Future<int?> getInt(String key) async {
    var obj = await get(key);
    if (obj is int)
      return obj;
    return null;
  }

  Future<Object> get(String key) async {
    return ref.record(key).get(await AppDatabase.instance.database);
  }
}