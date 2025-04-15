# arch-post-install

An Arch Linux post-installation script and dotfiles to automate the setup process for the XFCE desktop environment.

# 1. Download Arch Installation ISO and verify its integrity (on Arch Linux)

- Open `utilities/downloadArch.sh` and goto https://archlinux.org/download/.
- Copy and paste the latest links from the website into `TORRENT_MAGNET`, `SHA_SIGNATURE` and `PGP_SIGNATURE` variables in the `utilities/downloadArch.sh` script.
- Run `utilities/downloadArch.sh` to download and verify the latest Arch Linux ISO (this script is designed to work on Arch Linux).
- For other operating systems, torrent the Arch ISO and verify its integrity manually.

# 2. Flash USB Drive with Arch Linux ISO (on Arch Linux)

Format and flash the USB drive with this utility:

```bash
# READ the following and run with caution
lsblk # Determine the USB drive (of=/dev/sda for example)
cd ~/Downloads/
sudo dd status=progress if=archlinux-2024.04.01-x86_64.iso of=/dev/sda bs=4M
sync
```

# 3. Install Arch

"Keep as much of the defaults as possible, unless you have a good reason"

- Arch Wiki: https://wiki.archlinux.org/title/Installation_guide
- Boot from the USB
- Connect to the internet (WIFI)

```bash
iwctl
[iwd]# device list
[iwd]# station wlan0 scan
[iwd]# station wlan0 get-networks
[iwd]# station wlan0 connect [SSID name]
exit
```

- Start the installer for Arch Linux

```bash
archinstall
```

- Load installer with predefined config (users and passwords are not saved):

```bash
archinstall --config user_configuration.json
```

- Sample settings:

```plaintext
Achinstall language:         English
Mirrors:                     Canada, United States, Worldwide
Locales:                     us, en_US, UTF-8
Disk:                        Use a best-effort default partition layout
                             btrfs, subvolumes (yes), compression (yes)
Disk encryption:             Yes, type in a password
Bootloader:                  Systemd-boot
Unified kernel images:       False
Swap:                        False (we will create later)
Hostname:                    Enter machine name
Rooot password:              Enter password
User account:                Add a user, enter username,
                             enter password, make it superuser
Profile:                     Type: Desktop, Xfce4
                             Graphics driver: Nvidia (open kernel module)
                             Greeter: SDDM has more theme selection
							 https://www.youtube.com/watch?v=2p7FINJSlAk
Audio:                       Pipewire
Kernels:                     linux
Additional packages:         firefox
Network Configuration:       Use NetworkManager
Timezone:                    America/Toronto
Automatic time sync (NTP):   True
Optional repositories:       multilib
```

# 4. Perform Swapfile Setup for Hibernation

Do [Swapfile Setup](https://github.com/renathossain/arch-post-install/blob/main/README/%20Swapfile%20Setup.md) to enable hibernation.

# 5. Run Post Installer

```bash
./postinstall.sh
```

# SDDM Login Manager Modes - How to go into the newly installed system to fix issues:

- SDDM Login Manager
- `Ctrl + Alt + F6` - Terminal Mode
- `Ctrl + Alt + F2` - GUI Mode

# Chroot into partition to edit files and fix the computer

```bash
# https://www.youtube.com/watch?v=bHGNkp7mYMc
lsblk # To see what disk to unencrypt
cryptsetup open /dev/vda2 cryptroot
mount /dev/mapper/cryptroot /mnt
nano /mnt/@/etc/fstab # To see the the mount points, which the following commands are created from:
mount -o subvol=@ /dev/mapper/cryptroot /mnt
mount -o subvol=@home /dev/mapper/cryptroot /mnt/home
mount -o subvol=@pkg /dev/mapper/cryptroot /mnt/var/cache/pacman/pkg
mount -o subvol=@log /dev/mapper/cryptroot /mnt/var/log
mount /dev/vda1 /mnt/boot
arch-chroot /mnt
```

# Connect to the Internet After Install (if Network Manager is not present)

- Guide: https://www.youtube.com/watch?v=loJKf1zr1bU

```bash
nmcli r wifi on
nmcli d wifi list
nmcli connections show
nmcli d wifi connect '[SSID name]' password '[WIFI password]'
```
