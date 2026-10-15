# Architecture

## System boundary

The repository has two products with a shared safety model:

1. a fork-oriented multiboot OS flasher; and
2. a local DNS-appliance profile that demonstrates guarded unattended
   installation and post-install management.

The public Gujo Homelab OS Catalog is an external, data-only dependency.
The Installer pins one exact Catalog commit, selects entries, adds fork-local
entries and bundles, and produces a resolved plan. The Installer never executes
Catalog code.

Ongoing DNS host configuration and long-lived secrets are outside this
repository. The repository owns Day-0 media, first boot, enrollment, portable
verification tools, and explicit management commands.

## Components and dependency direction

```text
Public Catalog JSON at an exact commit
                   |
                   v
usb-media/resolve-catalog <--- collections/ + local-entries/
                   |
                   v
       resolved catalog plan
          |        |        |
          v        v        v
        fetch    Ventoy    USB writer
                             |
                             v
                    Gujo Homelab OS USB

DNS runtime artifact
installer/ --> guarded ISO --> USB local entry
                                  |
                                  v
                         three DNS appliances
                                  |
                                  v
                         management/ commands
```

Dependencies point from orchestration toward data and specialized modules.
Catalog data does not depend on the Installer. General media entries do not
depend on the DNS profile. Management commands operate after installation and
do not become an appliance boot dependency.

## Media composition

`usb-media/composition.json` pins the Catalog repository, 40-character
revision, index, bootloader, local entries, USB labels, reserve sizes, and
bundles. `collections/device-os.json` selects public entry IDs and defines
menu groups. The resolver copies only referenced JSON, validates paths and IDs,
and emits `work/device-os/catalog.json`.

The resolved plan is the single input for download, checksum verification,
Ventoy menu generation, capacity calculation, and USB staging. Existing
strategies are:

- `locked-download`: HTTPS plus a lowercase SHA-256;
- `runtime-artifact`: a caller-supplied file checked against a build manifest;
- `repository-file`: one reviewed repository file staged as a bundle;
- `repository-tree`: one reviewed repository directory staged as a bundle.

This is data polymorphism within implemented strategies, not a dynamic plug-in
system. A new entry using an existing strategy requires data only. A new
strategy or profile adapter requires Installer code and rejection coverage.

## DNS installation planes

### Installer plane

The immutable Debian image contains the offline package closure, a digest-pinned
Technitium OCI image, a checksum-pinned Tailscale archive, inventory matching,
and first-boot units. A separate `DNS-ENROLL` exFAT partition receives
plaintext enrollment evidence and age-encrypted recovery secrets.

The boot menu has no destructive timeout. After a deliberate DNS installer
selection, `install-gate` must resolve exactly one inventory role and exactly
one non-removable internal disk before partitioning.

### Appliance plane

Each appliance runs Technitium DNS, OpenSSH, Cockpit, Tailscale, nftables,
health checks, and encrypted backup jobs. Tailscale is installed offline and
enrolled later. General AI runtimes and MCP gateways do not run on appliances.

### Management plane

The management host imports enrollment, forms the cluster, applies reviewed DNS
desired state, mints one-time Tailscale keys, collects encrypted backups,
performs explicit restore, and hosts the read-only status page.

Tailscale is a management path only. Appliances reject tailnet DNS, do not
advertise routes or exit-node service, and do not enable Serve, Funnel, or
Tailscale SSH.

## Completion boundary

A DNS installation is complete only when the internal disk boots with the USB
still attached, static identity is correct, SSH key access works, DNS answers
over UDP and TCP, Technitium and Cockpit answer, the public enrollment record
validates, recovery data is encrypted, and the completed generation is
atomically synchronized to `DNS-ENROLL`.

Source simulation, image creation, USB writing, first boot, three-node cluster
formation, and router DHCP cutover are separate states and must be reported
separately.

