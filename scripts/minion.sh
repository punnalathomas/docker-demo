#!/bin/bash
set -e

# ----------------------------------------------------------------------
# Script: minion.sh
# Description: Provisions the Salt Minion node.
#   1. Installs Salt Minion using official repos.
#   2. Configures the minion ID and Master IP.
#   3. Adds systemd overrides to prevent PID locking issues on restart.
# ----------------------------------------------------------------------

echo "[*] Installing Salt minion (idempotently)"

#######################################
# APT Prerequisites
#######################################

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 git micro tree bash-completion

sudo mkdir -p /etc/apt/keyrings

#######################################
# Salt Keyring Configuration
# We compare the new key with the existing one to ensure idempotency.
# Only overwrite if the key has changed.
#######################################

TMP_KEY=/tmp/salt-key.pgp
wget -q -O "$TMP_KEY" \
  https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public

if ! cmp -s "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp 2>/dev/null; then
  echo "[*] Updating Salt keyring"
  sudo cp "$TMP_KEY" /etc/apt/keyrings/salt-archive-keyring.pgp
fi

#######################################
# Salt APT Source Configuration
# Only update if changed
#######################################

TMP_SRC=/tmp/salt.sources
wget -q -O "$TMP_SRC" \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

DEST_SRC=/etc/apt/sources.list.d/salt.sources

if ! cmp -s "$TMP_SRC" "$DEST_SRC" 2>/dev/null; then
  echo "[*] Updating Salt sources.list entry"
  sudo cp "$TMP_SRC" "$DEST_SRC"
fi

# Install Minion service
sudo apt-get update -y
sudo apt-get install -y salt-minion

#######################################
# Minion Configuration
# Sets the Master IP and Minion ID (hostname), only if changed.
#######################################

MINION_CFG_CONTENT=$(cat <<EOF
master: 192.168.12.10
id: $(hostname)
EOF
)

if [[ ! -f /etc/salt/minion ]] || ! echo "$MINION_CFG_CONTENT" | cmp -s - /etc/salt/minion; then
  echo "[*] Updating /etc/salt/minion"
  echo "$MINION_CFG_CONTENT" | sudo tee /etc/salt/minion > /dev/null
fi

#######################################
# Systemd Override for Reliability
# Cleans up stale PID files before starting the service.
# This prevents "service failed to start" errors after rough VM restarts.
#######################################

OVERRIDE_PATH=/etc/systemd/system/salt-minion.service.d/override.conf
OVERRIDE_CONTENT=$(cat <<'EOF'
[Service]
ExecStartPre=/bin/rm -f /run/salt-minion.pid /run/salt-minion/salt-minion.pid
Restart=on-failure
EOF
)

sudo mkdir -p /etc/systemd/system/salt-minion.service.d

TMP_OVERRIDE=/tmp/salt-override.conf
echo "$OVERRIDE_CONTENT" > "$TMP_OVERRIDE"

if [[ ! -f "$OVERRIDE_PATH" ]] || ! cmp -s "$TMP_OVERRIDE" "$OVERRIDE_PATH"; then
  echo "[*] Updating systemd override"
  sudo cp "$TMP_OVERRIDE" "$OVERRIDE_PATH"
fi

#######################################
# Restart Service
# Safely reset failed states and ensure the service is running.
#######################################

sudo systemctl daemon-reload
sudo systemctl stop salt-minion || true
sudo systemctl reset-failed salt-minion || true
sudo systemctl enable salt-minion
sudo systemctl start salt-minion

echo "[*] Salt minion provisioned idempotently"
