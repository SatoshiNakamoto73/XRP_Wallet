#!/usr/bin/env bash
set -e

echo "Installing xrp dependencies..."
pip3 install xrpl-py rich qrcode cryptography argon2-cffi --break-system-packages -q

echo "Installing xrp to /usr/local/bin..."
sudo cp xrp /usr/local/bin/xrp
sudo chmod +x /usr/local/bin/xrp

echo ""
echo "✓ Done. Run: xrp init"
