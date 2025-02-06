#!/bin/bash

/usr/bin/yay -Syu --noconfirm
/usr/bin/yay -Scc --noconfirm
/usr/bin/yay --noconfirm -Rns $(/usr/bin/yay -Qdtq)
/usr/bin/rm -rf /var/lib/systemd/coredump/*
