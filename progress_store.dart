import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Single local store (Hive). Progress is saved as one JSON string.
abstract class ProgressStore {
  UserProgress load();
  Future<void> save(UserProgress p);
}

class HiveProgressStore implements ProgressStore {
  static const _box = 'evidence_act_bd';
  static const _key = 'progress_v1';
  final Box<String> box;
  HiveProgressStore(this.box);

  static Future<HiveProgressStore> open() async {
    await Hive.initFlutter();
    return HiveProgressStore(await Hive.openBox<String>(_box));
  }

  @override
  UserProgress load() {
    final raw = box.get(_key);
    if (raw == null) return UserProgress();
    try {
      return UserProgress.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserProgress(); // corrupted data: start clean rather than crash
    }
  }

  @override
  Future<void> save(UserProgress p) => box.put(_key, jsonEncode(p.toJson()));
}

class MemoryProgressStore implements ProgressStore {
  UserProgress _p = UserProgress();
  @override
  UserProgress load() => _p;
  @override
  Future<void> save(UserProgress p) async => _p = p.clone();
}
