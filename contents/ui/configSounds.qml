import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_soundEnabled: soundCheck.checked
    property alias cfg_focusEndSound: focusPicker.value
    property alias cfg_breakEndSound: breakPicker.value
    property alias cfg_soundVolume: volumeSpin.value
    property alias cfg_startSoundEnabled: startCheck.checked
    property alias cfg_startSound: startPicker.value
    property alias cfg_tickEnabled: tickCheck.checked
    property alias cfg_tickVolume: tickVolumeSpin.value
    property bool cfg_soundEnabledDefault
    property string cfg_focusEndSoundDefault
    property string cfg_breakEndSoundDefault
    property int cfg_soundVolumeDefault
    property bool cfg_startSoundEnabledDefault
    property string cfg_startSoundDefault
    property bool cfg_tickEnabledDefault
    property int cfg_tickVolumeDefault

    Kirigami.FormLayout {
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Phase end") }
        QQC2.CheckBox {
            id: soundCheck
            text: i18n("Play a sound when a phase ends")
        }
        SoundPicker {
            id: focusPicker
            enabled: soundCheck.checked
            volume: volumeSpin.value
            Kirigami.FormData.label: i18n("End of focus / timer:")
        }
        SoundPicker {
            id: breakPicker
            enabled: soundCheck.checked
            volume: volumeSpin.value
            Kirigami.FormData.label: i18n("End of break:")
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Phase start") }
        QQC2.CheckBox {
            id: startCheck
            text: i18n("Play a sound when a phase starts")
        }
        SoundPicker {
            id: startPicker
            enabled: startCheck.checked
            volume: volumeSpin.value
            Kirigami.FormData.label: i18n("Start sound:")
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Volume") }
        QQC2.SpinBox {
            id: volumeSpin
            Kirigami.FormData.label: i18n("Alert volume (%):")
            from: 0; to: 100; stepSize: 5
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Ticking") }
        QQC2.CheckBox {
            id: tickCheck
            text: i18n("Tick every second during Pomodoro / Flowmodoro focus")
        }
        QQC2.SpinBox {
            id: tickVolumeSpin
            enabled: tickCheck.checked
            Kirigami.FormData.label: i18n("Tick volume (%):")
            from: 0; to: 100; stepSize: 5
        }
    }
}
