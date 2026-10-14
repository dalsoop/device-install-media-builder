# Installer source

This directory contains the first implementation of the Debian OS installer:

- `build-image` builds an offline amd64 image on a Debian 13 builder.
- `capture-inventory` hashes the exact identity of one HP PC, NIC, and disk.
- `simple-cdd/` holds the unattended Debian Installer profile.
- `scripts/install-gate` refuses partitioning unless one inventory entry and one
  internal disk match exactly.
- `payload/` holds host files installed before first boot.

The generated image installs Debian, OpenSSH, Cockpit, nftables, and operational
utilities without Internet access. It does not yet install Technitium or write
credentials to `DNS-ENROLL`; those are separate first-boot phases.

See [`docs/os-install.md`](../docs/os-install.md) before building or booting it.
