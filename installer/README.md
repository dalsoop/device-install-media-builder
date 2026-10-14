# Installer source

This directory will contain the boot menus, preseed, disk-selection gate,
first-boot units, offline packages manifest, and encrypted USB enrollment writer.

No destructive installer is committed in the bootstrap revision. Implementation
starts only after all three physical machines have exact inventory values and the
safe-default internal-disk boot path is covered by a VM test.
