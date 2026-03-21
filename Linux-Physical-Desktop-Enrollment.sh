#!/bin/bash

# ===== Ensure GNOME is installed and active =====
if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ]; then
    echo "GNOME not detected. Installing and configuring GNOME..."
    sudo apt install -y ubuntu-desktop-minimal gnome-session-flashback metacity xrdp xorgxrdp dbus-x11
    sudo systemctl enable --now xrdp
    sudo adduser xrdp ssl-cert
    # Set gdm3 as default display manager
    echo "gnome-session --session=gnome-flashback-metacity" > ~/.xsession
    # Enable GDM3
    sudo systemctl enable gdm3

    echo "GNOME installation/config complete. System will reboot at end."
else
    echo "GNOME already running."
fi

# ===== Microsoft Edge =====
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg
sudo apt update && sudo apt install -y microsoft-edge-stable

# ===== Intune Portal =====
sudo curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft.gpg
rm microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list'
sudo apt update
sudo apt install -y intune-portal

# ===== Reboot =====
echo "Rebooting system..."
sudo reboot
