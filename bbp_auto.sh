#!/bin/bash
set -e

echo "[*] Updating system..."
sudo apt update -y && sudo apt upgrade -y

echo "[*] Installing dependencies..."
sudo apt install -y build-essential git curl wget unzip jq python3 python3-pip

# === Install Go ===
if ! command -v go &> /dev/null; then
    echo "[*] Installing Go..."
    GO_VERSION="1.23.2"
    wget "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz"
    rm "go${GO_VERSION}.linux-amd64.tar.gz"
    
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.bashrc
    echo "export GOPATH=\$HOME/go" >> ~/.bashrc
    echo "export PATH=\$PATH:\$GOPATH/bin" >> ~/.bashrc
    source ~/.bashrc
else
    echo "[*] Go already installed!"
fi

# Reload PATH
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# === Install Go-based tools ===
echo "[*] Installing waybackurls..."
go install github.com/tomnomnom/waybackurls@latest

echo "[*] Installing gau..."
go install github.com/lc/gau/v2/cmd/gau@latest

echo "[*] Installing gf..."
go install github.com/tomnomnom/gf@latest

echo "[*] Installing httpx..."
go install github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "[*] Installing subfinder..."
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

echo "[*] Installing assetfinder..."
go install github.com/tomnomnom/assetfinder@latest

echo "[*] Installing nuclei..."
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

echo "[*] Installing arjun (Python)..."
pip install arjun

# === Install SecLists ===
echo "[*] Cloning SecLists wordlists..."
sudo git clone https://github.com/danielmiessler/SecLists.git /opt/SecLists || echo "[*] SecLists already exists!"

# === Add gf patterns ===
echo "[*] Setting up gf patterns..."
mkdir -p ~/.gf
cp -r "$GOPATH/src/github.com/tomnomnom/gf/examples" ~/.gf 2>/dev/null || true
git clone https://github.com/1ndianl33t/Gf-Patterns ~/.gf-patterns || true
cp ~/.gf-patterns/*.json ~/.gf/ 2>/dev/null || true

# === Clean & Final ===
echo "[*] Updating Nuclei templates..."
nuclei -update-templates

echo
echo "✅ Setup completed!"
echo "👉 Wordlists: /opt/SecLists"
echo "👉 Tools installed in: $GOPATH/bin"
echo "👉 Add to PATH: export PATH=\$PATH:\$GOPATH/bin"
echo "💡 Run 'source ~/.bashrc' to reload environment."
