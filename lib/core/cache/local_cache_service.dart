import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillswap/core/cache/local_cache_entry.dart';

class LocalCacheService {
  final Isar _isar;

  LocalCacheService._(this._isar);

  static Future<LocalCacheService> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [LocalCacheEntrySchema],
      directory: dir.path,
      name: 'skillswap_cache',
    );
    return LocalCacheService._(isar);
  }

  Future<void> putMap(String key, Map<String, dynamic> value) async {
    await _putString(key, jsonEncode(value));
  }

  Future<void> putList(String key, List<Map<String, dynamic>> value) async {
    await _putString(key, jsonEncode(value));
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final raw = await _getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final raw = await _getString(key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! List) return null;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> remove(String key) async {
    await _isar.writeTxn(() async {
      await _isar.localCacheEntrys.where().keyEqualTo(key).deleteFirst();
    });
  }

  Future<void> clearPrefix(String prefix) async {
    final ids = await _isar.localCacheEntrys
        .filter()
        .keyStartsWith(prefix)
        .idProperty()
        .findAll();
    if (ids.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.localCacheEntrys.deleteAll(ids);
    });
  }

  Future<String?> _getString(String key) async {
    final entry = await _isar.localCacheEntrys
        .where()
        .keyEqualTo(key)
        .findFirst();
    return entry?.value;
  }

  Future<void> _putString(String key, String value) async {
    final existing = await _isar.localCacheEntrys
        .where()
        .keyEqualTo(key)
        .findFirst();
    final entry = existing ?? LocalCacheEntry()
      ..key = key;
    entry
      ..value = value
      ..updatedAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.localCacheEntrys.put(entry);
    });
  }
}
