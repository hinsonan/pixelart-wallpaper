#!/bin/bash

# Pixel Art Wallpaper Plugin Installer
# =====================================
# Installs the KDE Plasma 6 wallpaper plugin to ~/.local/share/plasma/wallpapers/

PLUGIN_ID="com.github.hinsonan.pixelart"
INSTALL_DIR="$HOME/.local/share/plasma/wallpapers/$PLUGIN_ID"

echo "╔═══════════════════════════════════════════╗"
echo "║   Pixel Art Wallpaper Plugin Installer    ║"
echo "╚═══════════════════════════════════════════╝"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Remove old installation
if [ -d "$INSTALL_DIR" ]; then
    echo "🗑️  Removing old installation..."
    rm -rf "$INSTALL_DIR"
fi

# Also remove old versions with legacy IDs if they exist
OLD_INSTALLS=(
    "$HOME/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper"
    "$HOME/.local/share/plasma/wallpapers/com.example.pixelart"
)

for old_install in "${OLD_INSTALLS[@]}"; do
    if [ -d "$old_install" ]; then
        echo "🗑️  Removing old version: $old_install"
        rm -rf "$old_install"
    fi
done

# Create directories
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR/contents/ui"
mkdir -p "$INSTALL_DIR/contents/ui/components"
mkdir -p "$INSTALL_DIR/contents/config"

# Copy files
echo "📋 Copying files..."
cp "$SCRIPT_DIR/metadata.json" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/contents/ui/main.qml" "$INSTALL_DIR/contents/ui/"
cp "$SCRIPT_DIR/contents/ui/config.qml" "$INSTALL_DIR/contents/ui/"
cp "$SCRIPT_DIR/contents/ui/components/WallhavenAPI.qml" "$INSTALL_DIR/contents/ui/components/"
cp "$SCRIPT_DIR/contents/config/main.xml" "$INSTALL_DIR/contents/config/"

# Verify
echo "✅ Checking installation..."
ls -la "$INSTALL_DIR/"
ls -la "$INSTALL_DIR/contents/ui/"
ls -la "$INSTALL_DIR/contents/ui/components/"
ls -la "$INSTALL_DIR/contents/config/"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📍 Installed to: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "  1. Restart Plasma: killall plasmashell && plasmashell &"
echo "  2. Right-click desktop → Configure Desktop and Wallpaper"
echo "  3. Select 'Pixel Art Wallpaper' from Wallpaper Type"
echo ""

read -p "Restart Plasma now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Restarting..."
    killall plasmashell 2>/dev/null
    sleep 1
    plasmashell &
    disown
fi
