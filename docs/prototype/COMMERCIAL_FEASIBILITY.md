# Phase 0.1 Commercial Feasibility Gate

**Decision status (2026-10-03): not approved for implementation.** This is an issue register, not legal advice, a business case, or approval. The prototype has no payments, subscription, valuable balance, orders, or fulfilment.

## Unit economics and operating model to prove

A real reward must be funded from durable net revenue or a separately approved sponsor budget—not from an assumed unused balance. Model reward acquisition cost, tax, provider/merchant fees, payment/app-store fees, packing/delivery, returns/refunds, chargebacks, lost shipments, customer support, fraud loss, safeguarding, privacy operations, and reserve capital. Treat every issued but unexpired entitlement as outstanding exposure under the applicable accounting/legal treatment; breakage is a measured assumption, not free money.

Contracts must identify the supplier of record, merchant of record, product safety owner, inventory/stock representation, delivery SLA, returns/refunds, data roles, incident response, voucher issuer/distributor restrictions, age restrictions, and termination treatment. Subscription terms need transparent renewal, cancellation, refund and chargeback processes.

Client-controlled storage cannot support real redemption: users can reinstall, restore, modify an APK/storage, race devices, or lose data. A production entitlement would need an authoritative transactional backend, authentication, idempotency, audit/reconciliation, fraud controls, and deletion/accounting rules. That backend could validate ledger operations; it still could not prove self-reported offline behaviour.

## Current official-source review questions

The linked sources are starting points checked on 2026-10-03; counsel and product/platform specialists must re-check the then-current text and applicability before design approval.

- **RBI / PPI:** Would the exact issuer, stored-value, acceptance network, funding and redemption flow be a PPI/payment system or fall outside it? Do not classify all loyalty points alike. Review the RBI *Master Directions on PPIs* (issued 27 August 2021, page updated through 27 December 2024): https://www.rbi.org.in/Scripts/NotificationUser.aspx?Id=12156
- **Paid access plus valuable rewards / gaming:** Could consideration, chance/skill structure, prizes, or the specific state/central regime classify the proposal as online money gaming or another regulated activity? Gamification alone is not declared gambling here. Obtain current specialist analysis before joining paid access to valuable rewards.
- **Child data:** Which DPDP Act provisions and rules have commenced on the intended launch date, who is a child, which verifiable-consent/exception rules apply, and are tracking/behavioural-monitoring features prohibited or conditioned? Start with MeitY's official DPDP Act 2023 text: https://www.meity.gov.in/static/uploads/2024/02/Digital-Personal-Data-Protection-Act-2023.pdf and verify later rules/commencement notifications rather than assuming every notified provision is effective.
- **Consumer/subscription design:** What disclosures, affirmative consent, renewal notices, cancellation parity, refund rights and grievance handling apply? Review the CCPA *Guidelines for Prevention and Regulation of Dark Patterns, 2023* (30 November 2023): https://consumeraffairs.nic.in/sites/default/files/file-uploads/latestnews/central-consumer-protection-authority-dark-patterns-guidelines-watermark-1565354.pdf
- **App-store billing:** At launch, which rules apply to optional digital subscriptions versus physical goods, external links, alternative billing, children/families, disclosures, fees and refunds? Google Play's current policy generally distinguishes in-app digital content from physical goods, but markets/programs change: https://support.google.com/googleplay/android-developer/answer/9858738
- **Gift cards/vouchers:** Do issuer and distributor agreements permit the use case, minors, marketing language, refunds, expiry, territories, denominations, fraud controls and API handling? No issuer has been selected.
- **Products:** Which BIS/product-safety, Legal Metrology, labelling, marketplace/e-commerce, recall and liability duties apply to each toy/activity/pet accessory? If food or pet food is later considered, identify the responsible regulator, licence, ingredients/labelling, storage, contamination, expiry and recall obligations before catalogue approval.
- **Tax/accounting:** Determine GST invoicing/place-of-supply, subscription and physical-goods treatment, withholding, revenue recognition, provisions for outstanding entitlements, breakage, refunds and cross-border implications with qualified advisers.

## Approval gates

Approved requirements and ADR; youth/privacy threat assessment; official-source legal opinion; validated unit economics including outstanding exposure; provider contracts; product-safety and fulfilment ownership; backend ledger/security design; app-store review; refund/support runbook; and a controlled pilot that does not financially reward self-report. No screen or this document satisfies any gate.
