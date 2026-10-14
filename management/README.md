# Agent management plane

The management plane is separate from the DNS appliances.

Implemented bootstrap and operating surfaces:

- `import-enrollment` decrypts completed USB records into a caller-selected
  protected directory; it never writes credentials into the repository.
- `cluster-bootstrap` initializes dns01, joins dns02/dns03, imports the catalog
  backed `home.arpa` zone, and emits an age-encrypted agent token bundle.
- `dnsctl health` uses the reader token.
- `dnsctl plan` emits current and desired hashes plus a human diff.
- `dnsctl apply` requires a clean checked-out approved commit and literal
  `--confirm APPLY`; audit output is JSONL and contains no token.
- `collect-backups` retrieves only already-encrypted backup files over SSH.
- `restore-node` requires an explicit target URL, local age identity, and exact
  restore confirmation.
- `authorize-reinstall` creates a one-generation erase authorization after an
  explicit role confirmation.
- `network-preflight` verifies that the configured router prefix contains all
  three DNS addresses and reports current reachability.

The MCP gateway source or deployment remains intentionally unvendored until its
dependencies, authentication boundaries, audit behavior, and destructive tool
gates are reviewed and pinned. It belongs on a management host, never on the DNS
appliances. Until then, `dnsctl` is the auditable apply boundary.
