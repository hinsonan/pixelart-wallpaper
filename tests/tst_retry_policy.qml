/*
    SPDX-License-Identifier: GPL-3.0-or-later
    Tests for the retry backoff policy.
*/

import QtQuick
import QtTest
import "../contents/ui/components"

TestCase {
    name: "RetryPolicyTests"

    RetryPolicy {
        id: policy
    }

    function test_first_delay_uses_base() {
        compare(policy.delayFor(1), 2000)
    }

    function test_delay_doubles() {
        compare(policy.delayFor(2), 4000)
        compare(policy.delayFor(3), 8000)
        compare(policy.delayFor(4), 16000)
    }

    function test_delay_is_capped() {
        compare(policy.delayFor(5), 30000)
        compare(policy.delayFor(50), 30000)
    }

    function test_should_retry_unlimited() {
        verify(policy.shouldRetry(0, 0))
        verify(policy.shouldRetry(1000, 0))
    }

    function test_should_retry_limited() {
        verify(policy.shouldRetry(0, 3))
        verify(policy.shouldRetry(2, 3))
        verify(!policy.shouldRetry(3, 3))
        verify(!policy.shouldRetry(4, 3))
    }
}
