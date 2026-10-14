# Source locks

Generated media and downloaded binaries are not stored in Git. Before the image
builder is implemented, add lock files for:

- Debian installer ISO URL, version, size, and SHA-256
- every offline Debian package name, version, architecture, URL, and SHA-256
- Technitium image repository, version, platform, immutable digest, and archive
  SHA-256
- image-building tool versions
- the public authorized SSH key fingerprint
- the dedicated age recovery recipient fingerprint

Builds must fail if a source is mutable, a checksum is missing, or a downloaded
file differs from its lock.
