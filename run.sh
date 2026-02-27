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
  net-tools \
  postgresql postgresql-contrib

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

echo "[+] Installing wordlists (no apt wordlists/seclists)"
WORDLIST_DIR="$HOME/wordlists"
mkdir -p "$WORDLIST_DIR"

if [[ ! -d "$WORDLIST_DIR/SecLists" ]]; then
  git clone --depth=1 https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
else
  echo "[=] SecLists already exists, skipping clone"
fi

if [[ ! -f "$WORDLIST_DIR/rockyou.txt" ]]; then
  wget -O "$WORDLIST_DIR/rockyou.txt" \
    https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
else
  echo "[=] rockyou.txt already exists, skipping download"
fi

echo "[✓] Wordlists ready at $WORDLIST_DIR"

echo "[+] Installing Metasploit Framework (official)"
curl -fsSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
  | tee /usr/local/bin/msfinstall > /dev/null
chmod +x /usr/local/bin/msfinstall
msfinstall

echo "[+] Setting up PostgreSQL for Metasploit"
if systemctl list-unit-files | grep -q '^postgresql\.service'; then
  systemctl enable --now postgresql
else
  echo "[!] postgresql.service not found, using fallback startup methods"
  service postgresql start || true
  if command -v pg_ctlcluster >/dev/null 2>&1; then
    pg_lsclusters --no-header 2>/dev/null | while read -r version cluster _; do
      pg_ctlcluster "$version" "$cluster" start || true
    done
  fi
fi
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