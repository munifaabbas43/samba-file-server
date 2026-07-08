#!/bin/bash
# ============================================================
# Helper script to add a new Samba user
# Author: Munifa Abbas - DACS Batch 56
# Usage: sudo bash add_user.sh <username>
# ============================================================

set -e

if [ -z "$1" ]; then
  echo "Usage: sudo bash add_user.sh <username>"
  exit 1
fi

USERNAME=$1

echo "==> Creating Linux user $USERNAME"
id -u "$USERNAME" &>/dev/null || useradd -m -G sambashare "$USERNAME"

echo "==> Setting Samba password for $USERNAME"
smbpasswd -a "$USERNAME"
smbpasswd -e "$USERNAME"

echo "==> Adding $USERNAME to the sambashare group"
usermod -aG sambashare "$USERNAME"

echo "==> Done. $USERNAME can now access the shared drive."
