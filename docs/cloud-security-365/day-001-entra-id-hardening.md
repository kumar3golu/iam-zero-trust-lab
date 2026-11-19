# 365 Days of Cloud Security — Day 001
## Microsoft Entra ID Security Hardening
Published: 2026-11-19

**Scope:** Educational reference and simulated assessment. Not a claim of production implementation or certification. No tenant, paid subscription, credentials or employer information is required for this exercise.

## Objective
Reduce identity takeover, excessive privilege and unauthorized application access using defense in depth.

## Baseline checklist

| Priority | Control | Verification |
| --- | --- | --- |
| Critical | Protect administrator accounts with phishing-resistant MFA where supported | Review authentication methods and policy coverage |
| Critical | Maintain at least two independently protected cloud-only emergency access accounts | Verify access and alert on sign-ins |
| High | Separate administrative and everyday accounts | Review privileged role assignments |
| High | Block legacy authentication | Review sign-in logs and applicable access policies |
| High | Minimize standing privileges | Review role assignments; use PIM if licensed |
| High | Restrict risky application consent | Review consent settings and existing delegated/application permissions |
| High | Monitor identity activity | Review available sign-in and audit logs |
| Medium | Review guest and stale accounts | Confirm ownership and business need before removal |

## Licensing and cost
This repository exercise is free. Security defaults are available without premium Entra licensing for eligible tenants. Conditional Access generally requires Entra ID P1; risk-based policies and PIM require appropriate premium entitlements. Verify current licensing before implementing. Security defaults and custom Conditional Access are alternative configurations, not a combined baseline. No cloud resources are provisioned here.

## Safe implementation sequence
1. Inventory accounts, roles, applications, authentication methods and existing policies.
2. Establish emergency access and test recovery with authorized administrators.
3. Choose security defaults or a licensed Conditional Access strategy.
4. For Conditional Access, pilot policies with a small test group and use report-only mode before enforcement. Review impact on service identities and emergency access.
5. Roll out progressively after change approval. Document exceptions, owners and expiry dates.
6. Monitor sign-ins and audit events, and review the baseline periodically.

## Free tabletop lab
Use the fictional records below; no live tenant is needed.

| Identity | Finding | Proposed action |
| --- | --- | --- |
| Admin-A | Standing global administrator | Assess role reduction and eligible access |
| User-B | Password-only sign-in | Plan MFA enrollment |
| Guest-C | No confirmed sponsor | Ask owner to validate access |
| App-D | Broad Graph permissions | Validate required permissions and reduce excess |
| Emergency-E | Recovery access not tested | Arrange an authorized recovery drill |

### Acceptance criteria
- Each finding has a named role responsible for remediation (not a real person's name).
- Emergency access is validated before access policy enforcement.
- Privileged roles and application permissions have a documented justification.
- Changes have an approved rollback plan.
- Evidence is sanitized before publishing.

### Rollback
For a custom Conditional Access rollout, restore the prior policy state using authorized emergency access if necessary. Preserve policy settings before changes. Never remove all MFA protections as a routine troubleshooting step.

## References
- [Microsoft Entra security defaults](https://learn.microsoft.com/en-us/entra/fundamentals/security-defaults)
- [Conditional Access overview](https://learn.microsoft.com/en-us/entra/identity/conditional-access/overview)
- [Emergency access accounts](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/security-emergency-access)
- [Privileged Identity Management](https://learn.microsoft.com/en-us/entra/id-governance/privileged-identity-management/pim-configure)

## Learning outcome
Explain how authentication, least privilege, application governance and monitoring work together to protect cloud identities.

**Next:** Day 002 — Conditional Access policy design and simulated validation.
