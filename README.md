# Pixel Art Wallpaper Plugin for KDE Plasma

A KDE Plasma wallpaper plugin that displays random pixel art wallpapers from [Wallhaven](https://wallhaven.cc) or from a local folder.

## Features

- 🎲 **Random Wallpapers** - Get a new random pixel art wallpaper with one click
- 🌐 **Wallhaven API** - Fetch wallpapers from wallhaven.cc (no API key required!)
- 📁 **Local Folder Support** - Use your own collection of images
- ⏰ **Auto-Change** - Automatically change wallpaper at set intervals
- 🔍 **Search Queries** - Customize what type of pixel art you want
- 🎨 **Pixel-Perfect** - Option to disable smoothing for crisp pixel art
- ✨ **Smooth Transitions** - Crossfade animation between wallpapers

## Installation

### Quick Install

```bash
# Clone or download this repository
cd pixelart-wallpaper

# Make install script executable and run it
chmod +x install.sh
./install.sh
```

### Manual Install

```bash
# Create plugin directory
mkdir -p ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper/contents/ui

# Copy files
cp metadata.json ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper/
cp contents/ui/*.qml ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper/contents/ui/

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

## Usage

1. **Right-click** on your desktop
2. Select **Configure Desktop and Wallpaper**
3. In the **Wallpaper Type** dropdown, select **Pixel Art Wallpaper**
4. Configure your settings:
   - Choose between **Wallhaven API** or **Local Folder**
   - Set your search query (for API mode)
   - Set auto-change interval
5. Click **"Get New Random Wallpaper"** button to fetch a new wallpaper

## Configuration Options

### Source Options

| Option | Description |
|--------|-------------|
| **Wallhaven API** | Fetch wallpapers from wallhaven.cc |
| **Local Folder** | Use images from a folder on your computer |

### API Settings (Wallhaven mode)

| Setting | Description |
|---------|-------------|
| **Search Query** | Keywords to search for (e.g., "pixel art", "8bit retro") |
| **Categories** | General, Anime, People, or combinations |
| **Content Filter** | SFW only, or SFW + Sketchy |
| **Sorting** | Random, Latest, Most Viewed, etc. |
| **Min Resolution** | Minimum image resolution (720p to 4K) |

### Display Settings

| Setting | Description |
|---------|-------------|
| **Fill Mode** | How the image fills the screen (Crop, Fit, Stretch, etc.) |
| **Smooth Scaling** | Enable/disable smoothing (disable for crisp pixel art!) |

### Timer Settings

| Setting | Description |
|---------|-------------|
| **Change Interval** | How often to auto-change (15min to Daily, or Never) |

## Quick Presets

The config panel includes quick preset buttons:
- **Pixel Art** - General pixel art
- **8-Bit** - Retro 8-bit style
- **Cyberpunk** - Cyberpunk pixel art cities
- **Nature** - Pixel art landscapes
- **Space** - Space and stars pixel art
- **Anime** - Anime-style pixel art

## Local Folder Setup

1. Create a folder with your pixel art images:
   ```bash
   mkdir -p ~/Pictures/pixel-wallpapers
   ```

2. Add your images (supported formats: PNG, JPG, JPEG, GIF, WebP, BMP)

3. In the plugin settings:
   - Set **Wallpaper Source** to "Local Folder"
   - Click **Browse** and select your folder
   - Or manually enter the path (e.g., `file:///home/user/Pictures/pixel-wallpapers`)

## Tips

### For Best Pixel Art Display

1. **Disable Smooth Scaling** - This keeps pixels crisp and blocky
2. **Use "Preserve Aspect Crop"** - Fills the screen without distortion
3. **Use PNG images** - Avoids JPEG compression artifacts

### Recommended Search Queries

- `pixel art landscape` - Scenic pixel art
- `pixel art cyberpunk neon` - Neon city vibes
- `pixel art space galaxy` - Cosmic scenes
- `pixel art forest` - Nature and forests
- `pixel art sunset` - Sunset scenes
- `retro game` - Classic game-style art

## Troubleshooting

### Plugin doesn't appear in wallpaper type list
```bash
# Make sure files are in the right place
ls -la ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper/

# Restart Plasma
kquitapp5 plasmashell && kstart5 plasmashell
```

### No wallpapers loading (API mode)
- Check your internet connection
- Try a different search query
- Check the terminal for errors: `journalctl -f | grep -i plasma`

### Local folder not working
- Make sure the path starts with `file://`
- Example: `file:///home/username/Pictures/wallpapers`
- Check that images are in supported formats

### View debug output
```bash
# Watch Plasma logs
journalctl -f | grep -i qml

# Or run in a test window (limited functionality)
qmlscene ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper/contents/ui/main.qml
```

## Uninstallation

```bash
# Using the script
chmod +x uninstall.sh
./uninstall.sh

# Or manually
rm -rf ~/.local/share/plasma/wallpapers/com.example.pixelart-wallpaper
kquitapp6 plasmashell && kstart plasmashell &
```

## File Structure

```
pixelart-wallpaper/
├── metadata.json          # Plugin metadata
├── install.sh             # Installation script
├── uninstall.sh           # Uninstallation script
├── README.md              # This file
└── contents/
    └── ui/
        ├── main.qml       # Main wallpaper display logic
        └── config.qml     # Settings panel UI
```

## Credits

- Wallpapers provided by [Wallhaven.cc](https://wallhaven.cc)
- Built for KDE Plasma

## License

GPL-3.0+
