#!/bin/bash

# Install Prerequesites
sudo pacman -S --needed deluge

# Goto Download Location
mkdir -p ~/Downloads
cd ~/Downloads

# Fill in the latest links from: https://archlinux.org/download/
TORRENT_MAGNET="magnet:?xt=urn:btih:6f1bde857b97b382f8841cdf3a42c530b3f4e34e&dn=archlinux-2024.09.01-x86_64.iso"
SHA_SIGNATURE="https://archlinux.org/iso/2024.09.01/sha256sums.txt"
PGP_SIGNATURE="https://archlinux.org/iso/2024.09.01/archlinux-2024.09.01-x86_64.iso.sig"

# Start the Deluge service
systemctl --user start deluged.service

# Download the Torrent using Deluge
deluge-console add $TORRENT_MAGNET

# Function to check if torrent is still downloading
check_torrent_status() {
    status=$(deluge-console info | grep "\[D\]" | grep -o "[0-9]*%")
    if [ -n "$status" ]; then
        echo "Torrent is still downloading..."
        sleep 5  # Check every 5 seconds
        check_torrent_status
    else
        echo "Torrent download finished."
    fi
}

# Wait until the torrent finishes downloading
check_torrent_status

# Download SHA256 checksum file
wget $SHA_SIGNATURE
wget $PGP_SIGNATURE

# Only keep the first line in the SHA file
head -n 1 sha256sums.txt > tmpfile && mv tmpfile sha256sums.txt

# Verify the Arch ISO
echo "*****Verification of SHA*****"
sha_file=$(basename "$SHA_SIGNATURE")
sha256sum -c $sha_file
echo "*****Verification of PGP*****"
pgp_file=$(basename "$PGP_SIGNATURE")
sudo pacman-key -v $pgp_file # On Arch Machines Only
# gpg --keyserver-options auto-key-retrieve --verify $pgp_file # Non-arch machines

# Cleanup
rm $sha_file $pgp_file

# Extract username and password from auth file
auth_info=$(cat ~/.config/deluge/auth)
username=$(echo "$auth_info" | cut -d: -f1)
password=$(echo "$auth_info" | cut -d: -f2)
torrent_id=$(deluge-console info | grep -oE '[0-9a-f]{40}')

# Remove the Torrent (not the downloaded file)
deluge-console -U "$username" -P "$password" rm -c $torrent_id
rm -rf $torrent_id

# Stop the Deluge service
systemctl --user stop deluged.service 
