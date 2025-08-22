#!/bin/bash

# Search for packages
# Official Arch Packages: https://archlinux.org/packages/
# Arch User Repository (AUR): https://aur.archlinux.org/packages
# View update package log to fix broken packages: `cat /var/log/pacman.log`
# To figure out what files an app is changing use: `inotifywait -m ~/`

# Upgrade the system, post-installer and install AUR helper
SCRIPT_PATH="$0"
sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm git base-devel rustup
rustup default stable
git config --global user.name "default" # CHANGE IF NECESSARY
git config --global user.email "default@email.com" # CHANGE IF NECESSARY
OLD_HASH=$(sha256sum "$SCRIPT_PATH" | awk '{print $1}')
git pull # Obtain latest version of post-installer
NEW_HASH=$(sha256sum "$SCRIPT_PATH" | awk '{print $1}')
if [ "$OLD_HASH" != "$NEW_HASH" ]; then
  echo "Script updated! Relaunching..."
  exec "$SCRIPT_PATH" "$@"
  exit 0
fi

# Copy the configs
mkdir -p ~/Templates
cp -rf Templates/* ~/Templates/
cp -rf config/* ~/.config/
cp -rf local/* ~/.local/
sudo cp -rf etc/* /etc/
sudo cp -rf usr/* /usr/
sudo cp -rf boot/* /boot/
sudo cp -rf var/* /var/

# XFCE Settings
xfconf-query -c xfce4-notifyd -p /compat/use-override-redirect-windows -t bool -s true --create
# Default DPI is 96. For 1920x1080 laptop monitor, we need 1.5x scaling, so 96x1.5=144.
# Set DPI: `xfconf-query -c xsettings -p /Xft/DPI -s 144`
# Theme Selection:
read -p "Do you want to go with a light theme? (y/n): " response
if [[ "$response" == "y" || "$response" == "Y" ]]; then
  xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita
  cp -rf light/config/* ~/.config/
  sudo cp -rf light/etc/* /etc/
else
  xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark
  cp -rf dark/config/* ~/.config/
  sudo cp -rf dark/etc/* /etc/
fi

# Install official Arch Linux apps
apps=(
    # Web
    firefox                         # Browser
    chromium                        # Alternate Browser
    deluge-gtk                      # Download Torrents
    thunderbird                     # Email and Calendar
    yt-dlp                          # Download YouTube Videos
    rsync                           # File Synchronization
    rclone                          # Mount Cloud Storage

    # Productivity
    i3-wm                           # Tiling Window Manager
    i3status                        # Display Info in i3bar
    okular                          # PDF Viewer and Annotater
    poppler                         # Extract .jpeg Images From PDFs
    pdfarranger                     # Rearrange and Combine PDFs
    mousepad                        # Text Editor
    obs-studio                      # Record Computer Screen
    kdenlive                        # Video Editor
    handbrake                       # Video Encoding
    kclock                          # Set Alarm, Timer, Stopwatch
    cheese                          # Camera app
    gimp                            # Image Editor
    libheif                         # Support Apple's .HEIF Image Format
    gthumb                          # Image Viewer
    ristretto                       # Apple .HEIF Image viewer
    mpv                             # Video Player
    discord                         # Communication

    # Software Development
    code                            # Code Editor
    kitty                           # Terminal Emulator
    git                             # Repository Management
    docker                          # Container Management
    python                          # Programming Language
    inotify-tools                   # Track changes on filesystem
    plocate                         # Quickly find files
    man-db                          # Provide help info about applications
    wireshark-qt                    # Sniffs Network Packets to Analyze

    # Themes
    lxappearance-gtk3               # GTK Theme Manager
    qt6ct                           # Qt6 Theme Manager
    qt5ct                           # Qt5 Theme Manager
    breeze                          # Theme
    breeze5                         # Theme
    breeze-gtk                      # Theme
    breeze-icons                    # Icon Theme
    
    # System Utilities
    exfat-utils                     # The ExFAT file system
    unrar                           # Extract .rar files
    neofetch                        # Display Info About OS
    desktop-file-utils              # MIME Cache
    shared-mime-info                # MIME Cache
    zip                             # Zip Files
    unzip                           # Unzip Files
    feh                             # Change Wallpaper
    timeshift                       # File System Snapshots
    cronie                          # Schedule Services
    flameshot                       # Screenshot Utility
    volumeicon                      # Volume control applet
    xorg-xev                        # Record Mouse Button Events
    xorg-xwininfo                   # Print Info about X11 Windows
    xorg-xset                       # Adjust X11 Screen blanking
    xorg-xrandr                     # Display Resolution Tool
    xdotool                         # Automatically Type Text
    xautomation                     # Assign Mouse Buttons
    xbindkeys                       # Assign Mouse Buttons
    ifuse                           # Access Camera Photos and other media of Apple devices
    gvfs-afc                        # Access iOS apps data - AFC Thunar backend for Apple devices

    # Hardware
    brightnessctl                   # Control the screen brightness
    bluez                           # Bluetooth support
    bluez-utils                     # Additional Bluetooth tools
    blueman                         # Graphical Interface for Bluetooth
    touchegg                        # Configure Touchpad Gestures
    intel-ucode                     # Intel Microcode
    util-linux                      # SSD TRIM Support
    cups                            # Printer Driver
    piper                           # Gaming Mouse Buttons Customization
    libinput                        # Touchpad Configuration
)

# Install AUR unofficial apps
# View all installed unofficial/AUR packages: `pacman -Qmq`
aur_apps=(
    bauh                                # AUR Helper GUI
    downgrade                           # Downgrade Arch Packages
    cnrdrvcups-lb                       # Printer Driver
    localsend-bin                       # Cross-platform Airdrop
    auto-cpufreq                        # Make CPU more efficient
    onlyoffice-bin                      # Install Office Suite
)

# Install all the apps
apps_string=$(IFS=' '; echo "${apps[*]}")
aur_string=$(IFS=' '; echo "${aur_apps[*]}")
utilities/installpackage.sh yay "https://aur.archlinux.org/yay.git"
yay -S --needed --noconfirm $apps_string
yay -S --needed --noconfirm $aur_string

# Install VSCodium Extension
/bin/code --install-extension yzhang.markdown-all-in-one
/bin/code --install-extension renathossain.markdown-runner

# Register the Services
sudo systemctl daemon-reload
systemctl --user daemon-reload
sudo udevadm control --reload-rules

# Enable Periodic SSD TRIM Support
sudo systemctl enable fstrim.timer

# Enable auto-cpufreq service (to save power)
sudo systemctl enable auto-cpufreq
sudo systemctl start auto-cpufreq

# Enable Bluetooth service
sudo systemctl enable bluetooth.service
sudo systemctl start bluetooth.service

# Touchpad Gestures
sudo systemctl enable touchegg.service
sudo systemctl start touchegg.service

# Enable cronie.service for Timeshift
sudo systemctl start cronie.service
sudo systemctl enable cronie.service

# Periodic Cleanup of Downloaded Packages
sudo systemctl enable paccache.timer
sudo systemctl start paccache.timer

# Enable Printer Service
sudo systemctl start cups
sudo systemctl enable cups

# Auto-update service
sudo systemctl enable auto-update.timer
sudo systemctl start auto-update.timer

# Mount iPhone service
systemctl --user enable iphone-monitor.service
systemctl --user start iphone-monitor.service

# Enable Docker Service
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo systemctl start docker
sudo systemctl enable docker

###### CLEANUP ######

# Clean Unused repositories and AUR Build Cache
yay --noconfirm -Rns $(pacman -Qdtq)
yay -Scc --noconfirm
sudo paccache -r -k 1

# Clean Coredump
sudo rm -rf /var/lib/systemd/coredump/*
