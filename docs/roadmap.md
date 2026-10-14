# Implementation roadmap

## Phase 0: source and supply-chain lock

- Record Debian ISO, Debian packages, Technitium OCI image, and build-tool
  versions with SHA-256 or immutable digests.
- Add a reproducible image builder that downloads into ignored cache paths.
- Generate image manifest, checksums, and an SBOM.

## Phase 1: fail-closed installer

- Implement BIOS and UEFI boot menus with internal disk as the safe default.
- Require a role selection and exact hardware, serial/UUID, MAC, and disk match.
- Refuse duplicate completed roles unless an explicit reinstall path is used.
- Keep all destructive gates disabled until inventory is complete.

## Phase 2: retry-safe first boot and enrollment

- Generate credentials once and reuse them across retries.
- Add the `DNS-ENROLL` exFAT data partition.
- Encrypt recovery output with a dedicated age recipient.
- Perform atomic write, sync, validation, and completion marking.
- Remove the Technitium bootstrap plaintext after initialization.

## Phase 3: service and cluster configuration

- Configure firewall and management TLS.
- Create the Technitium three-node cluster and `home.arpa` zones.
- Add least-privilege human and agent identities.
- Add backup, restore, update, rollback, and configuration drift checks.

## Phase 4: agent management plane

- Add desired-state DNS records and a machine-readable preview.
- Evaluate and pin a safety-focused Technitium MCP gateway.
- Add read-only-by-default MCP tokens and structured audit logs.
- Add service discovery names and optional A2A Agent Cards without secrets.

## Phase 5: verification and release

- Test no-network install under BIOS and UEFI virtualization.
- Inject failures after credential generation and during USB writes.
- Test wrong hardware, extra disks, missing USB, duplicate roles, and corrupted
  enrollment partitions.
- Pilot on `dns01`, then install `dns02` and `dns03` one at a time.
- Publish a tagged installer only after physical verification.
