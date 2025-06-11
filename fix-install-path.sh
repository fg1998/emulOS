#!/bin/bash

APP_SOURCE="/emulos"
APP_DEST="/opt/emulos"
SYMLINK_PATH="/usr/bin/emulos"
EXECUTABLE="emulos"  # nome do executável (gerado pelo Electron)

# Move a instalação para o /opt
if [ -d "$APP_SOURCE" ]; then
  echo "Moving app from $APP_SOURCE to $APP_DEST"
  mkdir -p "$APP_DEST"
  mv "$APP_SOURCE"/* "$APP_DEST"/
  rmdir "$APP_SOURCE"
fi

# Corrige permissões
chown -R root:root "$APP_DEST"
chmod -R 755 "$APP_DEST"

# Cria o symlink para /usr/bin
if [ -f "$APP_DEST/$EXECUTABLE" ]; then
  ln -sf "$APP_DEST/$EXECUTABLE" "$SYMLINK_PATH"
  chmod +x "$APP_DEST/$EXECUTABLE"
  echo "Symlink created: $SYMLINK_PATH -> $APP_DEST/$EXECUTABLE"
else
  echo "Executable not found at $APP_DEST/$EXECUTABLE"
fi
