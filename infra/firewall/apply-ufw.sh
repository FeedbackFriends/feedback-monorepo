#!/usr/bin/env bash
set -euo pipefail

# Applies the UFW rules documented in ufw.rules.md.
# Intended for fresh hosts or explicit re-apply.

sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw default deny routed

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8080/tcp

sudo ufw logging low
sudo ufw --force enable
