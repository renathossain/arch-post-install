#!/bin/bash

/usr/bin/yay -Syu --noconfirm
/usr/bin/yay --noconfirm -Rns $(/usr/bin/pacman -Qdtq)
/usr/bin/rm -rf /var/lib/systemd/coredump/*
/usr/bin/yay -Scc --noconfirm
/usr/bin/paccache -r -k 1
