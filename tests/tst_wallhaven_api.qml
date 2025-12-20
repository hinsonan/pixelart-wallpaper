import QtQuick
import QtTest

TestCase {
    name: "WallhavenAPITests"

    Component {
        id: apiComponent
        QtObject {
            function buildApiUrl(query, cats, pur, sort, resolution) {
                var url = "https://wallhaven.cc/api/v1/search?"
                url += "q=" + encodeURIComponent(query)
                url += "&categories=" + cats
                url += "&purity=" + pur
                url += "&sorting=" + sort
                url += "&atleast=" + resolution
                return url
            }
        }
    }

    // Test 1: Basic URL construction with default parameters
    function test_build_url_with_defaults() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("pixel art", "110", "100", "random", "1920x1080")

        verify(url.includes("https://wallhaven.cc/api/v1/search?"))
        verify(url.includes("q=pixel%20art"))
        verify(url.includes("categories=110"))
        verify(url.includes("purity=100"))
        verify(url.includes("sorting=random"))
        verify(url.includes("atleast=1920x1080"))
    }

    // Test 2: Category parameter - General only (100)
    function test_categories_general_only() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "100", "100", "random", "1920x1080")

        verify(url.includes("categories=100"))
        verify(!url.includes("categories=110"))
        verify(!url.includes("categories=111"))
    }

    // Test 3: Category parameter - Anime only (010)
    function test_categories_anime_only() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "010", "100", "random", "1920x1080")

        verify(url.includes("categories=010"))
    }

    // Test 4: Category parameter - People only (001)
    function test_categories_people_only() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "001", "100", "random", "1920x1080")

        verify(url.includes("categories=001"))
    }

    // Test 5: Category parameter - General + Anime (110)
    function test_categories_general_and_anime() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "random", "1920x1080")

        verify(url.includes("categories=110"))
    }

    // Test 6: Category parameter - All categories (111)
    function test_categories_all() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "111", "100", "random", "1920x1080")

        verify(url.includes("categories=111"))
    }

    // Test 7: Purity parameter - SFW only (100)
    function test_purity_sfw_only() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "random", "1920x1080")

        verify(url.includes("purity=100"))
    }

    // Test 8: Purity parameter - Sketchy (010)
    function test_purity_sketchy() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "010", "random", "1920x1080")

        verify(url.includes("purity=010"))
    }

    // Test 9: Purity parameter - SFW + Sketchy (110)
    function test_purity_sfw_and_sketchy() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "110", "random", "1920x1080")

        verify(url.includes("purity=110"))
    }

    // Test 10: Search query encoding - spaces
    function test_query_encoding_spaces() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("pixel art wallpaper", "110", "100", "random", "1920x1080")

        verify(url.includes("q=pixel%20art%20wallpaper"))
    }

    // Test 11: Search query encoding - special characters
    function test_query_encoding_special_chars() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test&query=value", "110", "100", "random", "1920x1080")

        verify(url.includes("q=test%26query%3Dvalue"))
    }

    // Test 12: Different sorting options
    function test_sorting_toplist() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "toplist", "1920x1080")

        verify(url.includes("sorting=toplist"))
    }

    function test_sorting_date_added() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "date_added", "1920x1080")

        verify(url.includes("sorting=date_added"))
    }

    // Test 13: Different resolution constraints
    function test_resolution_4k() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "random", "3840x2160")

        verify(url.includes("atleast=3840x2160"))
    }

    function test_resolution_hd() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("test", "110", "100", "random", "1280x720")

        verify(url.includes("atleast=1280x720"))
    }

    // Test 14: Complete URL format validation
    function test_url_format_is_complete() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("pixel art", "110", "100", "random", "1920x1080")

        // Should have all 5 parameters
        var paramCount = 0
        if (url.includes("q=")) paramCount++
        if (url.includes("categories=")) paramCount++
        if (url.includes("purity=")) paramCount++
        if (url.includes("sorting=")) paramCount++
        if (url.includes("atleast=")) paramCount++

        compare(paramCount, 5, "URL should contain all 5 query parameters")
    }

    // Test 15: Empty query handling
    function test_empty_query() {
        var api = createTemporaryObject(apiComponent, null)
        var url = api.buildApiUrl("", "110", "100", "random", "1920x1080")

        verify(url.includes("q="))
        verify(url.includes("categories=110"))
    }
}
