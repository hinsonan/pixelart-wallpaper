# Pixel Art Wallpaper Plugin for KDE Plasma 6

<div align="center">

A beautiful KDE Plasma 6 wallpaper plugin that brings stunning pixel art wallpapers to your desktop from [Wallhaven](https://wallhaven.cc).

![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)
![KDE Plasma](https://img.shields.io/badge/KDE%20Plasma-6-blue.svg)
![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Configuration](#configuration) • [Troubleshooting](#troubleshooting)

</div>

---

## Screenshots

<div align="center">

### Example Wallpapers

<table>
  <tr>
    <td><img src="https://w.wallhaven.cc/full/8o/wallhaven-8oky1j.jpg" width="400" alt="Pixel Art Cyberpunk City"/><br/><sub>Cyberpunk Cityscape</sub></td>
    <td><img src="https://w.wallhaven.cc/full/zp/wallhaven-zpp3mg.png" width="400" alt="Pixel Art Nature Lake"/><br/><sub>Moonlit Lake</sub></td>
  </tr>
  <tr>
    <td><img src="https://w.wallhaven.cc/full/wq/wallhaven-wq2r8p.png" width="400" alt="Pixel Art Space Stars"/><br/><sub>Space & Stars</sub></td>
    <td><img src="https://w.wallhaven.cc/full/je/wallhaven-jeeq3q.png" width="400" alt="Pixel Art Romantic Scene"/><br/><sub>Starry Night</sub></td>
  </tr>
</table>

*All wallpapers sourced from [Wallhaven.cc](https://wallhaven.cc)*

</div>

---

## Features

- **Random Wallpapers** - Get a new random pixel art wallpaper with one click
- **Wallhaven API Integration** - Fetch wallpapers from wallhaven.cc (no API key required)
- **Customizable Searches** - Search by keywords, categories, and content ratings
- **Multiple Presets** - Quick access to popular pixel art styles (Cyberpunk, Nature, Space, Anime)
- **Quality Control** - Filter by minimum resolution (720p to 4K)
- **Smart Display** - Multiple fill modes to perfectly fit your screen
- **Content Filtering** - SFW-only mode or SFW + Sketchy options
- **Pure QML** - Lightweight and native to KDE Plasma

---

## Requirements

- **KDE Plasma 6** (Plasma 5 is not supported)
- **Qt 6**
- **Internet connection** (for Wallhaven API mode)
- **Linux** (Arch, Ubuntu, Fedora, etc.)

---

## Installation

### Quick Install (Recommended)

1. **Clone or download this repository:**
   ```bash
   git clone https://github.com/hinsonan/pixelart-wallpaper.git
   cd pixelart-wallpaper
   ```

2. **Run the installation script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **The script will:**
   - Install the plugin to `~/.local/share/plasma/wallpapers/com.example.pixelart/`
   - Prompt you to restart Plasma Shell
   - Type `y` to restart automatically

4. **Apply the wallpaper:**
   - Right-click on your desktop
   - Select **Configure Desktop and Wallpaper**
   - Choose **Pixel Art Wallpaper** from the **Wallpaper Type** dropdown

### Manual Installation

If you prefer to install manually:

```bash
# Create plugin directory
mkdir -p ~/.local/share/plasma/wallpapers/com.github.hinsonan.pixelart

# Copy plugin files
cp -r metadata.json contents ~/.local/share/plasma/wallpapers/com.github.hinsonan.pixelart/

# Restart Plasma Shell
killall plasmashell && plasmashell &
```

---

## Usage

### Getting Started

1. **Right-click** on your desktop
2. Select **Configure Desktop and Wallpaper**
3. In the **Wallpaper Type** dropdown, select **Pixel Art Wallpaper**
4. Configure your preferences (see [Configuration](#configuration))
5. Click **Apply** to save

### Getting New Wallpapers

Click the **Get New Random Wallpaper** button in the settings panel, then click **Apply** to load it.

---

## Configuration

### Search Settings

| Setting | Description | Default |
|---------|-------------|---------|
| **Search Query** | Keywords to search for | `pixel art` |
| **Categories** | General, Anime, or both | `General + Anime` |
| **Content Filter** | Content rating (SFW only or SFW + Sketchy) | `SFW only` |
| **Sorting** | Random, Latest, Most Viewed, Top Rated | `Random` |
| **Min Resolution** | Minimum image resolution | `1920x1080` |

### Quick Presets

Use the preset buttons for instant theme changes:

- **Pixel Art** - General pixel art
- **8-Bit** - Retro 8-bit style
- **Cyberpunk** - Neon cities and cyberpunk themes
- **Nature** - Landscapes and natural scenes
- **Space** - Cosmic and space-themed art
- **Anime** - Anime-style pixel art

### Display Settings

| Setting | Options | Recommended |
|---------|---------|-------------|
| **Fill Mode** | Stretch, Fit, Crop, Tile, Center | **Crop** |

**Tip:** Use **Crop** fill mode for best results with most wallpapers.

### Content Filters Explained

- **SFW only** (`100`): Only safe-for-work content
- **SFW + Sketchy** (`110`): Includes suggestive but not explicit content

The three-digit code represents: `[SFW][Sketchy][NSFW]`
- `1` = include
- `0` = exclude

---

## Tips & Tricks

### For Best Pixel Art Display

1. **Use Crop fill mode** - Fills the screen without distortion
2. **Set minimum resolution** to match or exceed your screen resolution
3. **Use specific search terms** for better results

### Recommended Search Queries

Try these search queries for amazing results:

- `pixel art landscape` - Scenic pixel art
- `pixel art cyberpunk neon` - Neon city vibes
- `pixel art space galaxy` - Cosmic scenes
- `pixel art forest` - Nature and forests
- `pixel art sunset` - Sunset scenes
- `pixel art castle` - Medieval and fantasy
- `retro game` - Classic game-style art
- `isometric pixel art` - Isometric perspective art

---

## Troubleshooting

### Plugin Doesn't Appear in Wallpaper List

```bash
# Verify installation
ls -la ~/.local/share/plasma/wallpapers/com.github.hinsonan.pixelart/

# Should show: metadata.json, contents/

# Restart Plasma Shell
killall plasmashell && plasmashell &
```

### No Wallpapers Loading

**Check internet connection:**
```bash
curl -I https://wallhaven.cc
```

**Try different search queries** - Some searches may return no results

**View debug logs:**
```bash
journalctl -f | grep -i qml
```

### Wallpaper Not Updating After Clicking Button

Make sure to click **Apply** after clicking "Get New Random Wallpaper" button.

### Check Plugin Logs

```bash
# Watch for QML errors
journalctl -f | grep -i qml

# Watch Plasma logs
journalctl -f | grep -i plasma
```

---

## Uninstallation

### Using the Script

```bash
chmod +x uninstall.sh
./uninstall.sh
```

### Manual Removal

```bash
rm -rf ~/.local/share/plasma/wallpapers/com.github.hinsonan.pixelart
killall plasmashell && plasmashell &
```

---

## File Structure

```
pixelart-wallpaper/
├── metadata.json              # Plugin metadata
├── install.sh                 # Installation script
├── uninstall.sh               # Uninstallation script
├── LICENSE                    # GPL-3.0 license
├── README.md                  # This file
├── CLAUDE.md                  # Developer documentation
└── contents/
    ├── config/
    │   └── main.xml          # Configuration schema
    └── ui/
        ├── main.qml          # Main wallpaper display logic
        └── config.qml        # Settings panel UI
```

---

## Development

### For Developers

See [CLAUDE.md](CLAUDE.md) for detailed development documentation including:
- Architecture overview
- Component structure
- Configuration flow
- Debugging techniques
- Testing procedures

### Making Changes

1. Edit QML files in `contents/ui/`
2. Run `./install.sh` to reinstall
3. Restart Plasma Shell: `killall plasmashell && plasmashell &`
4. Check logs: `journalctl -f | grep -i qml`

---

## Credits

- **Wallpapers** provided by [Wallhaven.cc](https://wallhaven.cc)
- **Built for** [KDE Plasma](https://kde.org/plasma-desktop/)
- **QML Framework** by Qt

---

## License

This project is licensed under the **GPL-3.0** License - see the [LICENSE](LICENSE) file for details.

---

## Support

Found a bug or have a feature request? Please open an issue on GitHub!
