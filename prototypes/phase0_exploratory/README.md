# Project IRL Phase-0 Exploratory Prototype

Disposable Flutter research software for testing the quest interaction loop. It is not production architecture and contains no backend, AI, authentication, real consent, surveillance, verification engine, or reward economy.

Run with `flutter run`. Validate with `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test`.

Progress is local: only unique completed quest IDs are stored through `shared_preferences`. Reflections are intentionally not retained.

## Regenerating mobile platform scaffolds

The `android/` and `ios/` directories are intentionally omitted from the text-only PR-export branch because Flutter generates binary launcher and launch-image assets. On the original Phase-0 branch, these directories contained only ordinary Flutter-generated development scaffolding and the generated `shared_preferences` registration—there were no Project IRL native integrations, Android UsageStats, or iOS DeviceActivity implementations.

Regenerate the disposable prototype's Android and iOS development artifacts locally from this directory:

```bash
flutter create \
  --platforms=android,ios \
  --org org.projectirl.prototype \
  --project-name project_irl_phase0 \
  .
```

Review generated changes before committing. Platform scaffold generation does not authorize native monitoring or production integration work.
