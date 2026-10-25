/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Wallhaven API client for the Pixel Art Wallpaper plugin.

    Request handling notes (verified against Qt 6.12):

    * The QML XMLHttpRequest has NO "timeout" property and NO "ontimeout"
      signal, so a real timeout is implemented here with a Timer + abort().
    * It also has no "onerror" signal. Network failures are reported through
      onreadystatechange with readyState === DONE and status === 0.
    * Only one request may be in flight. Starting a new fetch aborts the
      previous one, so a slow request can never pile up behind a user action.

    NOTE: this component is an Item (not a QtObject) because a QtObject
    cannot contain the Timer child object. It is never visible.
*/

import QtQuick

Item {
    id: api

    visible: false
    width: 0
    height: 0

    // --- Configuration -----------------------------------------------------
    property string searchQuery: "pixel art"
    property string categories: "110"
    property string purity: "100"
    property string sorting: "random"
    property string minResolution: "1920x1080"

    // Hard limit for one API request. Resuming from sleep often leaves the
    // network half-up; without this the request can hang for minutes.
    property int requestTimeout: 10000

    // --- Signals -----------------------------------------------------------
    signal imageUrlReceived(string imageUrl, string thumbUrl)
    signal errorOccurred(string errorMessage)
    signal fetchStarted()

    // --- Internal state ----------------------------------------------------
    property var _xhr: null

    readonly property bool isFetching: _xhr !== null

    // --- URL building (also used by the unit tests) ------------------------
    function setHeaderSafe(xhr, key, value) {
        try {
            xhr.setRequestHeader(key, value)
        } catch (e) {
            // Some headers may be blocked depending on the Qt runtime.
        }
    }

    function buildApiUrl(query, cats, pur, sort, resolution) {
        var url = "https://wallhaven.cc/api/v1/search?"
        url += "q=" + encodeURIComponent(query)
        url += "&categories=" + cats
        url += "&purity=" + pur
        url += "&sorting=" + sort
        url += "&atleast=" + resolution
        return url
    }

    function buildCurrentUrl() {
        return buildApiUrl(searchQuery, categories, purity, sorting, minResolution)
    }

    /**
     * Pick one entry from the API result list.
     * The currently displayed image is excluded when any alternative exists,
     * so a refresh always visibly changes the wallpaper.
     */
    function pickResult(list, avoidUrl) {
        if (!list || list.length === 0) {
            return null
        }

        var candidates = list
        if (avoidUrl) {
            var filtered = []
            for (var i = 0; i < list.length; ++i) {
                if (list[i] && list[i].path !== avoidUrl) {
                    filtered.push(list[i])
                }
            }
            if (filtered.length > 0) {
                candidates = filtered
            }
        }

        if (candidates.length === 0) {
            return null
        }
        return candidates[Math.floor(Math.random() * candidates.length)]
    }

    // --- Request lifecycle -------------------------------------------------
    function abort() {
        var xhr = _xhr
        _xhr = null
        timeoutTimer.stop()
        if (xhr) {
            try {
                xhr.abort()
            } catch (e) {
                // Already finished.
            }
        }
    }

    function fetch(avoidUrl) {
        abort()

        var xhr = new XMLHttpRequest()
        _xhr = xhr

        fetchStarted()
        timeoutTimer.restart()

        xhr.open("GET", buildCurrentUrl())
        setHeaderSafe(xhr, "Accept", "application/json")
        setHeaderSafe(xhr, "Accept-Language", "en-US,en;q=0.9")
        setHeaderSafe(xhr, "User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")

        xhr.onreadystatechange = function() {
            // Ignore responses of aborted or superseded requests.
            if (_xhr !== xhr) {
                return
            }
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return
            }

            _xhr = null
            timeoutTimer.stop()

            if (xhr.status !== 200) {
                if (xhr.status === 0) {
                    errorOccurred("Network error")
                } else if (xhr.status === 403) {
                    errorOccurred("Wallhaven rejected the request (403)")
                } else if (xhr.status === 429) {
                    errorOccurred("Rate limited by Wallhaven (429)")
                } else if (xhr.status === 404) {
                    errorOccurred("Wallhaven API not found (404)")
                } else {
                    errorOccurred("Wallhaven API error " + xhr.status
                                  + (xhr.statusText ? " (" + xhr.statusText + ")" : ""))
                }
                return
            }

            var parsed
            try {
                parsed = JSON.parse(xhr.responseText)
            } catch (e) {
                errorOccurred("Could not parse the API response")
                return
            }

            var list = parsed && parsed.data
            if (!list || list.length === 0) {
                errorOccurred("No results for this search")
                return
            }

            var picked = pickResult(list, avoidUrl || "")
            if (!picked || !picked.path) {
                errorOccurred("Invalid API response")
                return
            }

            var thumbUrl = (picked.thumbs && picked.thumbs.large) ? picked.thumbs.large : ""
            imageUrlReceived(picked.path, thumbUrl)
        }

        xhr.send()
    }

    Timer {
        id: timeoutTimer
        interval: api.requestTimeout
        repeat: false
        onTriggered: {
            if (api.isFetching) {
                api.abort()
                api.errorOccurred("Request timed out")
            }
        }
    }
}
