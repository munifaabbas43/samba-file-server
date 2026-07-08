#!/bin/bash
# ============================================================
# Samba File Server setup script
# Author: Munifa Abbas - DACS Batch 56
# Run this on a fresh Ubuntu Server 22.04 VM (VirtualBox)
# Run with sudo: sudo bash install_samba.sh
# ============================================================

set -e

echo "==> Updating package list"
apt update

echo "==> Installing Samba"
apt install -y samba samba-common-bin

echo "==> Creating the sambashare group"
groupadd sambashare 2>/dev/null || echo "Group sambashare already exists, skipping"

echo "==> Creating share directories"
mkdir -p /srv/samba/shared
mkdir -p /srv/samba/public
mkdir -p /srv/samba/users/munifa

echo "==> Setting folder permissions"
chgrp -R sambashare /srv/samba/shared
chmod -R 2775 /srv/samba/shared
chmod -R 0755 /srv/samba/public

echo "==> Backing up the default smb.conf"
cp /etc/samba/smb.conf /etc/samba/smb.conf.bak

echo "==> Copying lab smb.conf into place"
cp ../config/smb.conf /etc/samba/smb.conf

echo "==> Creating Linux user for munifa (skip if already exists)"
id -u munifa &>/dev/null || useradd -m -G sambashare munifa

echo "==> Setting Samba password for munifa"
echo "Set the Samba password for user munifa now:"
smbpasswd -a munifa

echo "==> Enabling the sambashare group membership for munifa"
usermod -aG sambashare munifa

echo "==> Testing the config file"
testparm -s

echo "==> Restarting Samba services"
systemctl restart smbd nmbd
systemctl enable smbd nmbd

echo "==> Opening firewall ports for Samba (if ufw is active)"
ufw allow samba || true

echo "==> Done. Samba shares are ready."
echo "    \\\\<server-ip>\\shared"
echo "    \\\\<server-ip>\\public"
echo "    \\\\<server-ip>\\munifa"
