#!/bin/bash
set -e

echo "[*] Installing Salt minion"

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 micro bash-completion

sudo mkdir -p /etc/apt/keyrings

wget -O - https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
  | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp > /dev/null

wget -O /etc/apt/sources.list.d/salt.sources \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

sudo apt-get update -y
sudo apt-get install -y salt-minion

# Set master IP
echo "master: 192.168.12.10" | sudo tee /etc/salt/minion

# Use hostname as id
HOSTNAME=$(hostname)
echo "id: $HOSTNAME" | sudo tee -a /etc/salt/minion

# Run systemd-override that cleans leftover PID files before start
sudo mkdir -p /etc/systemd/system/salt-minion.service.d
cat << 'EOF' | sudo tee /etc/systemd/system/salt-minion.service.d/override.conf
[Service]
ExecStartPre=/bin/rm -f /run/salt-minion.pid /run/salt-minion/salt-minion.pid
Restart=on-failure
EOF

sudo systemctl daemon-reload

# Run full restart (including stop and start in case of issues)
sudo systemctl stop salt-minion || true
sudo systemctl reset-failed salt-minion || true
sudo systemctl enable salt-minion
sudo systemctl start salt-minion
