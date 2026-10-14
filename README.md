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

The repository now contains the Debian 13 OS installer source: a Simple-CDD
profile, an unattended preseed, an exact-hardware install gate, SSH-key-only
operator bootstrap, Cockpit, and a locked-down host firewall. It intentionally
does **not** contain a generated ISO or real machine inventory.

The installer remains blocked until each HP PC is captured into the ignored
`inventory/local/` directory and its `destructive_install_enabled` flag is
explicitly changed to `true`. Technitium installation, writable USB enrollment,
and the reproducible package closure remain later phases.

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
[the OS installer guide](docs/os-install.md), and [the implementation roadmap](docs/roadmap.md).
