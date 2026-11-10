import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami

// Chooser for an alert sound: a few system sounds or any audio file.
RowLayout {
    id: picker
    property string value: ""
    property int volume: 70

    readonly property string dir: "/usr/share/sounds/freedesktop/stereo/"
    readonly property var presets: [
        { text: i18n("Question (Ocean)"), path: "/usr/share/sounds/ocean/stereo/dialog-question.oga" },
        { text: i18n("Complete"),    path: dir + "complete.oga" },
        { text: i18n("Bell"),        path: dir + "bell.oga" },
        { text: i18n("Message"),     path: dir + "message.oga" },
        { text: i18n("Alarm clock"), path: dir + "alarm-clock-elapsed.oga" },
        { text: i18n("Phone ring"),  path: dir + "phone-incoming-call.oga" }
    ]
    readonly property bool custom: combo.currentIndex === presets.length

    function syncIndex() {
        for (var i = 0; i < presets.length; i++) {
            if (presets[i].path === value) { combo.currentIndex = i; return; }
        }
        combo.currentIndex = presets.length;
    }
    onValueChanged: syncIndex()
    Component.onCompleted: syncIndex()

    QQC2.ComboBox {
        id: combo
        model: picker.presets.map(function (p) { return p.text; }).concat([i18n("Custom file…")])
        onActivated: index => {
            if (index < picker.presets.length) picker.value = picker.presets[index].path;
            else if (picker.value.indexOf(picker.dir) === 0) picker.value = "";
        }
    }

    QQC2.TextField {
        visible: picker.custom
        Layout.fillWidth: true
        placeholderText: i18n("Path to an audio file")
        text: picker.value
        onTextEdited: picker.value = text
    }
    QQC2.Button {
        visible: picker.custom
        icon.name: "document-open"
        onClicked: fileDialog.open()
        QQC2.ToolTip.text: i18n("Browse…")
        QQC2.ToolTip.visible: hovered
    }
    QQC2.Button {
        icon.name: "media-playback-start"
        text: i18n("Test")
        onClicked: if (testLoader.item) testLoader.item.play(picker.value, picker.volume)
    }

    FileDialog {
        id: fileDialog
        nameFilters: [i18n("Audio files (*.ogg *.oga *.wav *.mp3 *.flac)"), i18n("All files (*)")]
        onAccepted: picker.value = decodeURIComponent(selectedFile.toString().replace(/^file:\/\//, ""))
    }

    Loader {
        id: testLoader
        visible: false
        source: "SoundPlayer.qml"
        onLoaded: if (item) item.fallback = true
    }
}
