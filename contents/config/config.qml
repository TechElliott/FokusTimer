import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Timer")
        icon: "chronometer"
        source: "configTimer.qml"
    }
    ConfigCategory {
        name: i18n("Pomodoro")
        icon: "view-time-schedule"
        source: "configPomodoro.qml"
    }
    ConfigCategory {
        name: i18n("Flowmodoro")
        icon: "player-time"
        source: "configFlowmodoro.qml"
    }
    ConfigCategory {
        name: i18n("Sounds")
        icon: "audio-volume-high"
        source: "configSounds.qml"
    }
}
