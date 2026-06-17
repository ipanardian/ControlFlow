# Security Checklist Reference

Use this reference when work touches user input, auth, permissions,
secrets, storage, network boundaries, or external integrations.

## Lane Triggers

Security-related work is Lane B when it touches:

- Auth, authorization, sessions, or tokens.
- Secrets handling.
- Cryptographic code.
- Public API boundaries.
- Data persisted or consumed by other systems.

## Checks

- Inputs are validated at trust boundaries.
- Authorization is checked on server-side paths.
- Errors do not leak secrets or internal details.
- Secrets are not logged, committed, or printed.
- Tokens have clear expiry and audience/scope checks.
- External calls have timeouts and safe error handling.
- Dependency changes are reviewed for known risk.
- Dangerous operations require explicit approval and auditability.

## Evidence

Record which checks were performed:

- Tests.
- Static analysis or secret scan.
- Manual review notes.
- Contract tests.
- Unverified areas and mitigation.

## Red Flags

- Auth logic changed without Lane B.
- User-controlled input reaches shell, SQL, template, or file path without
  validation.
- Logs include tokens, passwords, private keys, or PII.
- New dependency is added without purpose and risk note.
- Security behavior is verified only by happy-path tests.
