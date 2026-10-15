# SUPERUSB multiboot media

The utility USB uses Ventoy for a deliberate, operator-selected boot menu. It
contains the locally built guarded DNS appliance installer plus checksum-pinned
Proxmox VE, TrueNAS, and Debian Live images. A separate trailing exFAT partition
named `DNS-ENROLL` remains available to the DNS installer's first-boot writer.

No Proxmox or TrueNAS answer file is included. Those installers can erase whole
disks and therefore remain interactive. The DNS entry is unattended only after
its exact HP hardware, NIC, disk, role, and reinstall gates pass.

## Capacity

A verified 16 GB device can hold the initial four images if the locally built
DNS ISO remains within the calculated capacity. Use 32 GB at minimum for useful
headroom and 64 GB if retaining multiple releases or adding recovery images.

## Build on Linux

Fetch and verify immutable upstream images:

```sh
superusb/fetch-images
```

Build the guarded DNS ISO separately, then identify the removable USB and its
serial. The writer refuses non-removable disks, the root disk, a missing serial,
bad checksums, insufficient capacity, or a confirmation that omits the serial:

```sh
sudo superusb/write-usb-linux \
  --device /dev/sdX \
  --dns-iso installer/simple-cdd/images/<dns-image>.iso \
  --dns-manifest artifacts/build-manifest.json \
  --confirm 'ERASE /dev/sdX USB_SERIAL'
```

Ventoy installation erases the target. Re-identify the target immediately
before every run. macOS is intentionally not supported by this writer because
the upstream Ventoy installer and guarded partition construction run on Linux.

## Required validation

- Verify every copied ISO against `manifests/SHA256SUMS`.
- Boot the menu under legacy BIOS and UEFI on expendable test hardware.
- Boot the custom DNS ISO through Ventoy and prove that `/dev/mapper/Ventoy`
  cannot be selected as the installation target.
- Leave the USB attached during internal-disk reboot and prove the firmware does
  not re-enter an installer automatically.
- Complete a non-destructive boot of Debian Live.
- Open Proxmox and TrueNAS installers only on disposable VM disks before using
  them on physical systems.
- Treat Secure Boot as unverified until each exact image and HP firmware path is
  tested; Ventoy may require key enrollment or Secure Boot to be disabled.
