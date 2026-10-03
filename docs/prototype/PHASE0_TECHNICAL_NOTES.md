# Phase 0.1 Technical Notes

## Scope and demonstrated history root cause

This remains disposable research software. The prior controller reduced progress to a `Set<String>` of completed quest IDs and persisted it only inside `submitReflection`. It had no attempt record, no cancelled/active history, no history renderer, and no durable timer. Consequently cancellation could never appear, completion was lost until reflection submitted successfully, repeat completions collapsed by quest ID, and the only progress UI showed a count rather than records. Loading itself worked for the limited key; the reported history was principally **not modeled or displayed**, with a save gap before reflection.

Phase 0.1 replaces that path with a deterministic `ProgressService` and a single JSON snapshot in `shared_preferences`. Each attempt contains stable ID, quest ID/version, local timestamps serialized as UTC, lifecycle status, `SELF_REPORTED` evidence, elapsed seconds, optional reflection and timing note. Completion plus append-only award is one store write; in-memory authoritative state changes only after that write succeeds. Award ID `award-<attempt-id>-v1` and completed-state checks make retries idempotent.

## Schema and migration

Snapshot schema is v2. On first load only, valid `phase0_completed_quest_ids_v1` entries migrate to completed attempts (`legacy-<quest-id>`, quest version 1, epoch timestamps, `SELF_REPORTED`) without retroactive XP. The old key is retained until deliberate reset. Valid v2 awards are loaded unchanged and never synthesized. Malformed v2 JSON raises a visible recovery error and is not silently cleared. Reset removes v1 and v2 keys.

## Timer/interruption contract

- Start is persisted immediately and a second active/interrupted quest is rejected.
- Periodic UI display derives from wall time; background/inactive transitions checkpoint. Timer duration is separate from the user report and grants nothing automatically.
- Foreground after ordinary backgrounding continues from persisted start time; keeping the timer screen open is unnecessary.
- Process termination/reopening or reboot cannot reconstruct a trustworthy monotonic interval, so a saved `active` attempt becomes `interrupted`, with explicit resume/cancel actions. Resume is labelled approximate.
- A backward clock change marks timing interrupted/uncertain. Forward clock changes can inflate display time, but never verify behaviour or automatically complete/award.
- Completion always requires explicit self-report and reflection/skip. Cancelled/abandoned attempts earn no XP.

## Provisional reward and progress policy

Policy v1 awards 10 XP for an eligible `SELF_REPORTED` completion, up to 10 XP for the same quest per local calendar day and 30 XP across all quests per local calendar day. Further practice remains recorded with an explanation and zero XP. Days use device-local midnight; weeks are local Monday–Sunday. Milestones are 0, 30, 70, 120 and 200 XP. Missing days remove nothing. Totals derive only from stored awards, not completion counts.

This local duplicate protection does not resist modified APKs, edited storage, reinstall/reset, or device-clock manipulation and must never secure valuable rewards.

## Data and capability boundary

Local storage contains attempts, timestamps, status/evidence, reflections, XP awards and optional concept preferences. It collects no account, address, payment/bank/UPI, identity document, sensor data, merchant submission or third-party identifying details. Reflections are never logged. Core functionality is local; automated tests use synthetic data; a real-participant pilot requires separate permission/privacy arrangements; a commercial service requires every gate in `COMMERCIAL_FEASIBILITY.md`.
