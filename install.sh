#!/bin/bash

PLUGIN_ID="com.example.pixelart"
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

# Also remove old version with different ID if exists
OLD_INSTALL="$HOME/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper"
if [ -d "$OLD_INSTALL" ]; then
    echo "🗑️  Removing old version..."
    rm -rf "$OLD_INSTALL"
fi

# Create directories
echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR/contents/ui"
mkdir -p "$INSTALL_DIR/contents/config"

# Copy files
echo "📋 Copying files..."
cp "$SCRIPT_DIR/metadata.json" "$INSTALL_DIR/"
cp "$SCRIPT_DIR/contents/ui/main.qml" "$INSTALL_DIR/contents/ui/"
cp "$SCRIPT_DIR/contents/ui/config.qml" "$INSTALL_DIR/contents/ui/"
cp "$SCRIPT_DIR/contents/config/main.xml" "$INSTALL_DIR/contents/config/"

# Verify
echo "✅ Checking installation..."
ls -la "$INSTALL_DIR/"
ls -la "$INSTALL_DIR/contents/ui/"
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
