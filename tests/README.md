# Tests

`install-gate-simulation.sh` runs the destructive-selection gate against an
isolated fake sysfs tree. It never opens a real block device.

The simulation covers:

- one exact HP/NIC/disk match selecting `/dev/sda`;
- wrong DMI identity stopping before selection;
- an erase-disabled role stopping before selection;
- two matching internal disks stopping as ambiguous;
- the installer media never being selected as the target.

This simulation is necessary but not sufficient. It does not replace building
the ISO, booting Debian Installer under BIOS and UEFI, or the physical `dns01`
pilot.
