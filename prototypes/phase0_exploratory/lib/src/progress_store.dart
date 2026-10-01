import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProgressStore {
  Future<Set<String>> loadCompletedQuestIds();
  Future<void> saveCompletedQuestIds(Set<String> ids);
}

class SharedPreferencesProgressStore implements ProgressStore {
  static const _key = 'phase0_completed_quest_ids_v1';

  @override
  Future<Set<String>> loadCompletedQuestIds() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key) ?? const <String>[]).toSet();
  }

  @override
  Future<void> saveCompletedQuestIds(Set<String> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_key, ids.toList()..sort());
  }
}

class MemoryProgressStore implements ProgressStore {
  Set<String> ids = {};

  @override
  Future<Set<String>> loadCompletedQuestIds() async => {...ids};

  @override
  Future<void> saveCompletedQuestIds(Set<String> ids) async {
    this.ids = {...ids};
  }
}
