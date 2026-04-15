import QtQuick

QtObject {
    id: api

    // Configuration properties
    property string searchQuery: "pixel art"
    property string categories: "110"
    property string purity: "100"
    property string sorting: "random"
    property string minResolution: "1920x1080"

    // Signals
    signal imageUrlReceived(string imageUrl)
    signal errorOccurred(string errorMessage)
    signal fetchStarted()

    function setHeaderSafe(xhr, key, value) {
        try {
            xhr.setRequestHeader(key, value)
        } catch (e) {
            // Some headers may be blocked depending on Qt runtime.
        }
    }

    // Expose the URL building logic for testing
    function buildApiUrl(query, cats, pur, sort, resolution) {
        var url = "https://wallhaven.cc/api/v1/search?"
        url += "q=" + encodeURIComponent(query)
        url += "&categories=" + cats
        url += "&purity=" + pur
        url += "&sorting=" + sort
        url += "&atleast=" + resolution
        return url
    }

    // Build URL with current properties
    function buildCurrentUrl() {
        return buildApiUrl(searchQuery, categories, purity, sorting, minResolution)
    }

    // Perform the actual API fetch
    function fetch() {
        fetchStarted()

        var url = buildCurrentUrl()
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.timeout = 15000
        setHeaderSafe(xhr, "Accept", "application/json")
        setHeaderSafe(xhr, "Accept-Language", "en-US,en;q=0.9")
        setHeaderSafe(xhr, "User-Agent", "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36")

        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText)
                        if (response.data && response.data.length > 0) {
                            var idx = Math.floor(Math.random() * response.data.length)
                            imageUrlReceived(response.data[idx].path)
                        } else {
                            errorOccurred("No results")
                        }
                    } catch (e) {
                        errorOccurred("Parse error: " + e.message)
                    }
                } else if (xhr.status === 403) {
                    errorOccurred("API Error: 403 (forbidden). Wallhaven rejected the request.")
                } else {
                    errorOccurred("API Error: " + xhr.status + (xhr.statusText ? " (" + xhr.statusText + ")" : ""))
                }
            }
        }

        xhr.ontimeout = function() {
            errorOccurred("Timeout")
        }

        xhr.send()
    }
}
