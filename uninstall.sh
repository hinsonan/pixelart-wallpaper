#!/bin/bash

# Pixel Art Wallpaper Plugin Uninstaller
# =======================================

PLUGIN_ID="com.example.pixelart"
INSTALL_DIR="$HOME/.local/share/plasma/wallpapers/$PLUGIN_ID"

echo "╔═══════════════════════════════════════════╗"
echo "║  Pixel Art Wallpaper Plugin Uninstaller   ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

if [ -d "$INSTALL_DIR" ]; then
    read -p "Are you sure you want to uninstall the Pixel Art Wallpaper plugin? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "🗑️  Removing plugin..."
        rm -rf "$INSTALL_DIR"
        echo "✅ Plugin uninstalled successfully!"
        echo ""
        echo "ℹ️  You may want to restart Plasma Shell:"
        echo "   kquitapp6 plasmashell && kstart plasmashell &"
    else
        echo "❌ Uninstall cancelled."
    fi
else
    echo "ℹ️  Plugin is not installed."
fi
