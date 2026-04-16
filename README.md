# xrp — Sovereign XRP Terminal Wallet + Point of Sale

No phone app. No exchange account. No cloud. Your keys live encrypted on your machine. The tool talks directly to the XRP Ledger over WebSocket — sub-second payment confirmation, $0.0002 per transaction.

---

## Install

```bash
git clone https://github.com/yourusername/xrp
cd xrp
bash install.sh
```

**Dependencies:** Python 3.10+, pip

---

## Usage

```bash
xrp init                                  # Generate new wallet (seed phrase shown once)
xrp balance                               # Show balance + USD equivalent
xrp address                               # Print your address
xrp receive                               # Show receive QR
xrp receive --amount 5.0 --label "1hr"   # Request specific amount
xrp send rXXX...XXX 1.5                  # Send 1.5 XRP
xrp send rXXX...XXX 1.5 --tag 4821       # Send with destination tag
xrp history                               # Recent transactions with USD values
xrp history --limit 50                    # More transactions
xrp export-csv                            # Export history to CSV
xrp export-csv --out sales_april.csv      # Custom filename
xrp watch                                 # Watch for incoming payments
xrp watch --amount 1.5 --on-payment "./unlock.sh"   # Trigger script on payment
xrp pos                                   # Launch point of sale
xrp pos --name "Satoshi's Coffee"         # With merchant name
xrp pos --name "My Shop" --lan            # Show LAN IP for tablet access
xrp export                                # Show seed phrase (careful)
xrp node https://xrplcluster.com          # Set custom XRPL node
```

---

## Point of Sale

`xrp pos` launches a browser-based POS terminal. Open on any screen — tablet on the counter, laptop, or any device on your network.

```bash
xrp pos --name "My Shop" --port 7743 --lan
```

**Features:**
- Live XRP/USD price display in header
- Item/label field for each sale
- USD equivalent shown at every step — amount entry, QR screen, paid confirmation
- Daily sales total (XRP + USD) in transaction history
- Unique destination tag per order — no missed or mismatched payments
- Orders persist across server restarts

**Cashier flow:**
1. Type item name (optional) and enter amount
2. Hit **Charge** — QR code appears instantly
3. Customer scans with any XRP wallet
4. Screen flips to ✓ **PAID** in ~1 second
5. Hit **New Sale**

**Why this beats card processing:**
- Card fees: ~2.9% + $0.30 per transaction
- XRP: $0.0002 flat, 3-second settlement, no chargebacks
- A business doing $10K/month saves ~$300/month

---

## Watch Mode — IoT / Access Control

`xrp watch` subscribes to your address in real time. When payment arrives it fires any shell command with full context in environment variables.

```bash
xrp watch --amount 1.5 --tag 42 --on-payment "python3 relay.py on 30"
```

| Variable | Value |
|---|---|
| `XRP_AMOUNT` | Amount received in XRP |
| `XRP_SENDER` | Sender's XRP address |
| `XRP_TAG` | Destination tag |
| `XRP_HASH` | Transaction hash |
| `XRP_DESTINATION` | Your address |

**Run as a systemd service:**

```ini
[Unit]
Description=XRP Payment Watcher
After=network.target

[Service]
ExecStart=/usr/local/bin/xrp watch --amount 1.5 --on-payment "/home/pi/unlock.sh"
Restart=always
User=pi

[Install]
WantedBy=multi-user.target
```

---

## Security

- Private key encrypted with **AES-256-GCM + Argon2id** (64MB memory, GPU-resistant)
- Automatic migration: existing PBKDF2 wallets decrypt transparently on next use
- Key derived from your password — never stored in plaintext
- `receive`, `watch`, `balance`, `history`, `pos` never ask for your password — public address only
- Only `send` and `export` decrypt the key

---

## Key Storage

```
~/.config/xrp/
├── wallet.enc        # AES-256-GCM encrypted seed (Argon2id)
├── config.json       # node URL, public address
├── pos_orders.json   # POS order state (survives restarts)
└── history.db        # SQLite local transaction log
```

---

## XRPL Node

Defaults to `https://xrplcluster.com` (community-run, reliable).

```bash
xrp node https://s1.ripple.com
```

---

## License

MIT
