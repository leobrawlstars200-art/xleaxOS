#!/usr/bin/env bash
set -euo pipefail

iso_name="xleaxOS"
iso_label="XLEAX_$(date +%Y%m)"
iso_publisher="xleaxOS Project <https://github.com/>"
iso_application="xleaxOS Live ISO"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux.mbr' 'bios.syslinux.eltorito' 'uefi-x64.systemd-boot.esp' 'uefi-x64.systemd-boot.eltorito')
arch="x86_64"
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
file_permissions=(
  ["/etc/shadow"]="0:0:400"
)