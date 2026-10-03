import 'package:flutter_test/flutter_test.dart';
import 'package:project_irl_phase0/src/models.dart';
import 'package:project_irl_phase0/src/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('migrates legacy completions once without retroactive XP', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProgressStore.legacyKey: [
        'focus-01',
        'focus-01',
        'gratitude-01',
      ],
    });
    final store = SharedPreferencesProgressStore();
    final first = await store.load();
    final second = await store.load();
    expect(first.attempts, hasLength(2));
    expect(
      first.attempts.every((a) => a.status == AttemptStatus.completed),
      isTrue,
    );
    expect(first.awards, isEmpty);
    expect(second.attempts.map((a) => a.id), first.attempts.map((a) => a.id));
  });

  test('unreadable v2 data is retained and reported', () async {
    SharedPreferences.setMockInitialValues({
      SharedPreferencesProgressStore.dataKey: '{broken',
    });
    final store = SharedPreferencesProgressStore();
    await expectLater(store.load(), throwsA(isA<ProgressStoreException>()));
    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(SharedPreferencesProgressStore.dataKey),
      '{broken',
    );
  });
}
