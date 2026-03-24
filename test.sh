#!/bin/bash
# Azure VM RHEL 8/9 - Intune Enrollment Prep (GNOME + XRDP + Edge + Intune Portal)

set -euo pipefail

echo "[1/7] Update system"
sudo dnf -y update

echo "[2/7] Install GNOME desktop (Workstation group)"
# If you are on a minimal/server image, this brings in GNOME + GUI tooling.
sudo dnf -y groupinstall "Workstation"

echo "[3/7] Enable EPEL (needed for xrdp on many RHEL builds) and install XRDP"
# EPEL release package (RHEL9 shown; works for RHEL9. For RHEL8 swap to epel-release-latest-8.noarch.rpm)
if rpm -q --quiet redhat-release && grep -qE 'release 9' /etc/redhat-release; then
  sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
else
  sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
fi

# XRDP + VNC backend is a common working combo on RHEL-like distros
sudo dnf -y install xrdp tigervnc-server

echo "[4/7] Enable and start XRDP"
sudo systemctl enable --now xrdp

# Optional: open firewall port if firewalld is running
if systemctl is-active --quiet firewalld; then
  echo "[4a] Opening firewall port 3389/tcp (firewalld active)"
  sudo firewall-cmd --permanent --add-port=3389/tcp
  sudo firewall-cmd --reload
fi

echo "[5/7] XRDP session fix: force GNOME session"
# Similar to your Ubuntu .xsession approach; some builds prefer ~/.Xclients
echo "gnome-session" > "$HOME/.Xclients"
chmod +x "$HOME/.Xclients"

# Also set .xsession for compatibility with some xrdp configs
echo "gnome-session" > "$HOME/.xsession"

sudo systemctl restart xrdp

# ===== Microsoft Edge (Stable) =====
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/edge
sudo mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge.repo
sudo dnf install microsoft-edge-stable

sudo dnf -y install microsoft-edge-stable

# ===== Intune Portal =====
# NOTE:
# Microsoft Intune Portal for Linux is ONLY supported on Ubuntu.
# There is NO supported RHEL / RPM package.
# Leaving this commented intentionally so automation does not fail.
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/microsoft-rhel9.0-prod
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo dnf config-manager --add-repo https://packages.microsoft.com/yumrepos/microsoft-rhel9.0-prod
sudo dnf install intune-portal

echo "Done. Rebooting..."
sudo reboot
