import QtQuick
import org.kde.notification

// Flowmodoro "take a break?" prompt: a notification with action buttons.
// Isolated in its own file so a failed import can't break the widget.
Item {
    id: prompt
    signal takeBreakRequested()

    function show(title, text) {
        n.title = title;
        n.text = text;
        n.sendEvent();
    }

    Notification {
        id: n
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "chronometer"
        actions: [
            NotificationAction {
                label: i18n("Take break")
                onActivated: prompt.takeBreakRequested()
            },
            NotificationAction {
                label: i18n("Keep going")
            }
        ]
    }
}
