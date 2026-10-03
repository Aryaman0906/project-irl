# Requirements Traceability

This bootstrap index is planning metadata, not an implementation claim. All production requirements remain **planned**. Phase-0 artefacts are research references only.

| SRS range | Area | Future module(s) | Status |
|---|---|---|---|
| FR-001–FR-009 | Identity, policy, consent, data rights | identity, policy | Planned |
| FR-010–FR-013 | Profile, goals, preferences | profile | Planned |
| FR-014–FR-020 | Quest catalog and recommendation | quests | Planned |
| FR-021–FR-027 | Quest sessions and device wellbeing | quests, device wellbeing | Planned |
| FR-028–FR-036 | Verification and evidence | verification | Planned |
| FR-037–FR-041 | Reflection | reflection | Planned |
| FR-042–FR-049 | Rewards and habits | rewards | Planned |
| FR-050–FR-055 | Family and school | family | Planned |
| FR-056–FR-063 | AI and content safety | AI orchestration, policy | Planned |
| FR-064–FR-067 | Notifications | notifications | Planned |
| FR-068–FR-073 | Admin and analytics | admin, analytics | Planned |
| NFR-001–NFR-022 | Quality attributes | cross-cutting | Planned |

Each production increment must add API, code, tests, status, and version links to `traceability.yaml`.

## Phase 0.1 research trace (not production compliance)

| SRS constraints exercised | Prototype code | Tests / evidence |
|---|---|---|
| FR-021, FR-024, FR-027 | `flow_controller.dart`, `progress_service.dart`, `progress_store.dart` | restart, interruption, backward-clock and reset tests |
| FR-028–FR-035 | `models.dart`, completion/evidence UI | catalog evidence and full-flow widget tests |
| FR-037–FR-040 | reflection UI and persisted `ReflectionAnswer` | full-flow widget test |
| FR-042–FR-044, FR-048 | `progress_service.dart`, XP/history UI, ADR-009 | atomicity, duplicate, limits, reconciliation and threshold tests |
| NFR-003, NFR-008, NFR-012 | local-only store, error/reset UI, semantic Material controls | store migration/corruption tests, analysis, physical checklist pending |

These links demonstrate a disposable experiment only; all production statuses below remain planned.
