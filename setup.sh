#!/data/data/com.termux/files/usr/bin/bash
clear
echo "📦 Watcher kurulum başlatılıyor..."
sleep 1

# 1️⃣ Paketleri yükle
echo "🔧 Gerekli paketler yükleniyor..."
pkg update -y && pkg upgrade -y
pkg install -y python wget git
pip install requests

# 2️⃣ Ana dizinleri oluştur
echo "📁 Dizinler hazırlanıyor..."
mkdir -p ~/discord_snap
cd ~/discord_snap

# 3️⃣ Python kodunu oluştur
echo "🧠 Python dosyası oluşturuluyor..."
cat > discord_screenshot.py <<'PY'
import os
import time
import requests
from datetime import datetime

BASE_DIR = os.path.expanduser("~/storage/pictures/discord_snaps")
WEBHOOK_URL = "YOUR_WEBHOOK_URL_HERE"  # 👈 Discord webhook'unu buraya gir

os.makedirs(BASE_DIR, exist_ok=True)

def send_to_discord_message(msg):
    """Discord’a düz metin mesajı gönderir."""
    try:
        response = requests.post(WEBHOOK_URL, data={"content": msg})
        if response.status_code == 200:
            print(f"[✅] Discord mesajı gönderildi: {msg}")
        else:
            print(f"[❌] Discord mesaj hatası: {response.status_code}")
    except Exception as e:
        print(f"[⚠️] Mesaj gönderim hatası: {e}")

def create_day_folder():
    today = datetime.now().strftime("%d_%m_%Y")
    path = os.path.join(BASE_DIR, today)
    os.makedirs(path, exist_ok=True)
    return path

def save_screenshot(folder_path):
    filename = f"shot_{datetime.now().strftime('%H_%M_%S')}.png"
    full_path = os.path.join(folder_path, filename)
    exit_code = os.system(f"su -c 'screencap -p {full_path}'")

    if exit_code != 0 or not os.path.exists(full_path):
        err = f"[!] Screenshot başarısız ({datetime.now().strftime('%H:%M:%S')})"
        print(err)
        send_to_discord_message(err)
        return None

    print(f"[+] Screenshot kaydedildi: {full_path}")
    return full_path

def send_screenshot(path):
    if path is None:
        return
    timestamp = datetime.now().strftime("%d-%m-%Y %H:%M:%S")
    msg = f"📸 Screenshot alındı ({timestamp})"
    try:
        with open(path, 'rb') as f:
            res = requests.post(WEBHOOK_URL, data={"content": msg}, files={"file": f})
        if res.status_code == 200:
            print(f"[✅] Discord’a gönderildi: {os.path.basename(path)}")
        else:
            print(f"[❌] Gönderim hatası: {res.status_code}, {res.text}")
    except Exception as e:
        print(f"[⚠️] Screenshot gönderim hatası: {e}")
        send_to_discord_message(f"[⚠️] Screenshot gönderim hatası: {e}")

def main():
    send_to_discord_message(f"🚀 Watcher aktif ({datetime.now().strftime('%d-%m-%Y %H:%M:%S')})")
    while True:
        folder = create_day_folder()
        shot = save_screenshot(folder)
        send_screenshot(shot)
        time.sleep(900)  # 15 dakika

if __name__ == "__main__":
    main()
PY

# 4️⃣ requirements.txt oluştur
echo "🧾 requirements.txt oluşturuluyor..."
cat > requirements.txt <<'REQ'
requests
REQ

# 5️⃣ Kullanıcıya talimat göster
clear
echo "✅ Kurulum tamamlandı!"
echo ""
echo "1️⃣ Dosyalar kaydedildi: ~/discord_snap/"
echo "2️⃣ Webhook URL'ni düzenle: ~/discord_snap/discord_screenshot.py"
echo "3️⃣ Kurulum sonrası başlatmak için:"
echo "   cd ~/discord_snap"
echo "   python discord_screenshot.py"
echo ""
echo "⚙️  Script her 15 dakikada bir ekran görüntüsü alır ve Discord’a yollar."
echo "📩 Hata veya başlangıçta mesaj gönderimi otomatik yapılır."
