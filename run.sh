#!/usr/bin/env bash
set -e

echo "======================================"
echo " Ubuntu Pentest Bootstrap (Kali-grade)"
echo "======================================"

# Root check
if [[ $EUID -ne 0 ]]; then
  echo "[-] Run as root: sudo bash ubuntu-pentest-bootstrap.sh"
  exit 1
fi

echo "[+] Updating system"
apt update && apt upgrade -y

echo "[+] Enabling Ubuntu repositories"
apt install -y software-properties-common
add-apt-repository universe -y
add-apt-repository multiverse -y
apt update

echo "[+] Installing core dependencies"
apt install -y \
  git curl wget unzip \
  build-essential dkms \
  python3 python3-pip \
  net-tools

echo "[+] Installing pentesting tools"
apt install -y \
  nmap \
  wireshark \
  tcpdump \
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
  neovim

echo "[+] Installing wordlists"
apt install -y wordlists seclists

# Extract rockyou if needed
if [[ -f /usr/share/wordlists/rockyou.txt.gz ]]; then
  echo "[+] Extracting rockyou.txt"
  gunzip -f /usr/share/wordlists/rockyou.txt.gz
fi

echo "[+] Linking wordlists to /opt"
mkdir -p /opt/wordlists
ln -sf /usr/share/wordlists /opt/wordlists/system || true
ln -sf /usr/share/seclists /opt/wordlists/seclists || true

echo "[+] Installing Metasploit Framework (official)"
curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
  | tee /usr/local/bin/msfinstall > /dev/null
chmod +x /usr/local/bin/msfinstall
msfinstall

echo "[+] Setting up PostgreSQL for Metasploit"
systemctl enable postgresql
systemctl start postgresql
msfdb init || true

echo "[+] Creating pentest workspace"
mkdir -p /opt/pentest/{wifi,web,exploits,hashcat,loot,reports}
chmod -R 755 /opt/pentest

echo "[+] Optional: Install RTL8812AU / RTL8814AU Wi-Fi drivers"
read -p "Install Realtek RTL88xxAU monitor-mode drivers? (y/N): " WIFI
if [[ "$WIFI" =~ ^[Yy]$ ]]; then
  echo "[+] Installing Realtek drivers"
  git clone https://github.com/aircrack-ng/rtl8812au.git /opt/rtl8812au
  cd /opt/rtl8812au
  make dkms_install
fi

echo "[+] Post-install notes"
echo "--------------------------------------"
echo "• Add your user to wireshark group:"
echo "  sudo usermod -aG wireshark \$USER"
echo "• Log out / reboot after install"
echo "• Start Metasploit with: msfconsole"
echo "• Hashcat test: hashcat -I"
echo "--------------------------------------"

echo "[✓] Installation complete. Reboot recommended."