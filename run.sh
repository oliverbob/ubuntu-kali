#!/usr/bin/env bash
set -e

echo "=== Ubuntu Pentest Bootstrap ==="

# Safety check
if [[ $EUID -ne 0 ]]; then
  echo "Run as root: sudo bash install.sh"
  exit 1
fi

echo "[+] Updating system"
apt update && apt upgrade -y

echo "[+] Enabling repositories"
apt install -y software-properties-common
add-apt-repository universe -y
add-apt-repository multiverse -y
apt update

echo "[+] Installing core pentesting tools"
apt install -y \
  nmap \
  wireshark \
  tcpdump \
  net-tools \
  aircrack-ng \
  hcxdumptool \
  hcxtools \
  reaver \
  bully \
  hashcat \
  john \
  hydra \
  sqlmap \
  nikto \
  gobuster \
  dirsearch \
  whois \
  dnsutils \
  proxychains4 \
  tor \
  macchanger \
  tmux \
  neovim \
  git \
  curl \
  build-essential \
  dkms \
  unzip \
  python3-pip

echo "[+] Installing wordlists"
apt install -y wordlists
ln -sf /usr/share/wordlists /opt/wordlists || true

echo "[+] Installing Metasploit Framework"
curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
  | tee /usr/local/bin/msfinstall > /dev/null
chmod +x /usr/local/bin/msfinstall
msfinstall

echo "[+] Initializing Metasploit database"
systemctl enable postgresql
systemctl start postgresql
msfdb init || true

echo "[+] Creating pentest workspace"
mkdir -p /opt/pentest/{wifi,web,exploits,loot,wordlists}
chmod -R 755 /opt/pentest

echo "[+] Optional: Realtek Wi-Fi drivers"
read -p "Install RTL8812AU/8814AU drivers? (y/N): " WIFI
if [[ "$WIFI" =~ ^[Yy]$ ]]; then
  git clone https://github.com/aircrack-ng/rtl8812au.git /opt/rtl8812au
  cd /opt/rtl8812au
  make dkms_install
fi

echo "[+] Done."
echo "Reboot recommended."
echo "Launch Metasploit with: msfconsole"