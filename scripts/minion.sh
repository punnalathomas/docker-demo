#!/bin/bash
set -e

echo "[*] Installing Salt minion"

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 micro

sudo mkdir -p /etc/apt/keyrings

wget -O - https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
  | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp > /dev/null

wget -O /etc/apt/sources.list.d/salt.sources \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

sudo apt-get update -y
sudo apt-get install -y salt-minion

# Set master IP
echo "master: 192.168.12.3" | sudo tee /etc/salt/minion

# Use hostname as id
HOSTNAME=$(hostname)
echo "id: $HOSTNAME" | sudo tee -a /etc/salt/minion

sudo systemctl restart salt-minion
# stop and start again due to issues
sudo systemctl stop salt-minion
sudo systemctl start salt-minion
