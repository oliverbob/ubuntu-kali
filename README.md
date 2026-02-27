# Ubuntu + Kali-style Daily Toolkit

This repo helps you upgrade a fresh Ubuntu install so it covers roughly **90% of common Kali daily-use workflows** while staying on Ubuntu.

It focuses on practical categories used most often:
- networking and recon
- web and API testing
- wireless and packet analysis
- password auditing
- forensics and binaries
- containers and scripting

## Scope and expectation

- You will get a broad toolkit for lab, CTF, and defensive testing workflows.
- Some niche Kali workflows still need dedicated Kali packages or custom builds.
- Use this only on systems and targets you own or are explicitly authorized to test.

## Quick start

```bash
chmod +x run.sh
./run.sh
```

## What to install (recommended baseline)

The package list below is tuned for daily use rather than full parity with Kali.

### Core utilities

```bash
sudo apt update
sudo apt install -y \
  curl wget git vim tmux jq yq ripgrep fd-find tree htop net-tools \
  build-essential python3 python3-pip python3-venv pipx openjdk-17-jre \
  ca-certificates gnupg lsb-release unzip p7zip-full \
  postgresql postgresql-contrib
```

### Networking, recon, and scanning

```bash
sudo apt install -y \
  nmap masscan dnsutils whois traceroute tcpdump tshark wireshark \
  netcat-openbsd socat nikto whatweb amap arp-scan
```

### Web and service testing

```bash
sudo apt install -y \
  sqlmap wfuzz ffuf gobuster dirb hydra
```

### Wireless and Bluetooth

```bash
sudo apt install -y \
  aircrack-ng reaver bully wifite hcxdumptool hcxtools bluez-tools
```

### Password auditing and hashes

```bash
sudo apt install -y \
  john hashcat hashcat-data crunch
```

### Reverse engineering and forensics

```bash
sudo apt install -y \
  binwalk foremost testdisk sleuthkit exiftool radare2 gdb strace ltrace
```

### Containers and local lab setup

```bash
sudo apt install -y docker.io docker-compose-v2
sudo usermod -aG docker "$USER"
```

Log out and back in for Docker group membership to apply.

## Python tools (via pipx)

```bash
pipx ensurepath
pipx install impacket
pipx install mitmproxy
pipx install ropper
```

## Wordlists (no apt wordlists/seclists)

```bash
WORDLIST_DIR="$HOME/wordlists"
mkdir -p "$WORDLIST_DIR"

# SecLists replacement
if [ ! -d "$WORDLIST_DIR/SecLists" ]; then
  git clone --depth=1 https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
fi

# RockYou replacement
if [ ! -f "$WORDLIST_DIR/rockyou.txt" ]; then
  wget -O "$WORDLIST_DIR/rockyou.txt" \
    https://github.com/brannondorsey/naive-hashcat/releases/download/data/rockyou.txt
fi

echo "[✓] Wordlists ready at $WORDLIST_DIR"
```

## Sanity check

```bash
nmap --version
sqlmap --version
hashcat --version
aircrack-ng --help | head -n 1
tshark --version | head -n 1
```

## Notes

- `wireshark` capture may require adding your user to `wireshark` or using root privileges depending on distro defaults.
- Some tools move fast; if an apt package is old, prefer official project install instructions.
- Keep Ubuntu patched (`sudo apt upgrade`) and isolate offensive tooling in VMs when possible.
