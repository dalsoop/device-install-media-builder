# Security

## Secret handling

- Use a dedicated native age recovery recipient. Its private identity must not
  exist in this repository, CI variables, the installer image, or the USB.
- The operator SSH private key never leaves the operator machine.
- The installer may embed only an authorized public SSH key and an age public
  recipient.
- exFAT permissions are not a security boundary. Every secret written to the
  USB must be encrypted before the first byte is committed.
- Generated credentials are stable across first-boot retries and are rotated
  after import into the long-lived secret store.
- The generated `operator` and Technitium bootstrap passwords exist in plaintext
  only until encrypted enrollment is committed. SSH password authentication
  remains disabled.
- A root-only static Technitium token remains on each appliance solely for local
  health and encrypted backup jobs. It is never written to USB in plaintext.
- SSH host private-key escrow is disabled by default. Public fingerprints are
  always recorded; encrypted private-key escrow requires a separate decision.

## Agent access

Use distinct identities so every action is attributable:

| Identity | Allowed operations |
| --- | --- |
| `agent-dns-reader` | Health, zones, records, logs, and statistics view |
| `agent-dns-planner` | Read state and produce a proposed diff |
| `agent-dns-applier` | Apply an approved plan; no user or token administration |
| `dns-backup` | Create and verify backups only |
| `human-admin` | Emergency administration and credential rotation |

Tokens must be stored outside this repository, passed in headers rather than
URLs, and rotated on a documented schedule even if the upstream token does not
expire automatically.

## Network exposure

- DNS: UDP/TCP 53 from the approved LAN.
- SSH, Cockpit, and metrics: management sources only.
- Technitium API: management sources plus the three fixed node addresses needed
  for cluster traffic; it is not open to the rest of the LAN.
- Technitium management must use TLS before agent write access is enabled.
- IPv6 exposure follows an explicit policy; an accidental wildcard IPv6 listener
  is treated as a failure.
- The writable USB partition is mounted `nodev,nosuid,noexec` and never supplies
  executable installer code.

## Change safety

- Read-only tools are the default agent surface.
- Destructive operations require an explicit confirmation field and an approved
  pull request.
- Apply one node at a time and verify canary DNS resolution before continuing.
- Router DHCP settings change only after all three resolvers pass live tests.

## Recovery access tradeoff

`operator` has passwordless sudo because a failed USB write can otherwise leave
the host reachable by SSH key but impossible to repair. This makes possession of
the authorized SSH private key equivalent to root access. Compensating controls
are key-only SSH, management-CIDR firewall restriction, no private key on the
USB, and host-key fingerprint verification from enrollment.
