import 'package:isar/isar.dart';

part 'local_cache_entry.g.dart';

@collection
class LocalCacheEntry {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String key;

  late String value;

  DateTime updatedAt = DateTime.now();
}
