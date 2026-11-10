import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_focusMinutes: focusSpin.value
    property alias cfg_shortBreakMinutes: shortSpin.value
    property alias cfg_longBreakMinutes: longSpin.value
    property alias cfg_cyclesBeforeLong: cyclesSpin.value
    property int cfg_focusMinutesDefault
    property int cfg_shortBreakMinutesDefault
    property int cfg_longBreakMinutesDefault
    property int cfg_cyclesBeforeLongDefault

    Kirigami.FormLayout {
        QQC2.SpinBox { id: focusSpin; Kirigami.FormData.label: i18n("Focus (min):"); from: 1; to: 240 }
        QQC2.SpinBox { id: shortSpin; Kirigami.FormData.label: i18n("Short break (min):"); from: 1; to: 120 }
        QQC2.SpinBox { id: longSpin; Kirigami.FormData.label: i18n("Long break (min):"); from: 1; to: 240 }
        QQC2.SpinBox { id: cyclesSpin; Kirigami.FormData.label: i18n("Focus sessions before long break:"); from: 1; to: 20 }
    }
}
