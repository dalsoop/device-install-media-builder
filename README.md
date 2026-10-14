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

The repository contains source for the complete day-0 path: a snapshot-pinned
Debian 13.7 Simple-CDD profile, exact-hardware erase gates, a digest-pinned
Technitium 15.6.1 OCI image, retry-safe first boot, generated Cockpit and
Technitium credentials, encrypted `DNS-ENROLL` writeback, health and backup
timers, cluster bootstrap, and Git-gated zone plan/apply tooling.

It deliberately contains no generated ISO, real HP inventory, password, token,
private key, or recovery archive. Destructive installation remains disabled
until each machine is captured into ignored `inventory/local/` files and a
physical `dns01` pilot is approved.

The isolated simulations cover 12 installer cases plus 4 management safety
cases, including completed-role and stale reinstall-token rejection. This
proves scripted decisions only. A booted ISO, Debian installation, Secure Boot,
internal-disk reboot, USB writeback, and physical DNS service remain
**unverified** until the gates in [verification](docs/verification.md) are
completed.

## Design summary

1. The read-only installer image is built from a dated Debian snapshot and a
   digest-pinned Technitium image; release evidence records every package hash.
2. The same USB has a writable exFAT partition labeled `DNS-ENROLL`.
3. The operator selects `dns01`, `dns02`, or `dns03`; internal-disk erasure is
   allowed only after exact hardware and disk checks.
4. First boot generates credentials once, verifies services, and writes public
   facts plus an age-encrypted recovery archive to `DNS-ENROLL`.
5. Ongoing DNS changes use Git review, plan/apply separation, per-agent identities,
   and a management-plane MCP gateway.

Start with [the architecture](docs/architecture.md), [security rules](docs/security.md),
[the OS installer guide](docs/os-install.md), [network cutover](docs/network-cutover.md),
[recovery](docs/recovery.md), and [verification gates](docs/verification.md).
