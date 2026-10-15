# Device Install Media Builder

This repository selects verified public media from Device Install Media Catalog,
assembles a bootable USB, and owns the guarded offline profile for the three
bare-metal DNS appliances `dns01`, `dns02`, and `dns03`.

## Safety invariants

- Never commit passwords, API tokens, private keys, recovery archives, or USB
  enrollment output. Public SSH keys and age recipients are allowed only in
  explicitly named public-input files.
- Never commit ISO, QCOW2, OCI archives, Debian packages, or generated disks.
  Commit versioned download locations and SHA-256 digests instead.
- Installer code must fail closed unless the selected role, HP product identity,
  system serial/UUID, NIC MAC, and internal disk identity match inventory.
- A successful install is not complete until the installed disk boots, DNS UDP
  and TCP probes pass, management services answer, and encrypted enrollment data
  is atomically written to the USB data partition.
- The installer may erase only the resolved internal disk. The USB boot device,
  removable devices, and unresolved or multiple candidates must always stop the
  install.
- Agents receive read-only access by default. DNS writes require a reviewed
  desired-state change, a machine-readable plan, and an explicit apply gate.
- `usb-media/composition.json` pins the external catalog commit and owns USB
  properties, local profiles, and bundles. `collections/device-install.json`
  owns the selected public entries. Never execute code fetched from the catalog.
- Add public operating-system metadata to
  `dalsoop/device-install-media-catalog`; add private or profile-specific media
  under `usb-media/local-entries/`. New source kinds must implement fetch,
  verify, stage, and rejection tests.

## Repository boundaries

- Media selection, downloads, USB assembly, Day-0 installation profiles, first
  boot, enrollment, and portable read-only verification tools live here.
- Public bootloader and operating-system metadata lives in
  `dalsoop/device-install-media-catalog`.
- Ongoing host configuration belongs in `gujoai/infra/host-infra`.
- Long-lived encrypted secrets belong in the existing principal secrets store.
- The MCP gateway runs on a management host, never on the DNS appliances.

## Change workflow

- Protect `main`; make substantive changes through pull requests.
- Keep destructive behavior disabled until a physical `dns01` pilot passes.
- Test BIOS and UEFI paths, zero-network installation, retry behavior, and
  fail-closed disk selection before publishing an installer release.
- A release contains checksums and manifests. Writing a release to a physical
  USB is a separate, explicitly approved operation.
