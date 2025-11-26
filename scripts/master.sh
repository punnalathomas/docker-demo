#!/bin/bash
set -e

echo "[*] Installing Salt master"

sudo apt-get update -y
sudo apt-get install -y wget curl gnupg2 micro bash-completion

sudo mkdir -p /etc/apt/keyrings

wget -O - https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public \
  | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp > /dev/null

wget -O /etc/apt/sources.list.d/salt.sources \
  https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources

sudo apt-get update -y
sudo apt-get install -y salt-master

# Auto accepting minion-keys
# Note: Auto accepting should only be done in test/dev environments, not for production!

sudo echo "auto_accept: True" >> /etc/salt/master


sudo systemctl stop salt-master
sudo systemctl start salt-master

sudo systemctl enable --now salt-master
