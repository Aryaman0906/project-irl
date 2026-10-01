# Prior Project Decisions

This is supplementary project context; the SRS remains authoritative and wins any conflict.

- Exploratory prototyping comes first; prototype code is disposable.
- Uncertain platform functionality is investigated in isolated technical spikes.
- Validated findings feed back into requirements and ADRs.
- Production is iterative/incremental and built as complete vertical slices.
- Deterministic functionality precedes AI enhancement, and a non-AI fallback remains available.
- Verification is deterministic; the reward ledger is append-only.
- Native capabilities use typed adapters; infrastructure providers use interfaces.
- Major APIs/contracts are versioned; database evolution is additive and backward compatible.
- Production modules preserve DDD boundaries; microservices require measured need.
- Codex works one controlled milestone at a time.
