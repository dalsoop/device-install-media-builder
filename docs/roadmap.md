# Implementation and verification roadmap

A checked source item is implemented in the repository. It is not proof of
physical operation; release remains blocked by `docs/verification.md`.

## Phase 0: source and supply-chain lock

- [x] Pin Debian 13.7, a dated Debian snapshot, Simple-CDD, and the Technitium
  amd64 OCI manifest digest.
- [x] Fetch the OCI archive into an ignored cache with digest verification.
- [x] Generate an ISO manifest, package list and hashes, checksums, and SPDX SBOM.
- [ ] Rebuild twice on the designated amd64 Debian builder and compare outputs.

## Phase 1: fail-closed installer

- [x] Require deliberate installer selection; there is no destructive timeout.
- [x] Match exact product, serial/UUID, NIC MAC, and internal disk identity.
- [x] Refuse USB/removable/ambiguous disks and disabled inventory roles.
- [x] Refuse a completed role without a generation-bound reinstall token.
- [ ] Boot and complete installs under both BIOS and UEFI/Secure Boot.

## Phase 2: retry-safe first boot and enrollment

- [x] Generate stable per-node credentials once and reuse them across retries.
- [x] Create a separate `DNS-ENROLL` exFAT partition with a guarded writer.
- [x] Encrypt recovery material to a dedicated native age recipient.
- [x] Validate schema, atomically rename, sync, and mark completion.
- [x] Remove bootstrap-password plaintext after enrollment.
- [ ] Exercise power-loss retries against a real exFAT USB.

## Phase 3: service and cluster configuration

- [x] Install digest-pinned Technitium, Cockpit, SSH, firewall, metrics, and NTP.
- [x] Install a checksum-pinned Tailscale client offline and provide one-off,
  tagged management-host enrollment without embedding credentials.
- [x] Provide cluster initialization/join and catalog-backed `home.arpa` import.
- [x] Create separate read, plan, and apply API identities.
- [x] Add encrypted backup collection and explicit restore tooling.
- [ ] Move ongoing update policy to `host-infra` and run a rollback drill.
- [ ] Apply and review the tailnet policy, create the scoped OAuth credential,
  and complete a three-node enrollment/reboot drill.

## Phase 4: agent management plane

- [x] Add a Git-owned zone file and machine-readable plan/apply CLI.
- [x] Require a clean approved commit and explicit `APPLY` confirmation.
- [x] Emit redacted JSONL audit events and default agents to read-only tokens.
- [ ] Evaluate and pin a management-host MCP gateway; none runs on appliances.

## Phase 5: verification and release

- [ ] Build the ISO and verify the complete offline package closure.
- [ ] Test zero-network BIOS, UEFI, USB-left-in, and internal-disk reboot paths.
- [ ] Inject failures after credential generation and during USB writes.
- [ ] Pilot `dns01`, then install `dns02` and `dns03` one at a time.
- [ ] Complete cluster, backup/restore, primary-loss, and DHCP rollback drills.
- [ ] Publish a tagged installer only after the physical gates pass.

## Phase 6: Device Install USB

- [x] Split the public, per-entry Device Install Media Catalog from the
  fork-oriented Device Install Media Builder.
- [x] Pin the catalog repository commit and resolve selected public entries with
  local runtime profiles without executing fetched code.
- [x] Pin Ventoy, Debian Live, Proxmox VE, Proxmox Backup Server, TrueNAS SCALE,
  and Pop!_OS downloads and checksums in the public catalog.
- [x] Add a serial-bound Linux writer that creates `DEVICE-INSTALL` and a separate
  `DNS-ENROLL` partition.
- [x] Add Korean-first Ventoy aliases, a Korean Pop!_OS guide, and a portable
  three-node DNS appliance status monitor.
- [ ] Build the DNS ISO, assemble the physical utility USB, and verify all
  copied checksums.
- [ ] Test the exact HP legacy BIOS, UEFI, Secure Boot, mapper-device exclusion,
  and USB-left-in paths before relying on the media.
