#!/usr/bin/env bash
set -euo pipefail

if ! id -u arch >/dev/null 2>&1; then
  useradd -m -s /bin/bash -G wheel,audio,video,input,storage,optical arch
fi

echo "arch:arch" | chpasswd

systemctl set-default graphical.target
systemctl enable gdm.service

if command -v dconf >/dev/null 2>&1; then
  dconf update
fi
