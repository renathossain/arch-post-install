#!/bin/bash

/usr/bin/sudo /usr/bin/yay -Syu --noconfirm
yay -Scc --noconfirm
yay --noconfirm -Rns $(pacman -Qdtq)
sudo rm -rf /var/lib/systemd/coredump/*