import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Shapes
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.notification

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration

    // ---------- state ----------
    property string mode: "timer"     // timer | pomodoro | flow
    property string phase: "focus"    // focus | short | long | break
    property bool running: false
    property double endTime: 0        // ms epoch (countdown)
    property double startTime: 0      // ms epoch (flow count-up)
    property int totalSecs: 600
    property int remainingSecs: 600
    property int elapsedSecs: 0
    property int completedFocus: 0
    property int timerSecs: 600       // last plain-timer duration
    property bool active: false       // a session has been started (running or paused)
    property real wheelAcc: 0
    property int lastTickVal: -1
    property int promptsSent: 0       // flowmodoro break suggestions already shown this session

    readonly property bool onBreak: (mode === "pomodoro" && phase !== "focus")
                                    || (mode === "flow" && phase === "break")
    readonly property color panelColor: (active && onBreak) ? Kirigami.Theme.disabledTextColor
                                                            : Kirigami.Theme.textColor

    readonly property bool countingUp: mode === "flow" && phase === "focus"
    readonly property int shownSecs: countingUp ? elapsedSecs : remainingSecs
    readonly property string display: fmt(shownSecs)

    readonly property real progress: {
        if (countingUp)
            return Math.min(1, elapsedSecs / (Math.max(1, cfg.focusMinutes) * 60));
        return totalSecs > 0 ? Math.min(1, remainingSecs / totalSecs) : 0;
    }

    readonly property color phaseColor: {
        if (mode === "timer") return Kirigami.Theme.highlightColor;
        if (phase === "focus") return Kirigami.Theme.negativeTextColor;
        if (phase === "long") return Kirigami.Theme.neutralTextColor;
        return Kirigami.Theme.positiveTextColor;
    }

    readonly property string phaseText: {
        if (mode === "timer") return i18n("Timer");
        if (mode === "pomodoro") {
            if (phase === "focus") return i18n("Focus");
            if (phase === "short") return i18n("Short break");
            return i18n("Long break");
        }
        return phase === "focus" ? i18n("Flow focus") : i18n("Break");
    }

    readonly property var presetList: {
        var out = [];
        var parts = String(cfg.presets).split(",");
        for (var i = 0; i < parts.length; i++) {
            var n = parseFloat(parts[i]);
            if (n > 0) out.push(n);
        }
        return out.length ? out : [5, 10, 25];
    }

    // ---------- helpers ----------
    function fmt(s) {
        s = Math.max(0, Math.floor(s));
        var h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60;
        var mm = (m < 10 ? "0" : "") + m, ss = (sec < 10 ? "0" : "") + sec;
        return h > 0 ? h + ":" + mm + ":" + ss : mm + ":" + ss;
    }

    function durationFor(p) {
        if (p === "short") return cfg.shortBreakMinutes * 60;
        if (p === "long") return cfg.longBreakMinutes * 60;
        return cfg.focusMinutes * 60;
    }

    function notify(title, text) {
        notif.title = title;
        notif.text = text;
        notif.sendEvent();
    }

    // ---------- core controls ----------
    function setCountdown(secs) {
        running = false;
        active = false;
        totalSecs = secs;
        remainingSecs = secs;
    }

    function start() {
        var fresh = !active;
        if (countingUp && elapsedSecs === 0) promptsSent = 0;
        if (countingUp) {
            startTime = Date.now() - elapsedSecs * 1000;
        } else {
            if (remainingSecs <= 0) remainingSecs = totalSecs;
            endTime = Date.now() + remainingSecs * 1000;
        }
        running = true;
        active = true;
        if (fresh) playAlert("start");
    }

    function pause() {
        if (update()) return;   // the phase just ended; finished() already settled the new state
        running = false;
    }

    // start from idle, pause when running, resume when paused (middle-click, context menu)
    function toggle() { running ? pause() : start(); }

    // back to an idle Flowmodoro focus phase
    function resetFlow() {
        phase = "focus";
        elapsedSecs = 0; totalSecs = 0; remainingSecs = 0;
    }

    function stop() {
        running = false;
        active = false;
        if (mode === "timer") {
            setCountdown(timerSecs);
        } else if (mode === "pomodoro") {
            phase = "focus";
            setCountdown(durationFor("focus"));
        } else {
            resetFlow();
        }
    }

    function setMode(m) {
        if (m !== "timer" && m !== "pomodoro" && m !== "flow") m = "timer";
        mode = m;
        cfg.lastMode = m;
        phase = "focus";
        elapsedSecs = 0;
        running = false;
        active = false;
        if (m === "timer") setCountdown(timerSecs);
        else if (m === "pomodoro") setCountdown(durationFor("focus"));
        else { totalSecs = 0; remainingSecs = 0; }
    }

    function applyPreset(minutes) {
        timerSecs = Math.round(minutes * 60);
        if (mode !== "timer") setMode("timer");
        setCountdown(timerSecs);
        start();
    }

    function breakSecsFor(e) {
        return Math.max(30, Math.round(e / Math.max(1, cfg.flowRatio)));
    }

    function playAlert(kind) {
        if (kind === "start") {
            if (cfg.startSoundEnabled && startSoundLoader.item)
                startSoundLoader.item.play(cfg.startSound, cfg.soundVolume);
            return;
        }
        if (!cfg.soundEnabled || !soundLoader.item) return;
        soundLoader.item.play(kind === "break" ? cfg.breakEndSound : cfg.focusEndSound,
                              cfg.soundVolume);
    }

    readonly property string tickUrl: Qt.resolvedUrl("../sounds/tick.wav").toString()

    function tickCheck(v) {
        if (v === lastTickVal) return;
        lastTickVal = v;
        if (cfg.tickEnabled && phase === "focus" && mode !== "timer" && tickLoader.item)
            tickLoader.item.play(tickUrl, cfg.tickVolume);
    }

    // scroll wheel: temporarily add/remove minutes on the current countdown
    function adjustTime(mins) {
        if (countingUp) return;
        var cur = running ? Math.max(0, Math.ceil((endTime - Date.now()) / 1000)) : remainingSecs;
        var rem = Math.min(86400, Math.max(1, cur + mins * 60));
        if (running) endTime = Date.now() + rem * 1000;
        totalSecs = active ? Math.max(rem, totalSecs + (rem - cur)) : rem;
        remainingSecs = rem;
    }
    function wheelStep(dy) {
        wheelAcc += dy;
        while (wheelAcc >= 120) { adjustTime(1); wheelAcc -= 120; }
        while (wheelAcc <= -120) { adjustTime(-1); wheelAcc += 120; }
    }

    function askForBreak() {
        playAlert("focus");
        var title = i18n("Time for a break?");
        var text = i18n("You've been focused for %1 minutes. Take a %2 break?",
                        Math.floor(elapsedSecs / 60), fmt(breakSecsFor(elapsedSecs)));
        if (promptLoader.item) promptLoader.item.show(title, text);
        else notify(title, text);
    }

    function takeBreak() {
        if (!(mode === "flow" && phase === "focus" && elapsedSecs > 0)) return;
        update();
        var b = breakSecsFor(elapsedSecs);
        phase = "break";
        setCountdown(b);
        start();
    }

    function finished() {
        running = false;
        active = false;
        if (mode === "timer") {
            playAlert("focus");
            notify(i18n("Timer finished"), fmt(totalSecs));
            setCountdown(timerSecs);
        } else if (mode === "pomodoro") {
            if (phase === "focus") {
                completedFocus++;
                playAlert("focus");
                var long = (completedFocus % Math.max(1, cfg.cyclesBeforeLong) === 0);
                phase = long ? "long" : "short";
                notify(i18n("Focus session complete"),
                       long ? i18n("Time for a long break.") : i18n("Time for a short break."));
            } else {
                phase = "focus";
                playAlert("break");
                notify(i18n("Break over"), i18n("Time to focus."));
            }
            setCountdown(durationFor(phase));
            if (cfg.autoStartNext) start();
        } else {
            resetFlow();
            playAlert("break");
            notify(i18n("Break over"), i18n("Ready for the next focus session."));
            if (cfg.autoStartNext) start();
        }
    }

    // returns true if this call ended the current phase
    function update() {
        if (!running) return false;
        var now = Date.now();
        if (countingUp) {
            elapsedSecs = Math.floor((now - startTime) / 1000);
            tickCheck(elapsedSecs);
            var n = cfg.flowPromptMinutes;
            if (n > 0) {
                // ask every n minutes of focus (at 10, 20, 30 ... with the default)
                var due = Math.floor(elapsedSecs / (n * 60));
                if (due > promptsSent) {
                    promptsSent = due;
                    askForBreak();
                }
            }
            return false;
        }
        remainingSecs = Math.max(0, Math.ceil((endTime - now) / 1000));
        if (remainingSecs <= 0) { finished(); return true; }
        tickCheck(remainingSecs);
        return false;
    }

    // refresh idle countdowns when settings change
    function refreshIdle() {
        if (active) return;
        if (mode === "pomodoro") setCountdown(durationFor(phase));
    }
    Connections {
        target: root.cfg
        function onFocusMinutesChanged() { root.refreshIdle(); }
        function onShortBreakMinutesChanged() { root.refreshIdle(); }
        function onLongBreakMinutesChanged() { root.refreshIdle(); }
    }

    Component.onCompleted: setMode(cfg.lastMode)

    Timer {
        interval: 250
        repeat: true
        running: root.running
        onTriggered: root.update()
    }

    Loader {
        id: soundLoader
        source: "SoundPlayer.qml"
        onLoaded: if (item) item.fallback = true
    }
    Loader {
        id: startSoundLoader
        source: "SoundPlayer.qml"
        onLoaded: if (item) item.fallback = true
    }
    Loader {
        id: tickLoader
        source: "SoundPlayer.qml"
    }

    Loader {
        id: promptLoader
        source: "BreakPrompt.qml"
    }
    Connections {
        target: promptLoader.item
        function onTakeBreakRequested() { root.takeBreak(); }
    }

    Notification {
        id: notif
        componentName: "plasma_workspace"
        eventId: "notification"
        iconName: "chronometer"
    }

    // ---------- plasmoid plumbing ----------
    toolTipMainText: phaseText
    toolTipSubText: display + (active && !running ? " · " + i18n("paused") : "")

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: root.running ? i18n("Pause") : (root.active ? i18n("Resume") : i18n("Start"))
            icon.name: root.running ? "media-playback-pause" : "media-playback-start"
            onTriggered: root.toggle()
        },
        PlasmaCore.Action {
            text: i18n("Stop")
            icon.name: "media-playback-stop"
            visible: root.active
            onTriggered: root.stop()
        }
    ]

    // ---------- panel / compact view ----------
    compactRepresentation: MouseArea {
        id: compactRoot
        readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical
        readonly property string disp: root.cfg.panelDisplay   // icon | text | both
        readonly property bool showIcon: disp !== "text"
        readonly property bool showText: vertical ? disp === "text" : disp !== "icon"

        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        Layout.minimumWidth: vertical ? Kirigami.Units.iconSizes.small
                                      : row.implicitWidth + Kirigami.Units.smallSpacing * 2
        onWheel: wheel => {
            root.wheelStep(wheel.angleDelta.y);
            wheel.accepted = true;
        }
        onClicked: mouse => {
            if (mouse.button === Qt.MiddleButton) root.toggle();
            else root.expanded = !root.expanded;
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            height: parent.height
            spacing: Kirigami.Units.smallSpacing
            opacity: (root.active && !root.running) ? 0.6 : 1.0

            // dial "icon": outline plus a filled wedge of the time left (same scale as the popup dial)
            Item {
                id: ringIcon
                visible: compactRoot.showIcon
                Layout.fillHeight: true
                Layout.preferredWidth: Math.max(1, height)
                readonly property real sw: Math.max(2, Math.round(width * 0.12))
                readonly property real r: Math.max(1, (width - sw) / 2 - 1)
                readonly property real wr: Math.max(1, r - sw * 0.5 - 1.5)
                readonly property real cx: width / 2
                readonly property real cy: height / 2

                Shape {
                    anchors.fill: parent
                    layer.enabled: true
                    layer.samples: 4
                    ShapePath {
                        strokeWidth: ringIcon.sw
                        strokeColor: Qt.alpha(root.panelColor, root.active ? 0.6 : 1.0)
                        fillColor: "transparent"
                        PathAngleArc {
                            centerX: ringIcon.cx; centerY: ringIcon.cy
                            radiusX: ringIcon.r; radiusY: ringIcon.r
                            startAngle: -90; sweepAngle: 360
                        }
                    }
                }

                SpinnerWedge {
                    anchors.fill: parent
                    visible: root.countingUp && root.active
                    active: root.countingUp && root.active
                    running: root.running
                    color: root.panelColor
                    wedgeR: ringIcon.wr
                }

                Shape {
                    anchors.fill: parent
                    visible: !root.countingUp
                    layer.enabled: true
                    layer.samples: 4
                    SequentialAnimation on opacity {
                        running: root.running
                        loops: Animation.Infinite
                        alwaysRunToEnd: true
                        NumberAnimation { to: 0.55; duration: 900 }
                        NumberAnimation { to: 1.0; duration: 900 }
                    }
                    ShapePath {
                        strokeWidth: -1
                        fillColor: (root.active && root.progress > 0) ? root.panelColor : "transparent"
                        startX: ringIcon.cx; startY: ringIcon.cy
                        PathLine { x: ringIcon.cx; y: ringIcon.cy - ringIcon.wr }
                        PathAngleArc {
                            moveToStart: false
                            centerX: ringIcon.cx; centerY: ringIcon.cy
                            radiusX: ringIcon.wr; radiusY: ringIcon.wr
                            startAngle: -90
                            sweepAngle: Math.min(359.9, 360 * root.progress)
                        }
                    }
                }
            }

            PlasmaComponents3.Label {
                visible: compactRoot.showText
                text: root.display
                font.bold: true
                color: root.panelColor
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: compactRoot.vertical
                Layout.maximumWidth: compactRoot.vertical ? compactRoot.width : 16777215
                fontSizeMode: compactRoot.vertical ? Text.Fit : Text.FixedSize
                minimumPixelSize: 6
            }
        }
    }

    // ---------- popup / desktop view ----------
    fullRepresentation: ColumnLayout {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 19
        Layout.minimumHeight: Kirigami.Units.gridUnit * 27
        spacing: Kirigami.Units.largeSpacing

        // mode tabs
        PlasmaComponents3.TabBar {
            id: modeTabs
            Layout.fillWidth: true
            enabled: !root.active
            Binding {
                target: modeTabs
                property: "currentIndex"
                value: root.mode === "timer" ? 0 : (root.mode === "pomodoro" ? 1 : 2)
            }
            PlasmaComponents3.TabButton {
                text: i18n("Timer")
                onClicked: root.setMode("timer")
            }
            PlasmaComponents3.TabButton {
                text: i18n("Pomodoro")
                onClicked: root.setMode("pomodoro")
            }
            PlasmaComponents3.TabButton {
                text: i18n("Flowmodoro")
                onClicked: root.setMode("flow")
            }
        }

        // countdown ring: full when a timer starts, empties as time runs out
        Item {
            id: ring
            readonly property real stroke: 10
            readonly property real arcR: width / 2 - stroke
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.gridUnit * 11
            Layout.preferredHeight: Kirigami.Units.gridUnit * 11

            WheelHandler {
                onWheel: event => root.wheelStep(event.angleDelta.y)
            }

            Shape {
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                ShapePath {
                    strokeWidth: ring.stroke
                    strokeColor: Qt.alpha(Kirigami.Theme.textColor, 0.15)
                    fillColor: "transparent"
                    PathAngleArc {
                        centerX: ring.width / 2; centerY: ring.height / 2
                        radiusX: ring.arcR; radiusY: ring.arcR
                        startAngle: -90; sweepAngle: 360
                    }
                }
                ShapePath {
                    strokeWidth: ring.stroke
                    strokeColor: (!root.countingUp && root.progress > 0) ? root.phaseColor : "transparent"
                    fillColor: "transparent"
                    capStyle: ShapePath.RoundCap
                    PathAngleArc {
                        centerX: ring.width / 2; centerY: ring.height / 2
                        radiusX: ring.arcR; radiusY: ring.arcR
                        startAngle: -90
                        sweepAngle: Math.min(359.9, 360 * root.progress)
                    }
                }
            }

            // Flowmodoro focus: spinning arc that grows and shrinks
            SpinnerArc {
                anchors.fill: parent
                visible: root.countingUp && root.active
                active: root.countingUp && root.active
                running: root.running
                color: root.phaseColor
                lineWidth: ring.stroke
                arcR: ring.arcR
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.display
                    font.pixelSize: Kirigami.Units.gridUnit * 2.6
                    font.weight: Font.Light
                }
                PlasmaComponents3.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.phaseText
                    color: root.phaseColor
                    font.bold: true
                }
            }
        }

        // status line
        PlasmaComponents3.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            opacity: 0.7
            wrapMode: Text.WordWrap
            visible: text.length > 0
            text: {
                if (root.mode === "pomodoro")
                    return i18n("Completed focus sessions: %1 (long break every %2)",
                                root.completedFocus, root.cfg.cyclesBeforeLong);
                if (root.mode === "flow") {
                    if (root.phase === "focus")
                        return root.elapsedSecs > 0
                            ? i18n("Next break: %1", root.fmt(root.breakSecsFor(root.elapsedSecs)))
                            : i18n("Counts up while you focus. Break = focus ÷ %1.", root.cfg.flowRatio);
                    return i18n("Enjoy your break.");
                }
                return "";
            }
        }

        // presets (plain timer only)
        Flow {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing
            visible: root.mode === "timer" && !root.active
            Repeater {
                model: root.presetList
                PlasmaComponents3.Button {
                    text: i18n("%1 min", modelData)
                    onClicked: root.applyPreset(modelData)
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            visible: root.mode === "timer" && !root.active
            PlasmaComponents3.Label { text: i18n("Custom:") }
            QQC2.SpinBox {
                id: customSpin
                from: 1; to: 999; value: 25; editable: true
            }
            PlasmaComponents3.Label { text: i18n("min") }
            Item { Layout.fillWidth: true }
            PlasmaComponents3.Button {
                text: i18n("Start")
                icon.name: "media-playback-start"
                onClicked: root.applyPreset(customSpin.value)
            }
        }

        Item { Layout.fillHeight: true }

        // Start when idle; only Pause/Resume + Stop while a session is active
        PlasmaComponents3.Button {
            Layout.fillWidth: true
            visible: !root.active && root.mode !== "timer"
            icon.name: "media-playback-start"
            text: i18n("Start")
            highlighted: true
            onClicked: root.start()
        }
        RowLayout {
            Layout.fillWidth: true
            visible: root.active
            PlasmaComponents3.Button {
                Layout.fillWidth: true
                icon.name: root.running ? "media-playback-pause" : "media-playback-start"
                text: root.running ? i18n("Pause") : i18n("Resume")
                highlighted: !root.running
                onClicked: root.toggle()
            }
            PlasmaComponents3.Button {
                visible: root.countingUp
                icon.name: "media-skip-forward"
                text: i18n("Take break")
                enabled: root.elapsedSecs > 0
                highlighted: root.promptsSent > 0
                onClicked: root.takeBreak()
            }
            PlasmaComponents3.Button {
                icon.name: "media-playback-stop"
                text: i18n("Stop")
                onClicked: root.stop()
            }
        }
    }
}
