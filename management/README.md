# Agent management plane

The management plane is separate from the DNS appliances.

Planned components:

- read-only Technitium API identity for diagnostics
- planner identity that produces structured diffs
- apply identity enabled only after pull-request approval
- safety-focused MCP gateway with named client tokens and redacted audit logs
- blackbox DNS canary probes and host metrics
- encrypted backups and restore-drill status

The MCP gateway source or deployment is not vendored until its dependencies,
authentication boundaries, audit behavior, and destructive tool gates are
reviewed and pinned.
