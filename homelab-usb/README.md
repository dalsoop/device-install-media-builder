# Homelab Bootstrap USB

The utility USB uses Ventoy for a deliberate, operator-selected boot menu. It
contains the locally built guarded DNS appliance installer plus checksum-pinned
Proxmox VE, Proxmox Backup Server, TrueNAS SCALE, Pop!_OS, and Debian Live
images. A separate trailing exFAT partition named `DNS-ENROLL` remains
available to the DNS installer's first-boot writer.

No Proxmox, Proxmox Backup Server, TrueNAS, or Pop!_OS answer file is included.
Those installers can erase whole disks and therefore remain interactive. The
DNS entry is unattended only after its exact HP hardware, NIC, disk, role, and
reinstall gates pass.

Ventoy starts in Korean and offers Korean menu aliases. Press `L` in Ventoy to
select another interface language. Pop!_OS remains an upstream, checksum-pinned
ISO; choose `한국어` on its first installer screen by following
[`guides/pop-os-ko.md`](guides/pop-os-ko.md). This preserves the upstream image
checksum instead of maintaining an unverified remaster.

## Capacity

The six upstream images already occupy more than 11 GB before the custom DNS
ISO, the 2 GiB `DNS-ENROLL` partition, manifests, and filesystem overhead. A
16 GB device is not supported. Use 32 GB at minimum and 64 GB for comfortable
headroom or additional recovery images. The writer calculates the exact total
and refuses an undersized target before erasing it.

## Build on Linux

Fetch and verify immutable upstream images:

```sh
homelab-usb/fetch-images
```

Build the guarded DNS ISO separately, then identify the removable USB and its
serial. The writer refuses non-removable disks, the root disk, a missing serial,
bad checksums, insufficient capacity, or a confirmation that omits the serial:

```sh
sudo homelab-usb/write-usb-linux \
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
- Open Proxmox VE, Proxmox Backup Server, TrueNAS, and Pop!_OS installers only
  on disposable VM disks before using them on physical systems.
- Treat Secure Boot as unverified until each exact image and HP firmware path is
  tested; Ventoy may require key enrollment or Secure Boot to be disabled.
- From Pop!_OS or another Linux environment, run
  `tools/dns-appliance-status-monitor/start` and verify UDP/TCP DNS plus the
  management ports for all three nodes.
