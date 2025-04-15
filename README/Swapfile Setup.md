# Swapfile Setup

Check if any swap files (or partitions) are already in use:

```bash
sudo swapon -s
```

Turn off all swap devices (you can also remove them yourself):

```bash
sudo swapoff -a
```

Run the following from the arch installer, as I could not figure out how to create a new btrfs volume from the booted system.

```bash
# List all of the disks and partitions
lsblk

# After identifying which disk to unencrypt, run:
cryptsetup open /dev/nvme0n1p2 cryptroot

# Mount the unencrypted partition to /mnt
mount /dev/mapper/cryptroot /mnt

# Create New Btrfs Volume called @swap
btrfs subvolume create /mnt/@swap
```

If using arch-chroot right after install, its easier:

```bash
# List all mount points
findmnt

# Mount the unencrypted partition to /mnt
mount /dev/mapper/ainstnvme0n1p2 /mnt

# Create New Btrfs Volume called @swap
btrfs subvolume create /mnt/@swap
```

List the current btrfs subvolumes (to see subvol id, fyi but we dont need it):

```bash
sudo btrfs subvolume list /
```

Create the `/swap` mount point:

```bash
sudo mkdir -p /swap
```

Edit the fstab to add the following entries:

```bash
sudo mousepad /etc/fstab
```

Add the following (remove all the subvol id's) to mount the new `@swap` partition:

- /swap entry to point to subvol=@swap (add it by copying an existing entry and modifying it)

Check if it correctly mounts or gives errors:

```bash
sudo mount -a
```

Enable the new fstab:

```bash
sudo systemctl daemon-reload
```

Create, a secure 10GB swapfile at /swap:

```bash
sudo btrfs filesystem mkswapfile --size 10G /swap/swapfile
```

Enable the swapfile:

```bash
sudo swapon /swap/swapfile
```

Make it persistent by adding the following line at the end:

```bash
sudo mousepad /etc/fstab
```

```plaintext
/swap/swapfile none    swap    defaults 0 0
```

Check for errors:

```bash
sudo mount -a
```

# Configure the Initramfs for Hibernation

Edit initramfs:

```bash
sudo nano /etc/mkinitcpio.conf
```

Edits:

- Make sure `resume` hook is included and after `udev`, `encrypt`, `lvm2`, etc. hooks:
- E.g. `HOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block filesystems resume fsck)`

Regenerate Initramfs with:

```bash
sudo mkinitcpio -P
```
