#!/usr/bin/env bash
set -euo pipefail

LIVE_USER="epstein"
LIVE_PASSWORD="epstein"

if ! id -u "$LIVE_USER" >/dev/null 2>&1; then
  if id -u arch >/dev/null 2>&1; then
    usermod -l "$LIVE_USER" -d "/home/${LIVE_USER}" -m arch || true
    if getent group arch >/dev/null 2>&1 && ! getent group "$LIVE_USER" >/dev/null 2>&1; then
      groupmod -n "$LIVE_USER" arch || true
    fi
  else
    useradd -m -s /bin/bash -G wheel,audio,video,input,storage,optical -c "Epstein" "$LIVE_USER"
  fi
fi

echo "${LIVE_USER}:${LIVE_PASSWORD}" | chpasswd
usermod -c "Epstein" "$LIVE_USER" || true

for grp in wheel audio video input storage optical libvirt kvm; do
  if getent group "$grp" >/dev/null 2>&1; then
    usermod -aG "$grp" "$LIVE_USER" || true
  fi
done

enable_if_present() {
  local unit="$1"
  if systemctl cat "$unit" >/dev/null 2>&1; then
    systemctl enable "$unit" || true
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
enable_if_present libvirtd.service
enable_if_present virtqemud.service
enable_if_present virtnetworkd.service
enable_if_present virtlogd.socket
enable_if_present virtlockd.socket
enable_if_present snapper-cleanup.timer
enable_if_present snapper-timeline.timer
enable_if_present grub-btrfs.path
enable_if_present btrfs-scrub@-.timer
enable_user_if_present xleax-ghost.service

for pkg in gnome-software epiphany yelp; do
  if pacman -Q "$pkg" >/dev/null 2>&1; then
    pacman -Rns --noconfirm "$pkg" || true
  fi
done

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

if command -v systemctl >/dev/null 2>&1; then
  systemctl daemon-reload || true
fi
