# Project IRL

Project IRL explores how a mobile product can help young people practise focus, responsibility, listening, gratitude, and intentional technology use **away from the screen**. It verifies only legitimately observable evidence and never scores morality or honesty.

## Status

**Phase 0 — exploratory prototype.** The prototype validates whether the quest loop is understandable and useful. It has no backend, AI, authentication, guardian workflow, production verification, or reward economy. Prototype code is intentionally disposable and must not evolve implicitly into production code.

## Architecture direction

The approved future baseline is Flutter plus typed Kotlin/Swift platform adapters and a Python/FastAPI DDD modular monolith backed by PostgreSQL and Redis. AI remains provider-neutral and advisory; deterministic software owns consent, policy, evidence labels, rewards, restrictions, and lifecycle decisions. See the [roadmap](docs/roadmap/BUILD_PLAN.md) and [ADRs](docs/adr/README.md).

## Method

Exploratory prototype → isolated technical spikes → requirements refinement → incremental production vertical slices → controlled pilot → production → measured scaling. Risky child-data and platform work follows requirement → threat analysis → design → implementation → tests → review.

## Privacy and safety

- No ambient recording, biometrics, hidden monitoring, continuous precise location, behavioural advertising, shame loops, or morality rankings.
- Self-report remains explicitly self-reported.
- Local aggregation and data minimisation are defaults.
- Only synthetic data is permitted in prototype and development environments.

## Repository map

- `prototypes/phase0_exploratory/` — disposable Flutter research app
- `docs/` — SRS guidance, decisions, roadmap, requirements, and research materials
- `spikes/` — isolated technical experiments and reports
- `.github/workflows/` — checks for code that currently exists

Production directories will be introduced only when their roadmap level begins.

## Run the prototype

```bash
cd prototypes/phase0_exploratory
flutter pub get
flutter run
```

Validate with `dart format --output=none --set-exit-if-changed .`, `flutter analyze`, and `flutter test`.

## Requirements and contribution

The authoritative source is `Project_IRL_Architecture_and_SRS_v1.docx`; see [SRS handling](docs/srs/README.md). Read [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and `AGENTS.md` before making changes. Production work must reference SRS IDs and include tests.
