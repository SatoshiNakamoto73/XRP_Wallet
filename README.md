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
xrp init                                  # Generate new wallet (shown once: seed phrase)
xrp balance                               # Show balance
xrp address                               # Print your address
xrp receive                               # Show receive QR
xrp receive --amount 5.0 --label "1hr"   # Request specific amount
xrp send rXXX...XXX 1.5                  # Send 1.5 XRP
xrp send rXXX...XXX 1.5 --tag 4821       # Send with destination tag
xrp history                               # Recent transactions
xrp watch                                 # Watch for incoming payments
xrp watch --amount 1.5 --on-payment "./unlock.sh"   # Trigger script on payment
xrp pos                                   # Launch browser-based point of sale
xrp export                                # Show seed phrase (careful)
xrp node https://xrplcluster.com          # Set custom XRPL node
```

---

## Point of Sale

`xrp pos` launches a browser-based POS terminal on your local machine. Open it on any screen — tablet on the counter, laptop, or any device on your local network.

```bash
xrp pos              # http://localhost:7743
xrp pos --port 8080  # custom port
```

**Cashier flow:**
1. Enter the amount using the on-screen keypad
2. Hit **Charge** — generates a unique order QR code
3. Customer scans with any XRP wallet
4. Screen flips to ✓ **PAID** automatically in ~3 seconds
5. Hit **New Sale** for the next customer

Each sale gets a unique destination tag as an order ID. All confirmed payments are logged locally. No card reader, no Stripe, no chargebacks.

**Why this matters:**
- Card processing costs ~2.9% + $0.30 per transaction
- XRP settles in 3–5 seconds at $0.0002 flat
- A business doing $10K/month saves ~$300/month in fees

---

## Watch Mode — IoT / Access Control

`xrp watch` subscribes to your address on the XRP Ledger in real time. When a qualifying payment arrives, it fires a shell command with full payment context in environment variables:

```bash
xrp watch \
  --amount 1.5 \
  --tag 4821 \
  --on-payment "gpio_set.sh 17 1"
```

**Environment variables passed to your command:**

| Variable | Value |
|---|---|
| `XRP_AMOUNT` | Amount received in XRP |
| `XRP_SENDER` | Sender's XRP address |
| `XRP_TAG` | Destination tag |
| `XRP_HASH` | Transaction hash |
| `XRP_DESTINATION` | Your address |

**Examples:**

```bash
# Unlock a GPIO relay (Raspberry Pi / any SBC)
xrp watch --amount 1.0 --on-payment "python3 relay.py on 30"

# Start a service
xrp watch --on-payment "systemctl start my-service"

# Log to file
xrp watch --on-payment 'echo "$XRP_AMOUNT XRP from $XRP_SENDER" >> payments.log'

# Run once and exit (vending / single-use)
xrp watch --amount 2.0 --on-payment "./dispense.sh" --once
```

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

- Private key encrypted with AES-256-GCM + PBKDF2 (600k iterations)
- Key derived from your password — never stored in plaintext
- `xrp receive`, `xrp watch`, `xrp balance`, `xrp history`, `xrp pos` never ask for your password — read-only, public address only
- Only `xrp send` and `xrp export` decrypt the key

---

## Key Storage

```
~/.config/xrp/
├── wallet.enc        # AES-256-GCM encrypted seed
├── config.json       # node URL, public address
├── pos_orders.json   # POS order state (survives restarts)
└── history.db        # SQLite local transaction log
```

---

## XRPL Node

Defaults to `https://xrplcluster.com` (community-run, reliable). Point it at any public or self-hosted `rippled` node:

```bash
xrp node https://s1.ripple.com
```

---

## License

MIT
