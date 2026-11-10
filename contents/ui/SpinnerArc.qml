import QtQuick
import QtQuick.Shapes

// Flowmodoro focus indicator for the popup: a ring segment that rotates while
// it grows and shrinks, like an indeterminate progress spinner. Freezes while paused.
Item {
    id: spinner
    property color color: "white"
    property real lineWidth: 10
    property real arcR: Math.min(width, height) / 2 - lineWidth
    property bool active: false
    property bool running: false
    property real sweep: 45

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.samples: 4
        ShapePath {
            strokeWidth: spinner.lineWidth
            strokeColor: spinner.color
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathAngleArc {
                centerX: spinner.width / 2; centerY: spinner.height / 2
                radiusX: spinner.arcR; radiusY: spinner.arcR
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
