#!/usr/bin/env bash
set -euo pipefail

if ! id -u arch >/dev/null 2>&1; then
  useradd -m -s /bin/bash -G wheel,audio,video,input,storage,optical arch
fi

echo "arch:arch" | chpasswd

enable_if_present() {
  local unit="$1"
  if systemctl list-unit-files "$unit" --no-legend >/dev/null 2>&1; then
    systemctl enable "$unit"
  fi
}

systemctl set-default graphical.target
enable_if_present gdm.service
enable_if_present xleax-gpu-boost.service
enable_if_present ananicy-cpp.service
enable_if_present scx_loader.service

if command -v dconf >/dev/null 2>&1; then
  dconf update
fi
