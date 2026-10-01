# Project IRL Engineering Constitution

This repository is governed by the Project IRL SRS v1.0 (30 September 2026). Before architectural or production work, read the SRS, relevant ADRs, and the traceability index. Production changes must cite applicable FR/NFR IDs and preserve requirement-to-code-to-test traceability.

## Non-negotiable boundaries

1. Authoritative state is changed only through deterministic application/domain services. Never bypass them.
2. AI is advisory. It may not directly mutate rewards, consent, verification, account restrictions, policy decisions, or enforcement state. Preserve a deterministic fallback.
3. Never infer honesty, morality, personality, protected traits, or mental-health status.
4. Do not introduce ambient audio/video, biometrics, facial analysis, hidden monitoring, or continuous precise GPS without an approved ADR plus privacy/threat analysis.
5. Never weaken privacy or safety to simplify implementation. Use synthetic data only; never copy production child data into staging.
6. Never commit secrets, credentials, tokens, private certificates, or real user/child data.
7. Do not introduce microservices without an accepted ADR backed by measured need. Kubernetes and Kafka are prohibited for the baseline MVP.
8. Production modules use DDD boundaries; cross-module infrastructure imports are forbidden. Providers sit behind interfaces/adapters where practical.
9. Every production functional change requires tests. Every database change requires a migration using additive/backward-compatible discipline.
10. Do not silently break public APIs. Version contracts when compatibility requires it.
11. Record consequential architecture changes as ADRs; do not change accepted invariants without stating the conflict and proposing an ADR.
12. Prefer small, reversible changes. Do not invent functionality or silently “improve” SRS requirements.

Phase-0 code under `prototypes/` is disposable research software, not production architecture.
