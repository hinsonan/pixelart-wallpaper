/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Persistent wallpaper state for the Pixel Art Wallpaper plugin.

    Two stores are used:

    * ~/.config/com.github.hinsonan.pixelart.conf
      The last successfully displayed image (URL + thumbnail). Survives
      logins, so the desktop is never blank while a new image is fetched.

    * $XDG_RUNTIME_DIR/pixelart-wallpaper-session.conf
      A marker that only exists for the current login session (systemd
      removes the runtime directory on logout). It lets the plugin tell
      "fresh login, pick a new wallpaper" apart from "Plasma re-created
      the wallpaper item" (virtual desktop switch, activity switch, ...).

    The QtCore Settings type (Qt 6.5+) is used instead of the deprecated
    Qt.labs.settings one. Its "location" property is a URL, which pairs
    nicely with StandardPaths.writableLocation() (also a URL).

    NOTE: this component must be an Item, not a QtObject: QtObject has no
    default "data" property and therefore cannot contain child objects.
*/

import QtQuick
import QtCore

Item {
    id: state

    visible: false
    width: 0
    height: 0

    // Overridable in tests so they never touch the real configuration.
    property string stateLocation: StandardPaths.writableLocation(StandardPaths.ConfigLocation)
                                    + "/com.github.hinsonan.pixelart.conf"
    property string sessionLocation: StandardPaths.writableLocation(StandardPaths.RuntimeLocation)
                                      + "/pixelart-wallpaper-session.conf"

    readonly property string lastImageUrl: store.lastImageUrl
    readonly property string lastThumbUrl: store.lastThumbUrl

    Settings {
        id: store
        location: state.stateLocation
        category: "Wallpaper"
        property string lastImageUrl: ""
        property string lastThumbUrl: ""
    }

    Settings {
        id: session
        location: state.sessionLocation
        category: "Wallpaper"
        property string startedAt: ""
    }

    /** True when no wallpaper has been fetched during this login session. */
    function isNewSession() {
        return session.startedAt === ""
    }

    function markSessionStarted() {
        session.startedAt = "" + Date.now()
        session.sync()
    }

    function clearSession() {
        session.startedAt = ""
        session.sync()
    }

    /** Remember the wallpaper that is actually on screen. */
    function save(url, thumbUrl) {
        store.lastImageUrl = url || ""
        store.lastThumbUrl = thumbUrl || ""
        store.sync()
    }

    function clear() {
        save("", "")
    }
}
