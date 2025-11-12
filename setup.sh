#!/data/data/com.termux/files/usr/bin/bash
set -e

WORKDIR="$HOME/discord_snap"
PY_BIN="/data/data/com.termux/files/usr/bin/python"
BASHRC="$HOME/.bashrc"

echo "🔧 Termux Screenshot Bot kurulumu başlıyor..."

pkg update -y && pkg upgrade -y
pkg install -y python git

echo "📁 Depolama erişimi izni gerekiyor. Lütfen izin ver."
termux-setup-storage || true
sleep 1

mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "📦 requirements.txt oluşturuluyor..."
cat > requirements.txt <<'REQ'
requests==2.31.0
REQ

echo "🧠 discord_screenshot.py oluşturuluyor..."
cat > discord_screenshot.py <<'EOF'
#!/usr/bin/env python3
import os, time, json, requests, subprocess
from datetime import datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
CONFIG_PATH = os.path.join(SCRIPT_DIR, "config.json")

DEFAULT_CONFIG = {
    "discord_webhook_url": "YOUR_WEBHOOK_URL_HERE",
        "interval_seconds": 900,
            "base_dir": "/sdcard/snapshots",
                "send_startup_notification": True
                }

                def load_config():
                    if not os.path.exists(CONFIG_PATH):
                            with open(CONFIG_PATH, "w") as f: json.dump(DEFAULT_CONFIG, f, indent=2)
                                    print("⚠️ config.json oluşturuldu, webhook URL girip tekrar başlat.")
                                            exit()
                                                with open(CONFIG_PATH) as f: cfg = json.load(f)
                                                    if "YOUR_WEBHOOK_URL_HERE" in cfg["discord_webhook_url"]:
                                                            print("⚠️ Lütfen webhook URL'ini config.json'a ekle.")
                                                                    exit()
                                                                        return cfg

                                                                        def get_device_info():
                                                                            try:
                                                                                    out = subprocess.check_output(["getprop","ro.product.model"]).de_
                                                                                    