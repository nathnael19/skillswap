import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:skillswap/core/cache/local_cache_entry.dart';

class LocalCacheService {
  final Isar _isar;
  static const Duration defaultMaxAge = Duration(minutes: 10);

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

  Future<Map<String, dynamic>?> getMap(
    String key, {
    Duration? maxAge = defaultMaxAge,
  }) async {
    final raw = await _getString(key, maxAge: maxAge);
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

  Future<List<Map<String, dynamic>>?> getList(
    String key, {
    Duration? maxAge = defaultMaxAge,
  }) async {
    final raw = await _getString(key, maxAge: maxAge);
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

  Future<String?> _getString(String key, {Duration? maxAge}) async {
    final entry = await _isar.localCacheEntrys
        .where()
        .keyEqualTo(key)
        .findFirst();
    if (entry == null) return null;
    if (_isExpired(entry, maxAge)) {
      await remove(key);
      return null;
    }
    return entry.value;
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

  Future<void> pruneExpired({Duration maxAge = defaultMaxAge}) async {
    final all = await _isar.localCacheEntrys.where().findAll();
    final expiredIds = all
        .where((entry) => _isExpired(entry, maxAge))
        .map((entry) => entry.id)
        .toList();
    if (expiredIds.isEmpty) return;
    await _isar.writeTxn(() async {
      await _isar.localCacheEntrys.deleteAll(expiredIds);
    });
  }

  bool _isExpired(LocalCacheEntry entry, Duration? maxAge) {
    if (maxAge == null) return false;
    return DateTime.now().difference(entry.updatedAt) > maxAge;
  }

  Future<void> close() async {
    if (_isar.isOpen) {
      await _isar.close();
    }
  }
}
