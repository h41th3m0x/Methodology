#!/bin/bash
set -e

echo -e "\n🚀 Starting Full Bug Bounty Setup..."

# === System Update ===
sudo apt update -y && sudo apt upgrade -y
sudo apt install -y build-essential git curl wget unzip jq python3 python3-pip snapd

# === Install Go ===
if ! command -v go &>/dev/null; then
    echo -e "\n[*] Installing Go..."
    GO_VERSION="1.23.2"
    wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    
    echo 'export GOPATH=$HOME/go' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> ~/.bashrc
    source ~/.bashrc
fi

# Load env
export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

# === Install Go-based Tools ===
echo -e "\n[*] Installing Go tools..."
go install github.com/tomnomnom/waybackurls@latest
go install github.com/lc/gau/v2/cmd/gau@latest
go install github.com/tomnomnom/gf@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install github.com/projectdiscovery/katana/cmd/katana@latest
go install github.com/tomnomnom/qsreplace@latest
go install github.com/s0md3v/uro@latest
go install github.com/tomnomnom/anew@latest
go install github.com/tomnomnom/hacks/kxss@latest
go install github.com/hahwul/dalfox/v2@latest

# === Install Python Tools ===
echo -e "\n[*] Installing Python tools..."
pip install --upgrade pip
pip install arjun

# === Install Amass ===
echo -e "\n[*] Installing amass..."
sudo snap install amass

# === Install Wordlists ===
echo -e "\n[*] Cloning SecLists..."
sudo git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists || echo "[*] SecLists already installed"

# === Setup gf Patterns ===
echo -e "\n[*] Setting up gf patterns..."
mkdir -p ~/.gf
git clone https://github.com/tomnomnom/gf.git ~/gf-source || true
cp -r ~/gf-source/examples ~/.gf/
git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf-patterns || true
cp ~/.gf-patterns/*.json ~/.gf/ || true

# === Update Nuclei Templates ===
echo -e "\n[*] Updating Nuclei templates..."
nuclei -update-templates || true

# === Aliases ===
echo -e "\n[*] Adding useful aliases..."
cat << 'EOF' >> ~/.bashrc

# === Bug Bounty Aliases ===
alias wf='waybackurls'
alias gff='gf'
alias sf='subfinder'
alias af='assetfinder'
alias nx='nuclei'
alias htx='httpx'
alias aj='arjun'
alias gx='gf xss'
alias gs='gf ssrf'
alias gr='gf redirect'
alias gl='gf lfi'
alias gi='gf idor'
EOF

source ~/.bashrc
