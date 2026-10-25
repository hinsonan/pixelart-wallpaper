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

# --restart / --no-restart make this script usable from automation.
AUTO_RESTART=""
for arg in "$@"; do
    case "$arg" in
        --restart) AUTO_RESTART="y" ;;
        --no-restart) AUTO_RESTART="n" ;;
        -h|--help)
            echo "Usage: $0 [--restart|--no-restart]"
            echo ""
            echo "  --restart     reinstall and restart Plasma (detached from this terminal)"
            echo "  --no-restart  reinstall only (default when stdin is not a terminal)"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg (try --help)" >&2
            exit 2
            ;;
    esac
done

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
cp "$SCRIPT_DIR/contents/ui/components/WallpaperState.qml" "$INSTALL_DIR/contents/ui/components/"
cp "$SCRIPT_DIR/contents/ui/components/RetryPolicy.qml" "$INSTALL_DIR/contents/ui/components/"
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
echo "  1. Restart Plasma (see below, or run: ./install.sh --restart)"
echo "  2. Right-click desktop → Configure Desktop and Wallpaper"
echo "  3. Select 'Pixel Art Wallpaper' from Wallpaper Type"
echo ""

# ---------------------------------------------------------------------------
# Restarting Plasma
#
# IMPORTANT: never run `plasmashell &` from this script. A background job
# inherits this terminal, so plasmashell would
#   * keep printing QML logs into it (which looks like a hung terminal), and
#   * stay attached to it, so closing the terminal can take the desktop down.
#
# Instead either let systemd own it (if it already does) or start it in its
# own session with no controlling terminal and no inherited stdio.
# ---------------------------------------------------------------------------
restart_plasma() {
    local unit="plasma-plasmashell.service"
    local i

    if systemctl --user is-active --quiet "$unit" 2>/dev/null; then
        echo "🔄 Restarting Plasma via systemd ($unit)..."
        systemctl --user restart "$unit"
        sleep 2
        pgrep -x plasmashell >/dev/null 2>&1
        return $?
    fi

    echo "🔄 Restarting Plasma..."

    if command -v pkill >/dev/null 2>&1; then
        pkill -x plasmashell 2>/dev/null
    else
        killall plasmashell 2>/dev/null
    fi

    # Wait for the old instance (and its org.kde.plasmashell D-Bus name) to go.
    for i in $(seq 1 20); do
        pgrep -x plasmashell >/dev/null 2>&1 || break
        sleep 0.25
    done

    if command -v setsid >/dev/null 2>&1; then
        setsid plasmashell </dev/null >/dev/null 2>&1 &
    else
        nohup plasmashell </dev/null >/dev/null 2>&1 &
    fi
    disown 2>/dev/null || true

    for i in $(seq 1 20); do
        pgrep -x plasmashell >/dev/null 2>&1 && return 0
        sleep 0.25
    done
    return 1
}

# --restart / --no-restart make this script usable from automation.
if [ -n "$AUTO_RESTART" ]; then
    REPLY="$AUTO_RESTART"
elif [ -t 0 ]; then
    read -p "Restart Plasma now? (y/n) " -n 1 -r
    echo
else
    REPLY="n"
fi

if [[ $REPLY =~ ^[Yy]$ ]]; then
    if restart_plasma; then
        echo "✅ Plasma restarted (detached from this terminal)."
        echo "   Logs: journalctl --user -b -f | grep -i -E 'plasmashell|qml'"
    else
        echo "⚠️  Could not restart Plasma automatically."
        echo "   Start it manually with:"
        echo "     setsid plasmashell </dev/null >/dev/null 2>&1 &"
    fi
fi
