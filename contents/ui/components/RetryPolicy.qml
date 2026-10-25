/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Retry backoff policy for the Pixel Art Wallpaper plugin.
*/

import QtQuick

QtObject {
    id: policy

    // First retry delay (ms) and upper bound.
    property int baseDelay: 2000
    property int maxDelay: 30000

    /**
     * Delay for the given retry attempt (1-based).
     * 1 -> baseDelay, 2 -> 2x, 3 -> 4x ... capped at maxDelay.
     */
    function delayFor(attempt) {
        if (attempt <= 1) {
            return baseDelay
        }
        var delay = baseDelay * Math.pow(2, attempt - 1)
        return Math.min(maxDelay, delay)
    }

    /**
     * True when another retry should be scheduled.
     * maxAttempts <= 0 means "retry forever".
     */
    function shouldRetry(attempt, maxAttempts) {
        return maxAttempts <= 0 || attempt < maxAttempts
    }
}
