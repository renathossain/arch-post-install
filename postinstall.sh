#!/bin/bash

# Search for packages
# Official Arch Packages: https://archlinux.org/packages/
# Arch User Repository (AUR): https://aur.archlinux.org/packages
# View update package log to fix broken packages: `cat /var/log/pacman.log`
# To figure out what files an app is changing use: `inotifywait -m ~/`

# Copy the configs
cp -rf config/* ~/.config/
cp -rf local/* ~/.local/
sudo cp -rf etc/* /etc/
sudo cp -rf usr/* /usr/
sudo cp -rf boot/* /boot/
sudo cp -rf Templates/* ~/Templates/

# Upgrade the system
sudo pacman -Syu --noconfirm

# Install AUR Helper
sudo pacman -S --needed --noconfirm git base-devel rustup
rustup default stable
git config --global user.name "default" # CHANGE IF NECESSARY
git config --global user.email "default@email.com" # CHANGE IF NECESSARY
utilities/installpackage.sh yay "https://aur.archlinux.org/yay.git"

# Install official Arch Linux apps
apps=(
    # Web
    firefox                         # Browser
    chromium                        # Alternate Browser
    deluge-gtk                      # Download Torrents
    thunderbird                     # Email and Calendar
    yt-dlp                          # Download YouTube Videos

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
    pinta                           # Drawing App
    gimp                            # Image Editor
    libheif                         # Support Apple's .HEIF Image Format
    mpv                             # Video Player

    # Software Development
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
    xdotool                         # Automatically Type Text
    xautomation                     # Assign Mouse Buttons
    xbindkeys                       # Assign Mouse Buttons

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
    cndrvcups-lb-bin                    # Printer Driver
    localsend-bin                       # Cross-platform Airdrop
    auto-cpufreq                        # Make CPU more efficient
    onlyoffice-bin                      # Install Office Suite
)

# Install all the apps
apps_string=$(IFS=' '; echo "${apps[*]}")
aur_string=$(IFS=' '; echo "${aur_apps[*]}")
yay -S --needed --noconfirm $apps_string
yay -S --needed --noconfirm $aur_string

# Register the Services
sudo systemctl daemon-reload
systemctl --user daemon-reload

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

# Enable Docker Service
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo systemctl start docker
sudo systemctl enable docker

# XFCE Settings
xfconf-query -c xsettings -p /Net/ThemeName -s Adwaita-dark
xfconf-query -c xfce4-notifyd -p /compat/use-override-redirect-windows -t bool -s true --create

###### CLEANUP ######

# Clean Unused repositories and AUR Build Cache
yay -Scc --noconfirm
yay --noconfirm -Rns $(pacman -Qdtq)

# Clean Coredump
sudo rm -rf /var/lib/systemd/coredump/*
