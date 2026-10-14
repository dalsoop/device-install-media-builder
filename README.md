# DNS Appliance Provisioning

Offline Debian provisioning and encrypted USB enrollment for three bare-metal
Technitium DNS appliances.

## Planned topology

| Role | Address | Initial responsibility |
| --- | --- | --- |
| Router | `10.0.0.1` | Gateway and DHCP authority |
| `dns01` | `10.0.5.1/16` | Primary cluster node |
| `dns02` | `10.0.5.2/16` | Secondary cluster node |
| `dns03` | `10.0.5.3/16` | Secondary cluster node |

All three nodes run Debian 13, Technitium DNS Server, OpenSSH, and Cockpit. The
installation must remain functional without Internet access.

## Current status

This repository is a safety-first bootstrap. It defines the architecture,
security boundaries, hardware inventory contract, enrollment record schema, and
implementation roadmap. It does **not** yet publish a bootable installer.

The existing local prototype is intentionally not imported as a release because
it still needs a writable enrollment partition, retry-safe credential handling,
exact hardware allowlists, health-gated completion, and a reproducible build.

## Design summary

1. The read-only installer image contains pinned packages and a pinned
   Technitium image.
2. The same USB has a writable exFAT partition labeled `DNS-ENROLL`.
3. The operator selects `dns01`, `dns02`, or `dns03`; internal-disk erasure is
   allowed only after exact hardware and disk checks.
4. First boot generates credentials once, verifies services, and writes public
   facts plus an age-encrypted recovery archive to `DNS-ENROLL`.
5. Ongoing DNS changes use Git review, plan/apply separation, per-agent identities,
   and a management-plane MCP gateway.

Start with [the architecture](docs/architecture.md), [security rules](docs/security.md),
and [the implementation roadmap](docs/roadmap.md).
