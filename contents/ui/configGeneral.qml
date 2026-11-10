import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property string cfg_panelDisplay
    property string cfg_panelDisplayDefault
    property alias cfg_autoStartNext: autoCheck.checked
    property bool cfg_autoStartNextDefault

    Kirigami.FormLayout {
        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Appearance") }
        QQC2.ComboBox {
            id: displayCombo
            Kirigami.FormData.label: i18n("Panel display:")
            textRole: "text"
            valueRole: "value"
            model: [
                { text: i18n("Icon only"), value: "icon" },
                { text: i18n("Timer only"), value: "text" },
                { text: i18n("Icon and timer"), value: "both" }
            ]
            Component.onCompleted: currentIndex = Math.max(0, indexOfValue(cfg_panelDisplay))
            onActivated: cfg_panelDisplay = currentValue
        }

        Item { Kirigami.FormData.isSection: true; Kirigami.FormData.label: i18n("Behavior") }
        QQC2.CheckBox {
            id: autoCheck
            text: i18n("Automatically start the next phase")
        }
    }
}
