# Phase-0 Technical Notes

## Purpose and disposal

This Flutter app is an interaction experiment, not a production foundation. Rebuild validated behaviour within the approved production architecture.

## Local storage decision

Flutter does not expose reliable cross-platform application storage through its core SDK alone. Phase 0 therefore uses `shared_preferences`, the smallest suitable Flutter key-value plugin, to persist only non-sensitive completed quest IDs. It avoids databases, schemas, and production-style repositories while still surviving app restarts. No reflections, identifiers, precise telemetry, or child data are retained.

## State and timer

A single explicit `QuestFlowController` owns navigation/session state. Timer state uses monotonic periodic ticks for display; it is not evidence and never proves the offline activity happened. Cancellation adds no progress. Completion requires a direct user answer and is labelled `SELF_REPORTED`.

## Accessibility/localization preparation

Strings are centralized in `AppStrings`; controls use standard semantic Flutter widgets and minimum Material touch targets. Full localization is deferred until research validates copy.

## Assumptions and ambiguities

- Phase 0 uses ages 12–17 as one prototype band and only low-risk quests.
- “Approximately three” means the first three matching local quests are shown per selection; the catalog contains five per goal.
- “Simple local progress” means completion count, not XP, a streak, or a production habit state.
- A timer is interaction feedback only, never `DEVICE_VERIFIED` evidence.
