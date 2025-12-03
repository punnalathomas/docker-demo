#!/bin/bash
set -e

# ----------------------------------------------------------------------
# Project: Docker & SaltStack Load Balancing Demo
# Script: master.sh
# Description: Provisions the Salt Master node.
#   1. Installs Salt Master using official Broadcom repositories.
#   2. Configures 'auto_accept' for seamless demo onboarding.
#   3. Links /vagrant/salt to /srv/salt for host-based editing.
# ----------------------------------------------------------------------

echo "[*] Installing Salt master"


#######################################
# APT Prerequisites and Basic Utilities
#######################################

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 git micro tree bash-completion


#######################################
# Salt Keyring Configuration
# Compares the new key with the existing one to ensure idempotency.
# Updates the key only if it has changed.
#######################################

sudo mkdir -p /etc/apt/keyrings

TMP_KEY=/tmp/salt-key.pgp
wget -q -O "$TMP_KEY" \
  https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public

if ! cmp -s "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp 2>/dev/null; then
  echo "[*] Updating Salt keyring"
  sudo cp "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp
fi


#######################################
# Salt APT Source Configuration
# Updates the sources.list entry only if the upstream source file changes.
#######################################

TMP_SRC=/tmp/salt.sources
wget -q -O "$TMP_SRC" \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

DEST_SRC=/etc/apt/sources.list.d/salt.sources

if ! cmp -s "$TMP_SRC" "$DEST_SRC" 2>/dev/null; then
  echo "[*] Updating Salt sources.list entry"
  sudo cp "$TMP_SRC" "$DEST_SRC"
fi


#######################################
# Install Master Service
#######################################

# Update is required to pick up the new Salt repository
sudo apt-get update -y
sudo apt-get install -y salt-master


#######################################
# Master Configuration: Auto Accept
# Automatically accepts keys from new minions.
# CRITICAL: This is for DEMO environments only. Do not use in production.
#######################################

if grep -qxF "auto_accept: True" /etc/salt/master; then
  : # Config already exists, do nothing
else
  echo "[*] Enabling auto_accept"
  echo "auto_accept: True" | sudo tee -a /etc/salt/master > /dev/null
fi


#######################################
# Developer Experience: Synced Folders
# Links /vagrant/salt (synced from Host) to /srv/salt (Salt's default).
# Allows editing .sls files in VS Code on the host machine.
#######################################

# Remove default empty directory if it exists and is not a symlink
if [ -d /srv/salt ] && [ ! -L /srv/salt ]; then
  sudo rm -rf /srv/salt
fi

# Create the symlink if it doesn't exist
if [ ! -L /srv/salt ]; then
  echo "[*] Linking /vagrant/salt to /srv/salt"
  sudo ln -s /vagrant/salt /srv/salt
fi


#######################################
# Restart Service
# Safely resets failed states and ensures the service is running.
# Sequence: Stop -> Reset Failed -> Enable -> Start.
#######################################

sudo systemctl daemon-reload
sudo systemctl stop salt-master || true
sudo systemctl reset-failed salt-master || true
sudo systemctl enable --now salt-master

echo "[*] Salt master provisioned idempotently"
