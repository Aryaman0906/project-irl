import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class ProgressStoreException implements Exception {
  const ProgressStoreException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class ProgressStore {
  Future<PrototypeData> load();
  Future<void> save(PrototypeData data);
  Future<void> clear();
}

class SharedPreferencesProgressStore implements ProgressStore {
  static const dataKey = 'phase01_data_v2';
  static const legacyKey = 'phase0_completed_quest_ids_v1';
  @override
  Future<PrototypeData> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(dataKey);
    if (raw != null) {
      try {
        return PrototypeData.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } on Object catch (_) {
        throw const ProgressStoreException(
          'Saved progress could not be read. It has been kept on this device; reset only if you choose.',
        );
      }
    }
    final legacy = preferences.getStringList(legacyKey) ?? const [];
    if (legacy.isEmpty) return const PrototypeData();
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final ids = legacy.toSet().toList()..sort();
    final migrated = PrototypeData(
      attempts: ids
          .map(
            (id) => QuestAttempt(
              id: 'legacy-$id',
              questId: id,
              questVersion: 1,
              startedAt: epoch,
              endedAt: epoch,
              status: AttemptStatus.completed,
              evidence: EvidenceLabel.selfReported,
              timingNote: 'Migrated completion; no retroactive XP.',
            ),
          )
          .toList(),
    );
    await save(migrated);
    return migrated;
  }

  @override
  Future<void> save(PrototypeData data) async {
    final preferences = await SharedPreferences.getInstance();
    if (!await preferences.setString(dataKey, jsonEncode(data.toJson()))) {
      throw const ProgressStoreException(
        'Progress could not be saved. Please try again.',
      );
    }
  }

  @override
  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    final a = await preferences.remove(dataKey);
    final b = await preferences.remove(legacyKey);
    if (!a || !b) {
      throw const ProgressStoreException(
        'Some local data could not be deleted. Please try again.',
      );
    }
  }
}

class MemoryProgressStore implements ProgressStore {
  PrototypeData data;
  bool failNextSave = false;
  MemoryProgressStore([this.data = const PrototypeData()]);
  @override
  Future<PrototypeData> load() async => data;
  @override
  Future<void> save(PrototypeData value) async {
    if (failNextSave) {
      failNextSave = false;
      throw const ProgressStoreException('Simulated save failure');
    }
    data = value;
  }

  @override
  Future<void> clear() async => data = const PrototypeData();
}
