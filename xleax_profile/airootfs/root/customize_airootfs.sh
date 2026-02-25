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

enable_user_if_present() {
  local unit="$1"
  if [ -f "/etc/systemd/user/$unit" ] || [ -f "/usr/lib/systemd/user/$unit" ]; then
    systemctl --global enable "$unit" || true
  fi
}

systemctl set-default graphical.target
enable_if_present gdm.service
enable_if_present xleax-gpu-boost.service
enable_if_present ananicy-cpp.service
enable_if_present scx_loader.service
enable_if_present snapper-cleanup.timer
enable_if_present grub-btrfs.path
enable_if_present btrfs-scrub@-.timer
enable_user_if_present xleax-ghost.service

cat > /etc/locale.gen <<'EOF'
en_US.UTF-8 UTF-8
EOF
locale-gen || true
echo "LANG=en_US.UTF-8" > /etc/locale.conf

find /usr/share/locale -mindepth 1 -maxdepth 1 \
  ! -name 'en*' \
  ! -name 'locale.alias' \
  ! -name 'C' \
  -exec rm -rf {} + 2>/dev/null || true
rm -rf /usr/share/man/* /usr/share/doc/* /usr/share/info/* /usr/share/help/* /usr/share/gtk-doc/* 2>/dev/null || true
rm -rf /usr/include/* /usr/lib/pkgconfig/* 2>/dev/null || true
find /usr/lib -type d \( -name test -o -name tests \) -prune -exec rm -rf {} + 2>/dev/null || true

if command -v dconf >/dev/null 2>&1; then
  dconf update
fi
