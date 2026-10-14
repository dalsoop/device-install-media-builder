# Verification and release gates

No source review or unit simulation guarantees that an installer can safely
erase and rebuild physical hardware. Complete every gate in order and attach
logs, checksums, screenshots, and resulting `public.json` files to the release
evidence.

## Automated source gates

- `tests/install-gate-simulation.sh` passes all 12 cases.
- `tests/management-simulation.sh` passes all 4 cases.
- `tests/repository-contract.sh` passes.
- ShellCheck reports no errors.
- GitHub CI passes on the exact commit to be built.
- `build/verify-locks` passes and the fetched OCI manifest matches the amd64
  digest.

## Build gates

- Build on an amd64 Debian 13.7 host with Simple-CDD 0.6.9.
- Build twice from clean ignored directories and compare ISO, package closure,
  manifest, and SBOM.
- Verify the ISO checksum before and after USB writing.
- Inspect BIOS and UEFI boot files; verify signed Secure Boot components.

## Virtual-machine gates

- BIOS install with networking disconnected.
- UEFI and Secure Boot install with networking disconnected.
- Wrong DMI, wrong MAC, wrong disk serial, two matching disks, removable disk,
  missing `DNS-ENROLL`, completed role, stale reinstall token, and corrupt exFAT
  all stop before erase.
- Power loss after credential generation, during encrypted output, after final
  record rename, and before local completion converges without changing secrets.
- Reboot with the USB attached does not start another installation.

## Physical dns01 pilot

- Photograph and record the HP product number, wired NIC, target disk, firmware
  mode, Secure Boot state, and boot order.
- Capture inventory from a trusted live system and enable only `dns01`.
- Confirm the erase target by serial immediately before selecting install.
- Verify internal-disk boot, SSH host fingerprint, SSH key login, sudo, Cockpit
  login, Technitium TLS fingerprint, DNS UDP/TCP, NTP, metrics, and encrypted
  enrollment.
- Decrypt recovery on the management machine and prove the Cockpit password.
- Run one encrypted backup and isolated restore drill.

Only after dns01 passes should dns02 and dns03 be enabled one at a time. Cluster
and router DHCP cutover are separate final gates. Publishing or writing a new
physical USB always requires a fresh target check and explicit erase approval.
