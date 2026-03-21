sudo apt-get update && sudo apt-get full-upgrade -y

# Install GNOME + Flashback session (no RDP)
sudo apt install -y ubuntu-desktop-minimal gnome-session-flashback metacity dbus-x11

# --- Force boot into GNOME (graphical) after reboot ---
sudo systemctl set-default graphical.target
sudo systemctl enable --now gdm3


# --- Enable UFW with minimal rules for normal use + Intune/Entra ---
# Minimal & safe baseline:
#   - Block inbound by default
#   - Allow outbound by default
# Intune/Entra are outbound (HTTPS 443 primarily; HTTP 80 sometimes used for CRLs). [3](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/reference-connect-ports)[1](https://learn.microsoft.com/en-us/intune/intune-service/user-help/enroll-device-linux)
sudo apt install -y ufw
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow DNS (name resolution) explicitly (not strictly required with allow outgoing, but harmless)
sudo ufw allow out 53

# Allow web (not strictly required with allow outgoing, but documents the intent)
sudo ufw allow out 80/tcp
sudo ufw allow out 443/tcp

# Enable firewall
sudo ufw --force enable


# Install Microsoft Edge
sudo apt install curl ca-certificates gpg -y
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
sudo tee /etc/apt/sources.list.d/microsoft-edge.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/edge
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/microsoft-edge.gpg
Architectures: amd64
EOF
sudo apt update
apt-cache policy microsoft-edge-stable
sudo apt install microsoft-edge-stable -y
sudo rm -f /etc/apt/sources.list.d/microsoft-edge.list
sudo apt update


# Download/Install Intune Linux Application (Microsoft official repo)
sudo apt install -y curl gpg
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" >> /etc/apt/sources.list.d/microsoft-ubuntu-$(lsb_release -cs)-prod.list'
sudo apt update
sudo apt install -y intune-portal

# Reboot recommended after installing Intune app [2](https://www.c-sharpcorner.com/article/how-to-install-and-configure-xrdp-on-azure-ubuntu-server-vm/)
sudo reboot