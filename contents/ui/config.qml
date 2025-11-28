/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Pixel Art Wallpaper Plugin Configuration
*/

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

Kirigami.ScrollablePage {
    id: root

    // Prevent Plasma errors
    property var configDialog
    property var wallpaperConfiguration

    // Configuration Properties
    property alias cfg_SourceType: sourceTypeCombo.currentValue
    property alias cfg_LocalFolderPath: localFolderField.text
    property alias cfg_SearchQuery: searchQueryField.text
    property alias cfg_Categories: categoriesCombo.currentValue
    property alias cfg_Purity: purityCombo.currentValue
    property alias cfg_Sorting: sortingCombo.currentValue
    property alias cfg_MinResolution: resolutionCombo.currentValue
    property alias cfg_FillMode: fillModeCombo.currentIndex
    property int cfg_RefreshTrigger: 0

    Kirigami.FormLayout {
        id: formLayout
        
        // === REFRESH BUTTON ===
        Button {
            Kirigami.FormData.label: i18n("Actions:")
            text: i18n("🎲 Get New Random Wallpaper")
            icon.name: "view-refresh"
            onClicked: {
                // FIX: Use a simple counter instead of Date.now() to avoid Integer Overflow
                root.cfg_RefreshTrigger = root.cfg_RefreshTrigger + 1
                applyHelpLabel.visible = true
            }
        }

        // Help Text (Only visible after clicking button)
        Label {
            id: applyHelpLabel
            visible: false
            text: i18n("🛈 Click 'Apply' below to load the new wallpaper")
            font.italic: true
            color: Kirigami.Theme.highlightColor
            Kirigami.FormData.label: " "
        }

        Item { Kirigami.FormData.isSection: true }

        // === SOURCE SELECTION ===
        ComboBox {
            id: sourceTypeCombo
            Kirigami.FormData.label: i18n("Source:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Wallhaven API (Online)"), value: "api" },
                { text: i18n("Local Folder"), value: "local" }
            ]
        }

        // === LOCAL FOLDER OPTIONS ===
        RowLayout {
            Kirigami.FormData.label: i18n("Folder:")
            visible: sourceTypeCombo.currentValue === "local"
            
            TextField {
                id: localFolderField
                Layout.fillWidth: true
                placeholderText: "file:///home/user/Pictures/wallpapers"
            }
            
            Button {
                text: i18n("Browse...")
                icon.name: "folder-open"
                onClicked: folderDialog.open()
            }
        }

        Label {
            visible: sourceTypeCombo.currentValue === "local"
            text: i18n("Formats: PNG, JPG, GIF, WebP, BMP")
            font.italic: true
            opacity: 0.7
        }

        FolderDialog {
            id: folderDialog
            title: i18n("Select Wallpaper Folder")
            currentFolder: localFolderField.text ? localFolderField.text : ""
            onAccepted: {
                localFolderField.text = selectedFolder
            }
        }

        Item { 
            Kirigami.FormData.isSection: true 
            visible: sourceTypeCombo.currentValue === "api"
        }

        // === API OPTIONS ===
        TextField {
            id: searchQueryField
            Kirigami.FormData.label: i18n("Search:")
            visible: sourceTypeCombo.currentValue === "api"
            placeholderText: "pixel art, 8bit, retro..."
        }

        // Quick presets
        RowLayout {
            Kirigami.FormData.label: i18n("Presets:")
            visible: sourceTypeCombo.currentValue === "api"
            spacing: Kirigami.Units.smallSpacing

            Button {
                text: "Pixel Art"
                onClicked: searchQueryField.text = "pixel art"
            }
            Button {
                text: "8-Bit"
                onClicked: searchQueryField.text = "8bit retro"
            }
            Button {
                text: "Cyberpunk"
                onClicked: searchQueryField.text = "pixel art cyberpunk"
            }
        }

        RowLayout {
            Kirigami.FormData.label: " "
            visible: sourceTypeCombo.currentValue === "api"
            spacing: Kirigami.Units.smallSpacing

            Button {
                text: "Nature"
                onClicked: searchQueryField.text = "pixel art nature landscape"
            }
            Button {
                text: "Space"
                onClicked: searchQueryField.text = "pixel art space stars"
            }
            Button {
                text: "Anime"
                onClicked: searchQueryField.text = "pixel art anime"
            }
        }

        ComboBox {
            id: categoriesCombo
            Kirigami.FormData.label: i18n("Categories:")
            visible: sourceTypeCombo.currentValue === "api"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("General only"), value: "100" },
                { text: i18n("Anime only"), value: "010" },
                { text: i18n("General + Anime"), value: "110" },
                { text: i18n("All"), value: "111" }
            ]
        }

        ComboBox {
            id: purityCombo
            Kirigami.FormData.label: i18n("Content:")
            visible: sourceTypeCombo.currentValue === "api"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("SFW only"), value: "100" },
                { text: i18n("SFW + Sketchy"), value: "110" }
            ]
        }

        ComboBox {
            id: sortingCombo
            Kirigami.FormData.label: i18n("Sorting:")
            visible: sourceTypeCombo.currentValue === "api"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Random"), value: "random" },
                { text: i18n("Latest"), value: "date_added" },
                { text: i18n("Most Viewed"), value: "views" },
                { text: i18n("Top Rated"), value: "toplist" }
            ]
        }

        ComboBox {
            id: resolutionCombo
            Kirigami.FormData.label: i18n("Min Resolution:")
            visible: sourceTypeCombo.currentValue === "api"
            textRole: "text"
            valueRole: "value"
            model: [
                { text: "1280x720 (HD)", value: "1280x720" },
                { text: "1920x1080 (Full HD)", value: "1920x1080" },
                { text: "2560x1440 (2K)", value: "2560x1440" },
                { text: "3840x2160 (4K)", value: "3840x2160" }
            ]
        }

        Item { Kirigami.FormData.isSection: true }

        // === DISPLAY OPTIONS ===
        ComboBox {
            id: fillModeCombo
            Kirigami.FormData.label: i18n("Fill Mode:")
            model: [
                i18n("Stretch"),
                i18n("Fit"),
                i18n("Crop"),
                i18n("Tile"),
                i18n("Tile Vertically"),
                i18n("Tile Horizontally"),
                i18n("Center")
            ]
        }

        Label {
            Kirigami.FormData.label: " "
            text: i18n("Tip: Use 'Crop' fill mode for best results")
            font.italic: true
            opacity: 0.7
        }

        Item { Kirigami.FormData.isSection: true }

        // === INFO ===
        Label {
            visible: sourceTypeCombo.currentValue === "api"
            text: i18n("Wallpapers from wallhaven.cc")
            font.italic: true
            opacity: 0.6
        }
    }
}