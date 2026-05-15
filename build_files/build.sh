#!/bin/bash
set -ouex pipefail

# Enable code signing
dnf5 -y install dnf5-plugins
dnf5 -y copr enable ublue-os/packages
dnf5 -y install /tmp/akmods-common/ublue-os/ublue-os-akmods-addons*.rpm
dnf5 -y install ublue-os-signing
cp /usr/etc/containers/policy.json /etc/containers/policy.json
rm -rf /usr/etc

# Install utilities
dnf5 -y install \
  docker-compose \
  firewalld \
  smartmontools \
  libguestfs-tools \
  libvirt-daemon-kvm \
  virt-install

# Install Nvidia
dnf5 -y install /tmp/akmods-nvidia/ublue-os/ublue-os-nvidia*.rpm
dnf5 config-manager setopt fedora-nvidia.enabled=1 nvidia-container-toolkit.enabled=1
dnf5 -y install /tmp/akmods-nvidia/kmods/kmod-nvidia*.rpm
dnf5 -y install nvidia-container-toolkit nvidia-driver-cuda
dnf5 config-manager setopt fedora-nvidia.enabled=0 nvidia-container-toolkit.enabled=0

# Install Tailscale
dnf5 config-manager addrepo --id=tailscale --set=baseurl=https://pkgs.tailscale.com/stable/fedora/tailscale.repo --set=enabled=0
dnf5 -y install --enable-repo=tailscale --nogpgcheck tailscale

# Install ZFS
dnf5 -y install /tmp/akmods-zfs/kmods/zfs/*.rpm
dnf5 -y install /tmp/akmods-zfs/kmods/zfs/other/zfs-dracut-*.rpm
depmod -a "$(rpm -qa kernel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
echo "zfs" > /etc/modules-load.d/zfs.conf

# Setup services
systemctl enable rpm-ostreed-automatic.timer
systemctl disable zincati.service

# Copy system files
cp -af /ctx/system_files/. /

# Clean up
dnf5 clean all
rm -rf /var/lib/dnf
