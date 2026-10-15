# 0002: Use a polymorphic media catalog

- Status: accepted
- Date: 2026-10-15

## Context

The initial USB writer embedded every product name, version, filename, checksum,
destination, and Ventoy alias in shell code. Adding Proxmox Backup Server and
Pop!_OS required editing fetch, verify, capacity, copy, menu, and documentation
branches independently. That creates drift and makes a broader product name
misleading because the implementation remains DNS-shaped.

## Decision

`homelab-usb/catalog.json` is the single source of truth for media entries,
groups, USB properties, bundles, and the bootloader. Every boot entry implements
the same identity, destination, menu, behavior, profile, and source contract.

Source behavior is selected by `source.kind`:

- `locked-download` resolves an immutable HTTPS URL and SHA-256.
- `runtime-artifact` resolves a caller-provided file and validates it against a
  caller-provided build manifest.
- `repository-file` and `repository-tree` stage reviewed support bundles.

Product-specific behavior is selected independently through `profile_adapter`.
The DNS adapter owns encrypted enrollment metadata and remains the only guarded
unattended profile. Generic ISO entries remain interactive.

## Consequences

Adding another image of an existing source kind changes only the catalog and
tests. Adding a source kind requires explicit fetch, verification, and staging
support. Adding a product exception requires a new profile adapter rather than
weakening a shared path.

The catalog is copied onto every USB and hashed alongside the ISO manifest, so
the assembled media records the exact declarative input that produced it.
