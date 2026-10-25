/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Tests for the persistent wallpaper state component.

    The file locations are overridden so the tests never touch the real
    ~/.config or $XDG_RUNTIME_DIR stores.
*/

import QtQuick
import QtTest
import QtCore
import "../contents/ui/components"

TestCase {
    name: "WallpaperStateTests"

    readonly property string tempDir: StandardPaths.writableLocation(StandardPaths.TempLocation)

    Component {
        id: stateComponent
        WallpaperState {
            stateLocation: tempDir + "/tst-pixelart-wallpaper-state.conf"
            sessionLocation: tempDir + "/tst-pixelart-wallpaper-session.conf"
        }
    }

    property var state: null

    function init() {
        state = createTemporaryObject(stateComponent, null)
        verify(state !== null)
        state.clear()
        state.clearSession()
    }

    function test_default_locations_are_file_urls() {
        var probe = createTemporaryObject(defaultsComponent, null)
        verify(probe !== null)
        verify(probe.stateLocation.startsWith("file://"), "state location: " + probe.stateLocation)
        verify(probe.sessionLocation.startsWith("file://"), "session location: " + probe.sessionLocation)
        verify(probe.stateLocation.endsWith(".conf"))
        verify(probe.sessionLocation.endsWith(".conf"))
    }

    Component {
        id: defaultsComponent
        WallpaperState {}
    }

    function test_save_and_restore() {
        compare(state.lastImageUrl, "")

        state.save("https://w.wallhaven.cc/full/43/wallhaven-4315k3.png",
                   "https://th.wallhaven.cc/lg/43/4315k3.jpg")

        compare(state.lastImageUrl, "https://w.wallhaven.cc/full/43/wallhaven-4315k3.png")
        compare(state.lastThumbUrl, "https://th.wallhaven.cc/lg/43/4315k3.jpg")
    }

    function test_save_without_thumb_clears_thumb() {
        state.save("https://example.com/a.png", "https://example.com/a-thumb.jpg")
        state.save("https://example.com/b.png", "")

        compare(state.lastThumbUrl, "")
    }

    function test_clear_removes_url() {
        state.save("https://example.com/a.png", "")
        state.clear()

        compare(state.lastImageUrl, "")
        compare(state.lastThumbUrl, "")
    }

    function test_session_marker() {
        verify(state.isNewSession(), "an empty marker means a fresh login session")

        state.markSessionStarted()
        verify(!state.isNewSession(), "the marker must survive a re-created wallpaper item")

        state.clearSession()
        verify(state.isNewSession())
    }
}
