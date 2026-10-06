#!/bin/bash

# ==========================================
# Debian DNS + Web Server Installer
# IP     : 192.168.7.7
# Domain : raffi.com
# ==========================================

# Pastikan dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Jalankan dengan: sudo ./installer.sh"
    exit 1
fi

echo "=========================================="
echo "   INSTALL DNS + WEB SERVER"
echo "=========================================="

# Update repository
apt update

# Install package
apt install -y bind9 bind9-utils dnsutils apache2

# ==========================================
# KONFIGURASI DNS
# ==========================================

echo "[1/5] Konfigurasi DNS..."

cat > /etc/bind/named.conf.local <<'EOF'
zone "raffi.com" {
    type master;
    file "/etc/bind/db.raffi.com";
};
EOF

cat > /etc/bind/db.raffi.com <<'EOF'
$TTL    604800
@       IN      SOA     ns.raffi.com. admin.raffi.com. (
                        2
                        604800
                        86400
                        2419200
                        604800 )

@       IN      NS      ns.raffi.com.
@       IN      A       192.168.7.7
ns      IN      A       192.168.7.7
www     IN      A       192.168.7.7
EOF

# ==========================================
# CEK KONFIGURASI DNS
# ==========================================

echo "[2/5] Mengecek konfigurasi DNS..."

named-checkconf

if [ $? -ne 0 ]; then
    echo "ERROR: Konfigurasi BIND9 salah!"
    exit 1
fi

named-checkzone raffi.com /etc/bind/db.raffi.com

if [ $? -ne 0 ]; then
    echo "ERROR: Zone DNS salah!"
    exit 1
fi

# ==========================================
# KONFIGURASI WEB SERVER
# ==========================================

echo "[3/5] Membuat halaman Web Server..."

cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Raffi Web Server</title>
</head>
<body>
    <h1>RAFFI.COM</h1>
    <p>Debian Web Server berhasil berjalan.</p>
    <p>IP Server: 192.168.7.7</p>
    <p>DNS Server: BIND9</p>
    <p>Web Server: Apache2</p>
</body>
</html>
EOF

# ==========================================
# RESTART SERVICE
# ==========================================

echo "[4/5] Menjalankan service..."

systemctl restart bind9
systemctl restart apache2

systemctl enable bind9
systemctl enable apache2

# ==========================================
# SELESAI
# ==========================================

echo "[5/5] Instalasi selesai!"

echo ""
echo "=========================================="
echo "        INSTALLASI BERHASIL"
echo "=========================================="
echo "IP Server  : 192.168.7.7"
echo "Domain     : raffi.com"
echo "DNS        : BIND9"
echo "Web Server : Apache2"
echo ""
echo "Tes Web:"
echo "http://192.168.7.7"
echo ""
echo "Tes DNS:"
echo "nslookup www.raffi.com 192.168.7.7"
echo "=========================================="