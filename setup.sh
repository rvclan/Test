#!/data/data/com.termux/files/usr/bin/bash
set -e

WORKDIR="$HOME/discord_snap"
BASHRC="$HOME/.bashrc"

echo "🔧 Termux Screenshot Bot kurulumu başlıyor..."

pkg update -y && pkg upgrade -y
pkg install -y python git -y

echo "📁 Depolama erişimi izni gerekiyor..."
termux-setup-storage || true
sleep 1

mkdir -p "$WORKDIR"
cd "$WORKDIR"

# --- requirements.txt ---
cat > requirements.txt <<'REQ'
requests==2.31.0
REQ

# --- discord_screenshot.py ---
cat > discord_screenshot.py <<'EOF'
#!/usr/bin/env python3
import os, time, json, requests, subprocess
from datetime import datetime

CONFIG_PATH = os.path.join(os.path.dirname(__file__), "config.json")
DEFAULT_CONFIG = {
    "discord_webhook_url": "YOUR_WEBHOOK_URL_HERE",
    "interval_seconds": 900,
    "base_dir": "/sdcard/snapshots",
    "send_startup_notification": True
}

def load_config():
    if not os.path.exists(CONFIG_PATH):
        with open(CONFIG_PATH, "w") as f: jso_
