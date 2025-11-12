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
        with open(CONFIG_PATH, "w") as f: json.dump(DEFAULT_CONFIG, f, indent=2)
        print("⚠️ config.json oluşturuldu, webhook URL ekle ve tekrar çalıştır.")
        exit()
    with open(CONFIG_PATH) as f: cfg = json.load(f)
    if "YOUR_WEBHOOK_URL_HERE" in cfg["discord_webhook_url"]:
        print("⚠️ Lütfen webhook URL'ini config.json'a yaz.")
        exit()
    return cfg

def get_device_info():
    try:
        out = subprocess.check_output(["getprop","ro.product.model"]).decode().strip()
        return out or "UnknownDevice"
    except: return "UnknownDevice"

def send_file_to_discord(webhook, path, msg):
    for i in range(3):
        try:
            with open(path,"rb") as f:
                r=requests.post(webhook,data={"content":msg},files={"file":f})
            if r.ok: return True
        except Exception as e: print("Gönderim hatası:",e)
        time.sleep(2)
    return False

def send_text(webhook,msg):
    try:
        r=requests.post(webhook,json={"content":msg});return r.ok
    except: return False

def take_screenshot(path):
    try:
        subprocess.run(["screencap","-p",path],check=True)
        return True
    except Exception as e:
        print("⚠️ Screencap hatası:",e)
        return False

def main():
    cfg=load_config()
    base=cfg["base_dir"];interval=cfg["interval_seconds"];webhook=cfg["discord_webhook_url"]
    os.makedirs(base,exist_ok=True)
    device=get_device_info()
    if cfg.get("send_startup_notification"):
        msg=f"📢 Bot started on {device} at {datetime.now().strftime('%H:%M:%S')}"
        send_text(webhook,msg)
    while True:
        folder=os.path.join(base,datetime.now().strftime("%d_%m_%Y"))
        os.makedirs(folder,exist_ok=True)
        path=os.path.join(folder,datetime.now().strftime("shot_%H_%M_%S.png"))
        if take_screenshot(path):
            msg=f"📸 {datetime.now().strftime('%d-%m-%Y %H:%M:%S')} — {device}"
            ok=send_file_to_discord(webhook,path,msg)
            print("✅ Gönderildi" if ok else "⚠️ Gönderilemedi")
        time.sleep(interval)

if __name__=="__main__": main()
EOF

# --- config.json ---
cat > config.json <<'CFG'
{
  "discord_webhook_url": "YOUR_WEBHOOK_URL_HERE",
  "base_dir": "/sdcard/snapshots",
  "interval_seconds": 900,
  "send_startup_notification": true
}
CFG

# --- Python kurulum ---
pip install --upgrade pip
pip install -r requirements.txt

chmod +x discord_screenshot.py

# --- Otomatik başlatma ---
AUTOCMD="pgrep -f discord_screenshot.py > /dev/null || nohup python $WORKDIR/discord_screenshot.py > /dev/null 2>&1 &"
if ! grep -Fq "$AUTOCMD" "$BASHRC"; then
  echo "" >> "$BASHRC"
  echo "# Auto-start Discord Screenshot bot" >> "$BASHRC"
  echo "$AUTOCMD" >> "$BASHRC"
fi

mkdir -p "$HOME/.termux/boot"
cat > "$HOME/.termux/boot/autostart.sh" <<'EOF2'
#!/data/data/com.termux/files/usr/bin/bash
pgrep -f discord_screenshot.py > /dev/null || nohup python $HOME/discord_snap/discord_screenshot.py > /dev/null 2>&1 &
EOF2
chmod +x "$HOME/.termux/boot/autostart.sh"

echo ""
echo "✅ Kurulum tamamlandı!"
echo "Webhook URL'ini config.json içine yaz: nano $WORKDIR/config.json"
echo "Manuel başlatmak için: python $WORKDIR/discord_screenshot.py"
echo "⏱ Varsayılan süre: 15 dakika (900 saniye)"
