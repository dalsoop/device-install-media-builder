# Gujo Homelab OS Installer

[![CI](https://github.com/dalsoop/gujo-homelab-os-installer/actions/workflows/ci.yml/badge.svg)](https://github.com/dalsoop/gujo-homelab-os-installer/actions/workflows/ci.yml)

Build one verified, Korean-first multiboot USB from public operating-system
metadata and fork-local profiles. The public
[Gujo Homelab OS Catalog](https://github.com/dalsoop/gujo-homelab-os-catalog)
supplies official URLs and SHA-256 values. This repository owns selection,
resolution, downloads, verification, Ventoy layout, physical USB safeguards,
and local profiles.

The default composition includes Proxmox VE, Proxmox Backup Server, TrueNAS
SCALE, Pop!_OS, Debian Live, and a guarded offline installer for three HP DNS
appliances.

> **Fork this Installer repository for normal use.** Your fork owns the OS
> selection, local profiles, and private hardware policy. Do not fork the
> Catalog unless you are contributing reusable public OS metadata.

> Current assurance: repository contracts and isolated simulations run in CI.
> Physical USB behavior, target firmware, Secure Boot, destructive disk
> selection, and post-install boot are not yet qualified. Source success is not
> permission to write a physical device.

## Recommended fork workflow

Fork only this Installer repository and manage your collection and local
profiles in that fork. Send reusable public media metadata to the Catalog
repository through its separate contributor workflow.

```sh
git clone https://github.com/<your-account>/gujo-homelab-os-installer.git
cd gujo-homelab-os-installer

./device-os available
./device-os plan
./device-os capacity --capacity 16GB
./device-os simulate
```

`simulate` resolves the exact Catalog commit and validates the intended media,
but it does not download ISO files or write a disk.

On a supported Linux builder, download and verify selected public media:

```sh
./device-os prepare
```

macOS can write a prepared full-disk image with the guarded native writer:

```sh
sudo ./device-os write-image-macos \
  --image /absolute/path/device-os.raw \
  --device /dev/diskN \
  --confirm 'ERASE /dev/diskN MEDIA_NAME EXACT_BYTES'
```

The macOS path requires an MBR image whose exact byte size matches the removable
target. It rejects internal or virtual targets and GPT images. To prevent Disk
Arbitration from mounting exFAT while verification runs, it hides the partition
map, writes and reads back the image body, commits and verifies the first MiB
last, then unmounts and ejects. Full-disk image assembly currently runs the
pinned official Linux Ventoy installer in an isolated QEMU guest because
Ventoy does not ship a native macOS installer.

After separately building the DNS runtime artifact, re-identify a disposable
removable device and write it with an exact path-and-serial confirmation:

```sh
sudo ./device-os write \
  --device /dev/sdX \
  --runtime-artifact dns-appliance=/absolute/path/dns-appliance.iso \
  --runtime-manifest dns-appliance=/absolute/path/build-manifest.json \
  --confirm 'ERASE /dev/sdX USB_SERIAL'
```

This destroys the selected USB. Use `capacity` with the DNS runtime artifact
to calculate the exact configured minimum before writing. A 32 GB or larger USB
is recommended for the default composition.

```sh
./device-os capacity --capacity 16GB \
  --runtime-artifact dns-appliance=/absolute/path/dns-appliance.iso \
  --runtime-manifest dns-appliance=/absolute/path/build-manifest.json

# Read the capacity of an attached device without writing it.
./device-os capacity --device /dev/disk5
```

Without the runtime artifact, the command reports the maximum space still
available for unknown entries. It verifies cached files and runtime artifacts
against their SHA-256 before issuing a final fit result. Missing public files use
a header/one-byte HTTPS estimate; `--offline` disables probes, and estimates
remain pending until the artifacts are locally verified.

## Customize the USB

```sh
./device-os include pop-os
./device-os exclude pop-os
./device-os plan
```

These commands update `collections/device-os.json`. Put private,
organization-specific, or hardware-specific entries under
`usb-media/local-entries/` and register them in
`usb-media/composition.json`.

To use another Catalog fork, change both its repository URL and exact
40-character commit. Branches and `latest` are intentionally rejected.

## Repository split

```text
gujo-homelab-os-catalog
  public bootloader and OS JSON, official URLs, SHA-256
                         |
                         | exact pinned commit
                         v
gujo-homelab-os-installer fork
  collection, local profiles, support bundles, media pipeline
                         |
                         v
                  Gujo Homelab OS USB
```

| Path | Responsibility |
| --- | --- |
| `device-os` | Human-facing selection, capacity, plan, simulation, preparation, and Linux/macOS write entry points |
| `usb-media/composition.json` | Catalog pin, USB properties, local profiles, bundles |
| `collections/device-os.json` | Selected public entries and menu groups |
| `usb-media/local-entries/` | Fork-local runtime artifacts and profiles |
| `installer/` | Default DNS profile's offline image and destructive gate |
| `management/` | DNS cluster, Tailscale, desired state, backup, recovery, status |

Adding another entry that uses an existing source kind is data-only. Adding a
new source kind or profile adapter requires Installer implementation and rejection
tests; this is not a dynamic plug-in loader.

## Documentation

- [Architecture](docs/architecture.md)
- [Business rules](docs/business-rules.md)
- [Security](docs/security.md)
- [Engineering standards](docs/standards.md)
- [Operations](docs/operations.md)
- [Data and CLI contracts](docs/contracts.md)
- [Implementation status](docs/tracking/status.md)
- [Open findings](docs/tracking/findings.md)
- [Decision index](docs/tracking/decisions/index.md)

Detailed operator guides remain available for
[DNS image creation](docs/os-install.md),
[network cutover](docs/network-cutover.md),
[backup and recovery](docs/recovery.md), and
[verification gates](docs/verification.md).

