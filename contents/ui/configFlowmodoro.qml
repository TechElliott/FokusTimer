import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_flowRatio: ratioSpin.value
    property alias cfg_flowPromptMinutes: promptSpin.value
    property int cfg_flowRatioDefault
    property int cfg_flowPromptMinutesDefault

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: ratioSpin
            Kirigami.FormData.label: i18n("Break = focus time ÷"); from: 1; to: 20
        }
        QQC2.SpinBox {
            id: promptSpin
            Kirigami.FormData.label: i18n("Suggest a break every (min, 0 = never):")
            from: 0; to: 240
        }
    }
}
