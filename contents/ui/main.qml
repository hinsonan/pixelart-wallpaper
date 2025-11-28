import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import org.kde.plasma.plasmoid

WallpaperItem {
    id: root
    
    anchors.fill: parent
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    // Config Properties
    readonly property string sourceType: (configuration && configuration.SourceType) ? configuration.SourceType : "api"
    readonly property string localFolderPath: (configuration && configuration.LocalFolderPath) ? configuration.LocalFolderPath : ""
    readonly property string searchQuery: (configuration && configuration.SearchQuery) ? configuration.SearchQuery : "pixel art"
    readonly property string categories: (configuration && configuration.Categories) ? configuration.Categories : "110"
    readonly property string purity: (configuration && configuration.Purity) ? configuration.Purity : "100"
    readonly property string sorting: (configuration && configuration.Sorting) ? configuration.Sorting : "random"
    readonly property string minResolution: (configuration && configuration.MinResolution) ? configuration.MinResolution : "1920x1080"
    readonly property int fillModeValue: (configuration && configuration.FillMode !== undefined) ? configuration.FillMode : 2
    readonly property int refreshTrigger: (configuration && configuration.RefreshTrigger) ? configuration.RefreshTrigger : 0
    
    // State properties
    property var localImageList: []
    property int localImageIndex: 0
    property string currentImageSource: ""
    property bool isLoading: false
    property string statusMessage: ""

    // === FIX: Startup Timer ===
    // This handles both the "Debounce" (preventing rapid clicks)
    // AND the "Startup Race Condition" (preventing double-loading).
    Timer {
        id: refreshTimer
        interval: 500 // Wait 500ms before fetching
        repeat: false
        onTriggered: {
            if (root.sourceType === "local") {
                getNextLocalWallpaper()
            } else {
                fetchFromWallhaven()
            }
        }
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

    // Local Folder Logic
    FolderListModel {
        id: folderModel
        folder: root.sourceType === "local" && root.localFolderPath !== "" ? root.localFolderPath : ""
        nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp"]
        showDirs: false
        sortField: FolderListModel.Unsorted
        onStatusChanged: {
            if (status === FolderListModel.Ready) root.buildLocalImageList()
        }
    }

    function buildLocalImageList() {
        localImageList = []
        for (var i = 0; i < folderModel.count; i++) {
            localImageList.push(folderModel.get(i, "fileURL"))
        }
        if (localImageList.length > 0 && currentImageSource === "") refreshTimer.restart()
    }

    function getNextLocalWallpaper() {
        if (localImageList.length === 0) { 
            root.statusMessage = "No images"
            root.isLoading = false
            return 
        }

        var newIndex = Math.floor(Math.random() * localImageList.length)
        if (localImageList.length > 1) {
            while (newIndex === localImageIndex) {
                newIndex = Math.floor(Math.random() * localImageList.length)
            }
        }

        localImageIndex = newIndex
        currentImageSource = localImageList[localImageIndex]
        isLoading = true
    }

    function fetchFromWallhaven() {
        isLoading = true
        statusMessage = "Fetching..."

        var url = "https://wallhaven.cc/api/v1/search?"
        url += "q=" + encodeURIComponent(root.searchQuery)
        url += "&categories=" + root.categories
        url += "&purity=" + root.purity
        url += "&sorting=" + root.sorting
        url += "&atleast=" + root.minResolution

        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 15000 
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.data && response.data.length > 0) {
                            var idx = Math.floor(Math.random() * response.data.length)
                            root.currentImageSource = response.data[idx].path
                        } else {
                            root.statusMessage = "No results"
                            root.isLoading = false
                        }
                    } catch (e) {
                        root.statusMessage = "Parse error"
                        root.isLoading = false
                    }
                } else {
                    root.statusMessage = "API Error: " + xhr.status
                    root.isLoading = false
                }
            }
        }
        
        xhr.ontimeout = function() { 
            root.statusMessage = "Timeout"
            root.isLoading = false 
        }
        
        xhr.send()
    }

    // === Listeners ===
    // All changes now go through the SAME timer.
    // This "swallows" multiple rapid events into a single fetch.

    onRefreshTriggerChanged: refreshTimer.restart()
    
    onSearchQueryChanged: refreshTimer.restart()
    onCategoriesChanged: refreshTimer.restart()
    onPurityChanged: refreshTimer.restart()
    onSortingChanged: refreshTimer.restart()

    onSourceTypeChanged: { 
        if (root.sourceType === "api") refreshTimer.restart()
        else if (folderModel.status === FolderListModel.Ready) buildLocalImageList()
    }
    
    // === FIX IMPLEMENTATION ===
    // Instead of calling the fetch directly, we start the timer.
    // If config loads 10ms later, it restarts the timer.
    // Result: Only 1 fetch happens after 500ms.
    Component.onCompleted: {
        refreshTimer.restart()
    }
}