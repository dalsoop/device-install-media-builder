# OS installation

The installer uses Debian Installer preseeding through Simple-CDD. Simple-CDD
places the selected packages and dependencies on the image, so installation does
not require a working Internet connection.

Upstream references:

- [Debian 13 automated installation appendix](https://www.debian.org/releases/trixie/amd64/apb.en.html)
- [Simple-CDD manual](https://manpages.debian.org/trixie/simple-cdd/simple-cdd.1.en.html)

## Safety model

The sample inventory cannot erase a disk. Before partitioning, `install-gate`
requires all of the following:

1. Product name, product SKU, system serial, system UUID, and one NIC MAC hash
   match exactly one of `dns01`, `dns02`, or `dns03`.
2. Exactly one non-removable disk matches the expected model hash, serial hash,
   and minimum byte size.
3. The matched disk is not the device that supplied `/cdrom`.
4. `destructive_install_enabled=true` is present in that node's local inventory.

The image stores SHA-256 hashes of hardware identifiers, not their raw values.
The role, address, and network settings are not secret.

## Capture each machine

Boot a trusted Debian live environment and identify the wired interface and the
single internal target disk. From a checkout of this repository, run:

```sh
mkdir -p inventory/local
sudo installer/capture-inventory dns01 10.0.5.1 enp1s0 /dev/sda \
  > inventory/local/dns01.conf
```

Repeat for `dns02` and `dns03`. Review every generated file. Only after confirming
the machine and disk should its final line be changed from `false` to `true`.
For the first physical pilot, enable only `dns01`; disabled role files may remain
as copies of their examples:

```sh
cp inventory/nodes/dns02.conf.example inventory/local/dns02.conf
cp inventory/nodes/dns03.conf.example inventory/local/dns03.conf
```

The builder requires at least one enabled role.

Copy the operator's public SSH key, never the private key:

```sh
cp /path/to/id_ed25519.pub installer/inputs/operator-authorized-keys
```

## Build

Build on an amd64 Debian 13 machine with `simple-cdd` installed:

```sh
sudo apt-get install simple-cdd debian-cd debian-archive-keyring \
  reprepro rsync xorriso isolinux syslinux-common
installer/build-image
```

The builder refuses macOS, non-amd64 hosts, missing SSH keys, incomplete
inventory, placeholders in enabled roles, malformed hashes, and a completely
disabled inventory. Build output is written under `installer/simple-cdd/images/`
and remains ignored by Git.

The current profile follows Debian `trixie`; exact package-version and mirror
snapshot locking is tracked separately before any installer release is trusted.

## Install behavior

Boot the generated image and deliberately select the installer entry. There is
no automatic boot timeout. After that selection, hardware identity chooses the
role and the remaining Debian installation is unattended. A mismatch stops the
installer before partitioning.

The resulting host has:

- the role hostname and static address;
- a locked `operator` password and the supplied SSH public key;
- root SSH login and SSH password authentication disabled;
- Cockpit on TCP 9090;
- nftables allowing DNS from `10.0.0.0/16` and management access from the same
  temporary LAN scope;
- the installation facts in `/etc/dns-appliance/install.env`.

This stage is not the complete appliance. Technitium, encrypted enrollment,
health-gated completion, and cluster joining must succeed before a node is put
into router DHCP service.
