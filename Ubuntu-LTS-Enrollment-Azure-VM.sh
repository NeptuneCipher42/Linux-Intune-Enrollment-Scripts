#!/bin/bash
# Azure VM Ubuntu 22.04 - Intune Enrollment Prep

# Full update
sudo apt-get update && apt-get full-upgrade -y

#Install and enable GNOME
# Install GNOME + Flashback session
sudo apt-get install -y ubuntu-desktop-minimal gnome-session-flashback metacity xrdp xorgxrdp dbus-x11

# Enable XRDP
sudo systemctl enable --now xrdp
sudo adduser xrdp ssl-cert


# --- XRDP session fix: force Ubuntu GNOME session so dock/taskbar appears ---
# 1) Start GNOME session for XRDP
echo "gnome-session" > "$HOME/.xsession"
sudo systemctl restart xrdp

# Microsoft Edge
sudo curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge-dev.list'
sudo rm microsoft.gpg
sudo apt update && sudo apt install microsoft-edge-stable

# Intune Portal
sudo curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/
rm microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list'
sudo apt-get update
sudo apt install -y intune-portal

sudo reboot
#Sign into Edge first with proper domain then sign into the intune portal app to finish installation
