#!/bin/bash
set -ouex pipefail

# Install dependencies
dnf5 -y install dnf5-plugins
dnf5 -y install /tmp/akmods-common/ublue-os/ublue-os-akmods-addons*.rpm

# Install Tailscale
dnf5 config-manager addrepo --id=tailscale --set=baseurl=https://pkgs.tailscale.com/stable/fedora/tailscale.repo --set=enabled=0
dnf5 -y install --enable-repo=tailscale --nogpgcheck tailscale

# Install ZFS
dnf5 -y install /tmp/akmods-zfs/kmods/zfs/*.rpm
dnf5 -y install /tmp/akmods-zfs/kmods/zfs/other/zfs-dracut-*.rpm
depmod -a "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
echo "zfs" > /etc/modules-load.d/zfs.conf

# Copy system files
cp -af /ctx/system_files/. /

# Clean up
dnf5 clean all
rm -rf /var/lib/dnf
