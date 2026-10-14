# DNS Appliance Provisioning

This repository owns the reproducible, offline bootstrap of the three bare-metal
DNS appliances `dns01`, `dns02`, and `dns03`.

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

## Repository boundaries

- Day-0 media, first boot, and USB enrollment live here.
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
