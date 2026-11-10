import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    property alias cfg_presets: presetsField.text
    property string cfg_presetsDefault

    Kirigami.FormLayout {
        QQC2.TextField {
            id: presetsField
            Kirigami.FormData.label: i18n("Presets (minutes):")
            placeholderText: "5,10,15,25,45,60"
        }
        QQC2.Label {
            text: i18n("Separate values with commas. Decimals work too, e.g. 0.5 for 30 seconds.")
            opacity: 0.7
            wrapMode: Text.WordWrap
            Layout.maximumWidth: Kirigami.Units.gridUnit * 20
        }
    }
}
