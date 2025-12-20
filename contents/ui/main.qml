import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid
import "components"

WallpaperItem {
    id: root

    anchors.fill: parent
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    // Config Properties
    readonly property string searchQuery: (configuration && configuration.SearchQuery) ? configuration.SearchQuery : "pixel art"
    readonly property string categories: (configuration && configuration.Categories) ? configuration.Categories : "110"
    readonly property string purity: (configuration && configuration.Purity) ? configuration.Purity : "100"
    readonly property string sorting: (configuration && configuration.Sorting) ? configuration.Sorting : "random"
    readonly property string minResolution: (configuration && configuration.MinResolution) ? configuration.MinResolution : "1920x1080"
    readonly property int fillModeValue: (configuration && configuration.FillMode !== undefined) ? configuration.FillMode : 2
    readonly property int refreshTrigger: (configuration && configuration.RefreshTrigger) ? configuration.RefreshTrigger : 0

    // State properties
    property string currentImageSource: ""
    property bool isLoading: false
    property string statusMessage: ""

    // Wallhaven API component
    WallhavenAPI {
        id: wallhavenApi
        searchQuery: root.searchQuery
        categories: root.categories
        purity: root.purity
        sorting: root.sorting
        minResolution: root.minResolution

        onImageUrlReceived: function(imageUrl) {
            root.currentImageSource = imageUrl
        }

        onErrorOccurred: function(errorMessage) {
            root.statusMessage = errorMessage
            root.isLoading = false
        }

        onFetchStarted: {
            root.isLoading = true
            root.statusMessage = "Fetching..."
        }
    }

    // Debounce timer to prevent rapid API calls
    Timer {
        id: refreshTimer
        interval: 500
        repeat: false
        onTriggered: fetchFromWallhaven()
    }

    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
    }

    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: root.currentImageSource
        fillMode: root.fillModeValue
        smooth: false 
        asynchronous: true
        cache: true
        z: 1

        onStatusChanged: {
            if (status === Image.Ready) {
                root.isLoading = false
                root.statusMessage = ""
            } else if (status === Image.Error) {
                root.isLoading = false
                root.statusMessage = "Image Load Error"
            }
        }
    }

    // === Feature: Click to Reset ===
    // If it gets stuck loading, clicking the background resets it
    MouseArea {
        anchors.fill: parent
        z: 3
        enabled: root.isLoading
        onClicked: {
            root.isLoading = false
            root.statusMessage = ""
            refreshTimer.stop()
        }
    }

    // Status Indicator
    Rectangle {
        anchors.centerIn: parent
        width: Math.max(statusText.implicitWidth + 40, 150)
        height: statusText.implicitHeight + 30
        radius: 8
        color: "#cc2d2d44"
        visible: root.isLoading || root.statusMessage !== ""
        z: 4

        Column {
            anchors.centerIn: parent
            spacing: 5
            Text {
                id: statusText
                text: root.statusMessage !== "" ? root.statusMessage : "Loading..."
                color: "white"
                font.pixelSize: 14
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }

    function fetchFromWallhaven() {
        wallhavenApi.fetch()
    }

    // Configuration change listeners - all trigger the debounce timer
    onRefreshTriggerChanged: refreshTimer.restart()
    onSearchQueryChanged: refreshTimer.restart()
    onCategoriesChanged: refreshTimer.restart()
    onPurityChanged: refreshTimer.restart()
    onSortingChanged: refreshTimer.restart()

    // Fetch initial wallpaper on startup
    Component.onCompleted: refreshTimer.restart()
}