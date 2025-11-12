#!/data/data/com.termux/files/usr/bin/bash
# --- Termux Screenshot System Setup (EOF-free version) ---
echo "📦 Termux ortamı hazırlanıyor..."

# Güncelleme ve temel paketler
pkg update -y && pkg upgrade -y
pkg install python -y
pkg install termux-api -y
termux-setup-storage

# Çalışma dizini oluştur
BASE_DIR="$HOME/discord_snap"
mkdir -p "$BASE_DIR"
cd "$BASE_DIR" || exit

echo "requests==2.31.0" > requirements.txt
pip install --upgrade pip
pip install -r requirements.txt

# Python script oluşturuluyor
cat > discord_screenshot.py <<'PY'
import os
import time
import requests
from datetime import datetime

BASE_DIR = os.path.expanduser("~/storage/pictures/discord_snaps")
WEBHOOK_URL = "YOUR_WEBHOOK_URL_HERE"  # <-- kendi webhook'unu buraya ekle

os.makedirs(BASE_DIR, exist_ok=True)

def create_day_folder():
    today = datetime.now().strftime("%d_%m_%Y")
    path = os.path.join(BASE_DIR, today)
    os.makedirs(path, exist_ok=True)
    return path

def save_screenshot(folder_path):
    filename = f"shot_{datetime.now().strftime('%H_%M_%S')}.png"
    full_path = os.path.join(folder_path, filename)
    os.system(f"termux-screencap '{full_path}'")
    return full_path

def send_to_discord(path):
    timestamp = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    msg = f"📸 Screenshot taken at {timestamp}"
    with open(path, 'rb') as f:
        response = requests.post(WEBHOOK_URL, data={"content": msg}, files={"file": f})
    if response.status_code == 200:
        print(f"[+] Sent to Discord: {path}")
    else:
        print(f"[!] Failed to send: {response.status_code}, {response.text}")

def main():
    while True:
        folder = create_day_folder()
        shot = save_screenshot(folder)
        send_to_discord(shot)
        time.sleep(900)  # 15 dakika

if __name__ == "__main__":
    main()
PY

# .bashrc'ye otomatik başlatma ekle
if ! grep -q "discord_screenshot.py" ~/.bashrc; then
  echo 'pgrep -f discord_screenshot.py > /dev/null || nohup python ~/discord_snap/discord_screenshot.py > /dev/null 2>&1 &' >> ~/.bashrc
  echo "✅ Otomatik başlatma eklendi (~/.bashrc)"
else
  echo "⚙️ Otomatik başlatma zaten mevcut."
fi

echo ""
echo "🚀 Kurulum tamamlandı!"
echo "📂 Script dizini: $BASE_DIR"
echo "💡 Şimdi kendi Discord Webhook URL’ni discord_screenshot.py içine ekle."
echo ""
 
