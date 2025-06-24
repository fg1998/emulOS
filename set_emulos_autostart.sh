#!/bin/bash
set -e

# Dependencies
DEPENDENCIES=("dialog")

for prog in "${DEPENDENCIES[@]}"; do
  if ! command -v "$prog" &> /dev/null; then
    echo "Error: '$prog' is not installed. Please install it using: sudo apt-get install -y $prog"
    exit 1
  fi
done

APP_PATH="$HOME/emulos-app/emulos"
XINITRC="$HOME/.xinitrc"

# Check if EmulOS exists
if [ ! -f "$APP_PATH" ]; then
  dialog --msgbox "Error: EmulOS not found at $APP_PATH. Please install it first." 8 60
  exit 1
fi

# Warn user if X is not configured
if ! command -v startx &> /dev/null; then
  dialog --msgbox "Warning: 'startx' not found. X may not be properly installed." 8 60
fi

# Create .xinitrc with openbox and EmulOS if not present
if [ ! -f "$XINITRC" ]; then
  echo "#!/bin/bash" > "$XINITRC"
  echo "exec openbox-session &" >> "$XINITRC"
  echo "sleep 1" >> "$XINITRC"
  echo "exec \"$APP_PATH\"" >> "$XINITRC"
  chmod +x "$XINITRC"
else
  # Update existing .xinitrc
  grep -q "$APP_PATH" "$XINITRC" || echo "exec \"$APP_PATH\"" >> "$XINITRC"
fi

# Success
dialog --title "Autostart Enabled" --msgbox "EmulOS will now start automatically with X.\n\nTo launch, type:\n\nstartx" 10 60
