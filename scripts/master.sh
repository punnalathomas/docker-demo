#!/bin/bash
set -e

echo "[*] Installing Salt master"

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 git micro bash-completion

sudo mkdir -p /etc/apt/keyrings

#######################################
# Salt keyring — only update if changed
#######################################

TMP_KEY=/tmp/salt-key.pgp
wget -q -O "$TMP_KEY" \
  https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public

if ! cmp -s "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp 2>/dev/null; then
  echo "[*] Updating Salt keyring"
  sudo cp "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp
fi

#######################################
# Salt apt source — write only if changed
#######################################

TMP_SRC=/tmp/salt.sources
wget -q -O "$TMP_SRC" \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

DEST_SRC=/etc/apt/sources.list.d/salt.sources

if ! cmp -s "$TMP_SRC" "$DEST_SRC" 2>/dev/null; then
  echo "[*] Updating Salt sources.list entry"
  sudo cp "$TMP_SRC" "$DEST_SRC"
fi

sudo apt-get update -y
sudo apt-get install -y salt-master

#######################################
# Auto accept minion-keys
# Note: Auto accepting should only be done in test/dev environments, not in production!
#######################################

grep -qxF "auto_accept: True" /etc/salt/master || echo "auto_accept: True" | sudo tee -a /etc/salt/master

sudo systemctl stop salt-master
sudo systemctl start salt-master

sudo systemctl enable --now salt-master

echo "[*] Salt master provisioned successfully"
