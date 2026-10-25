/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Tests for the real WallhavenAPI component (not a copy of its logic).
*/

import QtQuick
import QtTest
import "../contents/ui/components"

TestCase {
    name: "WallhavenAPITests"

    Component {
        id: apiComponent
        WallhavenAPI {}
    }

    property var api: null

    function init() {
        api = createTemporaryObject(apiComponent, null)
        verify(api !== null)
    }

    // ---------------------------------------------------------------- URL building

    function test_build_url_with_defaults() {
        var url = api.buildApiUrl("pixel art", "110", "100", "random", "1920x1080")

        verify(url.includes("https://wallhaven.cc/api/v1/search?"))
        verify(url.includes("q=pixel%20art"))
        verify(url.includes("categories=110"))
        verify(url.includes("purity=100"))
        verify(url.includes("sorting=random"))
        verify(url.includes("atleast=1920x1080"))
    }

    function test_categories_general_only() {
        var url = api.buildApiUrl("test", "100", "100", "random", "1920x1080")

        verify(url.includes("categories=100"))
        verify(!url.includes("categories=110"))
        verify(!url.includes("categories=111"))
    }

    function test_categories_anime_only() {
        var url = api.buildApiUrl("test", "010", "100", "random", "1920x1080")
        verify(url.includes("categories=010"))
    }

    function test_categories_people_only() {
        var url = api.buildApiUrl("test", "001", "100", "random", "1920x1080")
        verify(url.includes("categories=001"))
    }

    function test_categories_general_and_anime() {
        var url = api.buildApiUrl("test", "110", "100", "random", "1920x1080")
        verify(url.includes("categories=110"))
    }

    function test_categories_all() {
        var url = api.buildApiUrl("test", "111", "100", "random", "1920x1080")
        verify(url.includes("categories=111"))
    }

    function test_purity_sfw_only() {
        var url = api.buildApiUrl("test", "110", "100", "random", "1920x1080")
        verify(url.includes("purity=100"))
    }

    function test_purity_sketchy() {
        var url = api.buildApiUrl("test", "110", "010", "random", "1920x1080")
        verify(url.includes("purity=010"))
    }

    function test_purity_sfw_and_sketchy() {
        var url = api.buildApiUrl("test", "110", "110", "random", "1920x1080")
        verify(url.includes("purity=110"))
    }

    function test_query_encoding_spaces() {
        var url = api.buildApiUrl("pixel art wallpaper", "110", "100", "random", "1920x1080")
        verify(url.includes("q=pixel%20art%20wallpaper"))
    }

    function test_query_encoding_special_chars() {
        var url = api.buildApiUrl("test&query=value", "110", "100", "random", "1920x1080")
        verify(url.includes("q=test%26query%3Dvalue"))
    }

    function test_sorting_toplist() {
        var url = api.buildApiUrl("test", "110", "100", "toplist", "1920x1080")
        verify(url.includes("sorting=toplist"))
    }

    function test_sorting_date_added() {
        var url = api.buildApiUrl("test", "110", "100", "date_added", "1920x1080")
        verify(url.includes("sorting=date_added"))
    }

    function test_resolution_4k() {
        var url = api.buildApiUrl("test", "110", "100", "random", "3840x2160")
        verify(url.includes("atleast=3840x2160"))
    }

    function test_resolution_hd() {
        var url = api.buildApiUrl("test", "110", "100", "random", "1280x720")
        verify(url.includes("atleast=1280x720"))
    }

    function test_url_format_is_complete() {
        var url = api.buildApiUrl("pixel art", "110", "100", "random", "1920x1080")

        var paramCount = 0
        if (url.includes("q=")) paramCount++
        if (url.includes("categories=")) paramCount++
        if (url.includes("purity=")) paramCount++
        if (url.includes("sorting=")) paramCount++
        if (url.includes("atleast=")) paramCount++

        compare(paramCount, 5, "URL should contain all 5 query parameters")
    }

    function test_empty_query() {
        var url = api.buildApiUrl("", "110", "100", "random", "1920x1080")

        verify(url.includes("q="))
        verify(url.includes("categories=110"))
    }

    function test_build_current_url_uses_properties() {
        var saved = {
            query: api.searchQuery,
            categories: api.categories,
            purity: api.purity,
            sorting: api.sorting,
            resolution: api.minResolution
        }

        api.searchQuery = "8bit retro"
        api.categories = "111"
        api.purity = "100"
        api.sorting = "toplist"
        api.minResolution = "2560x1440"

        compare(api.buildCurrentUrl(), api.buildApiUrl("8bit retro", "111", "100", "toplist", "2560x1440"))

        api.searchQuery = saved.query
        api.categories = saved.categories
        api.purity = saved.purity
        api.sorting = saved.sorting
        api.minResolution = saved.resolution
    }

    // ------------------------------------------------------------- result picking

    function test_pick_result_returns_null_for_empty_list() {
        compare(api.pickResult([], ""), null)
        compare(api.pickResult(null, ""), null)
    }

    function test_pick_result_returns_only_entry() {
        var list = [{ path: "https://example.com/only.png" }]
        compare(api.pickResult(list, "").path, "https://example.com/only.png")
    }

    function test_pick_result_avoids_current_image() {
        var list = [
            { path: "https://example.com/a.png" },
            { path: "https://example.com/b.png" },
            { path: "https://example.com/c.png" }
        ]

        // Deterministic: the avoided entry is filtered out entirely, so every
        // pick must differ from it.
        for (var i = 0; i < 50; ++i) {
            var picked = api.pickResult(list, "https://example.com/a.png")
            verify(picked.path !== "https://example.com/a.png")
        }
    }

    function test_pick_result_falls_back_when_all_entries_avoided() {
        var list = [{ path: "https://example.com/a.png" }]
        compare(api.pickResult(list, "https://example.com/a.png").path, "https://example.com/a.png")
    }

    function test_no_request_in_flight_initially() {
        verify(!api.isFetching)
    }
}
