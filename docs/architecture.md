# Architecture

## Three planes

### Installer plane

The installer image is immutable and contains everything required for an offline
Debian installation. A separate writable USB partition labeled `DNS-ENROLL`
stores only enrollment results and sanitized logs.

The boot menu defaults to the installed internal disk. Installation entries are
manual choices so that keeping the USB inserted for first-boot enrollment does
not start a second installation.

### Appliance plane

Each appliance runs only infrastructure required for DNS and host management:

- Technitium DNS Server
- OpenSSH
- Cockpit
- firewall rules
- a small machine-readable health exporter
- encrypted backup and enrollment units

General-purpose AI agents and MCP servers do not run on these machines.

### Management plane

The management plane owns orchestration and agent access:

- Git pull requests hold desired DNS state.
- CI produces a change plan but does not apply it automatically.
- A separately deployed MCP gateway exposes read-only tools by default.
- A limited apply identity is enabled only for approved changes.
- Prometheus blackbox DNS probes and node metrics verify all three nodes.

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
