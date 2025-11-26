#!/bin/bash
set -e

echo "[*] Installing Salt minion (idempotently)"

#######################################
# APT prerequisites
#######################################

sudo apt-get update -y

sudo apt-get install -y wget curl gnupg2 micro bash-completion

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

#######################################
# Install salt-minion (idempotent via APT)
#######################################

sudo apt-get update -y
sudo apt-get install -y salt-minion

#######################################
# Write minion config in a fully idempotent way
#######################################

MINION_CFG_CONTENT=$(cat <<EOF
master: 192.168.12.10
id: $(hostname)
EOF
)

if [[ ! -f /etc/salt/minion ]] || ! echo "$MINION_CFG_CONTENT" | cmp -s /etc/salt/minion; then
  echo "[*] Updating /etc/salt/minion"
  echo "$MINION_CFG_CONTENT" | sudo tee /etc/salt/minion > /dev/null
fi

#######################################
# Write systemd override idempotently
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
# Restart service safely
#######################################

sudo systemctl daemon-reload

sudo systemctl stop salt-minion || true
sudo systemctl reset-failed salt-minion || true
sudo systemctl enable salt-minion
sudo systemctl start salt-minion

echo "[*] Salt minion provisioned idempotently"
