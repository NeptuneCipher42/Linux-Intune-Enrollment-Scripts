# Prep Fresh Azure VM for Intune Enrollment

# Full Update
sudo apt-get update && sudo apt-get full-upgrade -y

# Install GNOME + Flashback session + XRDP
sudo apt-get install -y ubuntu-desktop-minimal gnome-session-flashback metacity xrdp xorgxrdp dbus-x11

# Enable XRDP
sudo systemctl enable --now xrdp

# Tell XRDP to start GNOME Flashback
echo "gnome-session --session=gnome-flashback-metacity" > ~/.xsession

# ---------------------------
# UFW Firewall (Minimum inbound + SSH + RDP)
# ---------------------------

# Install UFW (usually present on Ubuntu, but safe to enforce)
sudo apt-get install -y ufw

# Set sane defaults (least privilege)
sudo ufw default deny incoming
sudo ufw default allow outgoing   # typical desktop client needs outbound, not inbound [1](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu)

# Allow SSH (so you don't lock yourself out)
sudo ufw allow 22/tcp comment "SSH"   # best practice before enabling [1](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu)

# Allow RDP for XRDP (XRDP listens on 3389)
sudo ufw allow 3389/tcp comment "RDP (xrdp)"   [2](https://support.stordis.com/hc/en-us/articles/26026787269149-How-to-Set-Up-RDP-on-Ubuntu-24-04-for-Remote-Access)[3](https://askubuntu.com/questions/234856/unable-to-do-remote-desktop-using-xrdp)

# (Optional) enable logging (low)
sudo ufw logging low

# Enable firewall + start on boot
sudo ufw --force enable   [1](https://www.digitalocean.com/community/tutorials/how-to-set-up-a-firewall-with-ufw-on-ubuntu)[4](https://unix.stackexchange.com/questions/555020/how-should-i-enable-ufw-through-systemctl-enable-or-ufw-enable)

# Show status
sudo ufw status verbose

# ---------------------------
# Install Microsoft Edge
# ---------------------------
sudo apt-get install -y curl ca-certificates gpg
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft-edge.gpg
sudo tee /etc/apt/sources.list.d/microsoft-edge.sources > /dev/null << 'EOF'
Types: deb
URIs: https://packages.microsoft.com/repos/edge
Suites: stable
Components: main
Signed-By: /usr/share/keyrings/microsoft-edge.gpg
Architectures: amd64
EOF
sudo apt-get update
apt-cache policy microsoft-edge-stable
sudo apt-get install -y microsoft-edge-stable
sudo rm -f /etc/apt/sources.list.d/microsoft-edge.list
sudo apt-get update

# ---------------------------
# Download/Install Intune Linux Portal
# ---------------------------
sudo apt-get install -y curl gpg
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm -f microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/$(lsb_release -rs)/prod $(lsb_release -cs) main" >> /etc/apt/sources.list.d/microsoft-ubuntu-$(lsb_release -cs)-prod.list'
sudo apt-get update
sudo apt-get install -y intune-portal