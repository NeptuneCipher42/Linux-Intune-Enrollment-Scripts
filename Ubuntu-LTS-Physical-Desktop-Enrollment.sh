#!/bin/bash
# ===== Ensure GNOME is installed and active =====
if [ "${XDG_CURRENT_DESKTOP:-}" != "GNOME" ] && [ "${XDG_CURRENT_DESKTOP:-}" != "ubuntu:GNOME" ]; then
    echo "GNOME not detected. Installing and configuring GNOME + XRDP..."
    sudo apt update
    sudo apt install -y ubuntu-desktop-minimal gnome-session-flashback metacity xrdp xorgxrdp dbus-x11

    sudo systemctl enable --now xrdp
    sudo adduser xrdp ssl-cert

    # --- XRDP session fix: force Ubuntu GNOME session so dock/taskbar appears ---
    # 1) Start GNOME session for XRDP
    echo "gnome-session" > "$HOME/.xsession"

    # 2) Force Ubuntu session env vars so you get ubuntu:GNOME (dock, appearance settings, etc.)
    cat > "$HOME/.xsessionrc" <<'EOF'
export XAUTHORITY=${HOME}/.Xauthority
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
EOF

    sudo systemctl restart xrdp

    echo "GNOME installation/config complete. System will reboot at end."
else
    echo "GNOME already running."
fi

# ===== Prereqs =====
sudo apt update
sudo apt install -y curl gpg ca-certificates

sudo reboot
#Run After reboot
# ===== Microsoft Edge (Stable) =====
# Use keyring + signed-by (cleaner than /etc/apt/trusted.gpg.d)
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main" > /etc/apt/sources.list.d/microsoft-edge.list'
sudo apt update
sudo apt install -y microsoft-edge-stable

# ===== Intune Portal =====
# Microsoft official guidance uses packages.microsoft.com + keyring + signed-by [2](https://learn.microsoft.com/en-us/intune/intune-service/user-help/microsoft-intune-app-linux)[3](https://github.com/MicrosoftDocs/memdocs/diffs/0?base_sha=d1750008bfcfad3622c4f7d23881fd54f0b11613&head_user=aaronparker&name=main&pull_number=4095&qualified_name=refs%2Fheads%2Fmain&sha1=d1750008bfcfad3622c4f7d23881fd54f0b11613&sha2=1a2be7209f7a976c8a8d5b9227e4c4d74b5e3dba&short_path=628a057&unchanged=expanded&w=false)
sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-ubuntu-jammy-prod.list'
sudo apt update
sudo apt install -y intune-portal

# ===== Reboot =====
echo "Rebooting system..."
sudo reboot

#Sign into Edge first with proper domain then sign into the intune portal app to finish installation
