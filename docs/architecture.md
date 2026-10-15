# Architecture

## Three planes

### Installer plane

The installer image is immutable and contains everything required for an offline
Debian installation. A separate writable USB partition labeled `DNS-ENROLL`
stores only enrollment results and sanitized logs.

The boot menu has no unattended timeout. Installation requires a manual choice,
so keeping the USB inserted for first-boot enrollment cannot automatically
start a second installation. Firmware boot order should still prefer the
internal disk after the pilot.

### Appliance plane

Each appliance runs only infrastructure required for DNS and host management:

- Technitium DNS Server
- OpenSSH
- Cockpit
- Tailscale, installed offline and enrolled later
- firewall rules
- a small machine-readable health exporter
- encrypted backup and enrollment units

General-purpose AI agents and MCP servers do not run on these machines.

Technitium runs as a root-managed Podman container loaded from an OCI archive
embedded in the installer. It binds only IPv4, uses explicit recursion ACLs,
and stores configuration under `/var/lib/technitium`. Cockpit authenticates the
local `operator` account with a generated per-node password; SSH remains
public-key-only.

### Management plane

The management plane owns orchestration and agent access:

- Git pull requests hold desired DNS state.
- CI produces a change plan but does not apply it automatically.
- A separately deployed MCP gateway exposes read-only tools by default.
- A limited apply identity is enabled only for approved changes.
- Prometheus blackbox DNS probes and node metrics verify all three nodes.
- An OAuth credential kept on the management host mints one one-off,
  pre-authorized `tag:dns-appliance` key per node and sends only that key over
  LAN SSH. The key is removed immediately after enrollment.

Tailscale is a management path, not a routing authority. Appliances use
`--accept-dns=false`, advertise no subnet or exit-node routes, and do not enable
Tailscale SSH by default. Normal OpenSSH remains the recovery surface.

### Utility media plane

`homelab-usb/` builds a Korean-first Ventoy menu containing the guarded DNS
appliance ISO, Proxmox VE, Proxmox Backup Server, TrueNAS SCALE, Pop!_OS, and
Debian Live. Upstream images are version- and SHA-256-pinned; generated images
and ISOs remain outside Git. A distinct `DNS-ENROLL` partition preserves the
DNS first-boot contract. A dependency-free, read-only status page can run from
the USB on Pop!_OS or another Python 3 Linux environment to probe all three DNS
nodes without installing software on them.

Proxmox VE, Proxmox Backup Server, TrueNAS, and Pop!_OS always remain
interactive. Their inclusion on the same USB does not authorize unattended
erasure or reuse the DNS hardware inventory.

## Installation completion contract

An installation is complete only when all conditions are true:

1. The machine booted from its internal disk while the USB remained attached.
2. Hostname and static address match the selected inventory role.
3. SSH key authentication succeeds locally.
4. DNS answers the canary query over UDP and TCP.
5. Technitium and Cockpit health checks pass.
6. `public.json` validates against the enrollment schema.
7. The recovery archive is encrypted to the configured age recipient.
8. Files are atomically committed and synchronized to `DNS-ENROLL`.

NTP may be recorded as `degraded-offline` during a deliberately disconnected
installation. It must become healthy before router DHCP cutover.

## Enrollment layout

```text
DNS-ENROLL/
├── installer.json
└── records/
    ├── dns01/<generation>/
    │   ├── public.json
    │   ├── recovery.tar.age
    │   ├── install.log
    │   └── COMPLETE
    ├── dns02/<generation>/
    └── dns03/<generation>/
```

`public.json` contains hardware identity, addresses, image/build identifiers,
public SSH host-key fingerprints, certificate fingerprints, service health, and
timestamps. Passwords and private recovery material exist only inside the age
archive.

`records/<role>/ACTIVE` selects the current completed generation. A reinstall
is blocked unless `reinstall/<role>.allow` names that exact generation and the
matching system UUID hash, so an old authorization cannot erase a later install.
