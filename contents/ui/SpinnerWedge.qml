import QtQuick
import QtQuick.Shapes

// Flowmodoro focus indicator: a pie wedge that rotates while it grows and
// shrinks, like an indeterminate progress spinner. Freezes while paused.
Item {
    id: spinner
    property color color: "white"
    property real wedgeR: Math.min(width, height) / 2
    property bool active: false     // a session is in progress (running or paused)
    property bool running: false    // currently running (not paused)
    property real sweep: 45

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        ShapePath {
            strokeWidth: -1
            fillColor: spinner.color
            startX: spinner.width / 2; startY: spinner.height / 2
            PathLine { x: spinner.width / 2; y: spinner.height / 2 - spinner.wedgeR }
            PathAngleArc {
                moveToStart: false
                centerX: spinner.width / 2; centerY: spinner.height / 2
                radiusX: spinner.wedgeR; radiusY: spinner.wedgeR
                startAngle: -90
                sweepAngle: spinner.sweep
            }
        }
    }

    RotationAnimator on rotation {
        from: 0; to: 360
        duration: 1800
        loops: Animation.Infinite
        running: spinner.active
        paused: !spinner.running
    }

    SequentialAnimation on sweep {
        loops: Animation.Infinite
        running: spinner.active
        paused: !spinner.running
        NumberAnimation { to: 260; duration: 1100; easing.type: Easing.InOutQuad }
        NumberAnimation { to: 45; duration: 1100; easing.type: Easing.InOutQuad }
    }
}
