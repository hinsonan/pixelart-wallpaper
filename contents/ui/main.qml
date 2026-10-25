/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Pixel Art Wallpaper plugin - main item.

    Lifecycle contract (see README):
    * A new random wallpaper is fetched once per login session.
    * Locking the screen, suspending the machine or switching virtual
      desktops keeps the current wallpaper.
    * The last wallpaper is persisted and restored immediately, so the
      desktop is never blank while a request is in flight.
    * Every network/image failure is retried with exponential backoff.
*/

import QtQuick
import org.kde.plasma.plasmoid
import "components"

WallpaperItem {
    id: root

    anchors.fill: parent
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0

    // ------------------------------------------------------------------ config
    readonly property string searchQuery: (configuration && configuration.SearchQuery) ? configuration.SearchQuery : "pixel art"
    readonly property string categories: (configuration && configuration.Categories) ? configuration.Categories : "110"
    readonly property string purity: (configuration && configuration.Purity) ? configuration.Purity : "100"
    readonly property string sorting: (configuration && configuration.Sorting) ? configuration.Sorting : "random"
    readonly property string minResolution: (configuration && configuration.MinResolution) ? configuration.MinResolution : "1920x1080"
    readonly property int fillModeValue: (configuration && configuration.FillMode !== undefined) ? configuration.FillMode : 2
    readonly property int refreshTrigger: (configuration && configuration.RefreshTrigger) ? configuration.RefreshTrigger : 0
    readonly property bool newWallpaperOnLogin: (configuration && configuration.NewWallpaperOnLogin !== undefined) ? configuration.NewWallpaperOnLogin : true

    // ------------------------------------------------------------------- state
    property string currentImageSource: ""
    property string currentThumbSource: ""
    property string placeholderSource: ""
    property string pendingImageSource: ""
    property string pendingThumbSource: ""

    property bool isLoading: false
    property string statusMessage: ""

    property int apiRetryAttempt: 0
    property int probeRetryAttempt: 0
    property int visibleRetryAttempt: 0

    property bool initialized: false

    readonly property bool hasWallpaper: currentImageSource !== ""
    readonly property bool showStatus: statusMessage !== "" || (isLoading && !hasWallpaper)

    WallpaperState {
        id: state
    }

    RetryPolicy {
        id: retryPolicy
    }

    WallhavenAPI {
        id: wallhavenApi
        searchQuery: root.searchQuery
        categories: root.categories
        purity: root.purity
        sorting: root.sorting
        minResolution: root.minResolution

        onFetchStarted: {
            root.isLoading = true
        }

        onImageUrlReceived: function(imageUrl, thumbUrl) {
            root.verifyCandidate(imageUrl, thumbUrl)
        }

        onErrorOccurred: function(message) {
            root.handleApiError(message)
        }
    }

    // Background while the very first image is being fetched.
    Rectangle {
        anchors.fill: parent
        color: "#1a1a2e"
        z: 0
    }

    // Low resolution placeholder, only visible until the full image is ready.
    // Its source is set only when there is nothing on screen, so browsing
    // wallpapers never downloads a thumbnail that is not needed.
    Image {
        id: placeholderImage
        anchors.fill: parent
        source: root.placeholderSource
        fillMode: root.fillModeValue
        smooth: false
        asynchronous: true
        cache: true
        z: 1
        visible: source !== "" && wallpaperImage.status !== Image.Ready
    }

    // The wallpaper itself.
    Image {
        id: wallpaperImage
        anchors.fill: parent
        fillMode: root.fillModeValue
        smooth: false
        asynchronous: true
        cache: true
        z: 2

        onStatusChanged: {
            if (status === Image.Ready) {
                root.isLoading = false
                root.visibleRetryAttempt = 0
                root.clearStatus()
            } else if (status === Image.Error && source !== "") {
                root.handleVisibleImageError()
            }
        }
    }

    // Hidden probe: a candidate is only promoted once it has fully loaded,
    // so a broken URL can never blank the desktop.
    //
    // The probe mirrors the visible image's geometry, fillMode and flags on
    // purpose: Qt keys its image cache on the requested size, so a probe with
    // different geometry/fillMode would download the image a second time when
    // it gets promoted.
    Image {
        id: probeImage
        visible: false
        anchors.fill: parent
        fillMode: root.fillModeValue
        smooth: false
        asynchronous: true
        cache: true

        onStatusChanged: {
            if (source === "") {
                return
            }
            if (status === Image.Ready) {
                root.promoteCandidate()
            } else if (status === Image.Error) {
                root.handleProbeError()
            }
        }
    }

    // ---------------------------------------------------------------- status UI
    Rectangle {
        anchors.centerIn: parent
        width: Math.max(statusText.implicitWidth + 40, 150)
        height: statusText.implicitHeight + 30
        radius: 8
        color: "#cc2d2d44"
        visible: root.showStatus
        z: 4

        Text {
            id: statusText
            anchors.centerIn: parent
            text: root.statusMessage !== "" ? root.statusMessage : "Loading..."
            color: "white"
            font.pixelSize: 14
        }
    }

    // Click the status badge to dismiss it and retry immediately.
    MouseArea {
        anchors.fill: parent
        z: 3
        enabled: root.showStatus
        onClicked: {
            root.clearStatus()
            root.validate()
        }
    }

    // ------------------------------------------------------------------ timers
    Timer {
        id: configDebounce
        interval: 500
        repeat: false
        onTriggered: root.requestNewWallpaper()
    }

    Timer {
        id: apiRetryTimer
        repeat: false
        onTriggered: root.startFetch()
    }

    Timer {
        id: probeRetryTimer
        repeat: false
        onTriggered: root.reloadProbe()
    }

    Timer {
        id: visibleRetryTimer
        repeat: false
        onTriggered: root.reloadVisible()
    }

    Timer {
        id: statusTimer
        interval: 15000
        repeat: false
        onTriggered: root.statusMessage = ""
    }

    Timer {
        id: watchdogTimer
        interval: 30000
        repeat: true
        running: true
        onTriggered: root.validate()
    }

    // ----------------------------------------------------------------- helpers
    function clearStatus() {
        statusTimer.stop()
        statusMessage = ""
    }

    function setStatus(message) {
        statusMessage = message
        if (message !== "") {
            statusTimer.restart()
        } else {
            statusTimer.stop()
        }
    }

    /** User action (refresh button, config change): reset the backoff. */
    function requestNewWallpaper() {
        if (!initialized || wallhavenApi.isFetching) {
            return
        }
        apiRetryTimer.stop()
        apiRetryAttempt = 0
        startFetch()
    }

    function startFetch() {
        if (!initialized || wallhavenApi.isFetching) {
            return
        }
        isLoading = true
        // Never hand back the image that is already on screen.
        wallhavenApi.fetch(currentImageSource)
    }

    function handleApiError(message) {
        isLoading = false
        setStatus(message)

        // Without a wallpaper we must keep trying. With one on screen the
        // background refresh is best effort, so give up after a few tries.
        var limit = hasWallpaper ? 5 : 0
        if (retryPolicy.shouldRetry(apiRetryAttempt, limit)) {
            apiRetryAttempt += 1
            apiRetryTimer.interval = retryPolicy.delayFor(apiRetryAttempt)
            apiRetryTimer.restart()
        }
    }

    function verifyCandidate(imageUrl, thumbUrl) {
        if (!imageUrl) {
            handleApiError("Empty image URL")
            return
        }
        pendingImageSource = imageUrl
        pendingThumbSource = thumbUrl || ""

        // Nothing on screen yet: show the (small, fast) thumbnail while the
        // full image is being verified.
        if (!hasWallpaper && pendingThumbSource !== "") {
            placeholderSource = pendingThumbSource
        }

        probeRetryAttempt = 0
        reloadProbe()
    }

    function reloadProbe() {
        if (pendingImageSource === "") {
            return
        }
        isLoading = true
        probeImage.source = ""
        probeImage.source = pendingImageSource
    }

    function promoteCandidate() {
        if (pendingImageSource === "") {
            return
        }

        currentImageSource = pendingImageSource
        currentThumbSource = pendingThumbSource
        state.save(currentImageSource, currentThumbSource)

        pendingImageSource = ""
        pendingThumbSource = ""
        apiRetryAttempt = 0
        probeRetryAttempt = 0
        isLoading = false
        clearStatus()

        wallpaperImage.source = currentImageSource
    }

    function handleProbeError() {
        isLoading = false

        if (retryPolicy.shouldRetry(probeRetryAttempt, 3)) {
            probeRetryAttempt += 1
            setStatus("Could not load the new wallpaper, retrying...")
            probeRetryTimer.interval = retryPolicy.delayFor(probeRetryAttempt)
            probeRetryTimer.restart()
            return
        }

        // This candidate looks permanently broken. Only fetch another one if
        // there is nothing on screen; otherwise keep the current wallpaper.
        var failedUrl = pendingImageSource
        pendingImageSource = ""
        pendingThumbSource = ""
        setStatus(hasWallpaper ? "" : "Could not load a wallpaper, retrying...")

        if (!hasWallpaper && !wallhavenApi.isFetching) {
            apiRetryAttempt = 0
            isLoading = true
            wallhavenApi.fetch(failedUrl)
        }
    }

    function handleVisibleImageError() {
        isLoading = false
        visibleRetryAttempt += 1
        setStatus("Wallpaper failed to load, retrying...")

        // Repeated failures usually mean the image URL itself is dead.
        if (visibleRetryAttempt >= 3 && !wallhavenApi.isFetching) {
            apiRetryAttempt = 0
            isLoading = true
            wallhavenApi.fetch(currentImageSource)
        }

        visibleRetryTimer.interval = retryPolicy.delayFor(visibleRetryAttempt)
        visibleRetryTimer.restart()
    }

    function reloadVisible() {
        if (currentImageSource === "") {
            return
        }
        wallpaperImage.source = ""
        wallpaperImage.source = currentImageSource
    }

    function restoreSavedWallpaper() {
        if (state.lastImageUrl === "") {
            return false
        }
        currentImageSource = state.lastImageUrl
        currentThumbSource = state.lastThumbUrl
        placeholderSource = state.lastThumbUrl
        wallpaperImage.source = currentImageSource
        return true
    }

    /** Called by the watchdog and after resuming from sleep. */
    function validate() {
        if (currentImageSource === "") {
            if (restoreSavedWallpaper()) {
                return
            }
            if (!wallhavenApi.isFetching && !apiRetryTimer.running) {
                requestNewWallpaper()
            }
            return
        }

        if (wallpaperImage.status === Image.Error && !visibleRetryTimer.running) {
            reloadVisible()
        }
    }

    // ---------------------------------------------------------------- startup
    Component.onCompleted: {
        initialized = true

        var restored = restoreSavedWallpaper()
        var freshSession = state.isNewSession()
        if (freshSession) {
            state.markSessionStarted()
        }

        if (freshSession && newWallpaperOnLogin) {
            // Keep the restored wallpaper on screen until the new one is ready.
            requestNewWallpaper()
        } else if (!restored) {
            requestNewWallpaper()
        }
    }

    // ------------------------------------------------------- config changes
    onRefreshTriggerChanged: if (initialized) requestNewWallpaper()
    onSearchQueryChanged: if (initialized) configDebounce.restart()
    onCategoriesChanged: if (initialized) configDebounce.restart()
    onPurityChanged: if (initialized) configDebounce.restart()
    onSortingChanged: if (initialized) configDebounce.restart()
    onMinResolutionChanged: if (initialized) configDebounce.restart()

    // ------------------------------------------------------ resume from sleep
    Connections {
        target: Qt.application
        function onStateChanged() {
            if (Qt.application.state === Qt.ApplicationActive) {
                root.validate()
            }
        }
    }
}
