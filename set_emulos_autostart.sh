#!/bin/bash
set -e

# Detect real user and home
TARGET_USER=$(logname)
TARGET_HOME=$(eval echo "~$TARGET_USER")
APP_PATH="$TARGET_HOME/emulos-app/emulos"
XINITRC="$TARGET_HOME/.xinitrc"
BASH_PROFILE="$TARGET_HOME/.bash_profile"

# Dependencies
DEPENDENCIES=("dialog" "startx")

for prog in "${DEPENDENCIES[@]}"; do
  if ! command -v "$prog" &> /dev/null; then
    echo "Error: '$prog' is not installed. Please install it using: sudo apt-get install -y $prog"
    exit 1
  fi
done

# Check if EmulOS binary exists
if [ ! -f "$APP_PATH" ]; then
  dialog --title "Error" --msgbox "EmulOS binary not found at:\n\n$APP_PATH\n\nPlease install it first." 10 60
  exit 1
fi

# Create or update .xinitrc
if [ ! -f "$XINITRC" ]; then
  echo "#!/bin/bash" > "$XINITRC"
  echo "exec openbox-session &" >> "$XINITRC"
  echo "sleep 1" >> "$XINITRC"
  echo "exec \"$APP_PATH\"" >> "$XINITRC"
else
  # Prevent duplicate entries
  grep -q "$APP_PATH" "$XINITRC" || echo "exec \"$APP_PATH\"" >> "$XINITRC"
fi

chmod +x "$XINITRC"
chown "$TARGET_USER:$TARGET_USER" "$XINITRC"

# Create or update .bash_profile to run startx
if [ ! -f "$BASH_PROFILE" ]; then
  echo "#!/bin/bash" > "$BASH_PROFILE"
  echo '[ -z "$DISPLAY" ] && startx' >> "$BASH_PROFILE"
else
  grep -q "startx" "$BASH_PROFILE" || echo '[ -z "$DISPLAY" ] && startx' >> "$BASH_PROFILE"
fi

chmod +x "$BASH_PROFILE"
chown "$TARGET_USER:$TARGET_USER" "$BASH_PROFILE"

# Final message
dialog --title "Autostart Configured" --msgbox "EmulOS is now configured to launch automatically at boot.\n\nX will start via 'startx' and load EmulOS with Openbox." 10 60
