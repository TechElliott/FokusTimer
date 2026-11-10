import QtQuick
import QtMultimedia

// Plays an alert sound. Kept in its own file so a missing QtMultimedia
// can't break the rest of the widget (loaded through a Loader).
Item {
    id: sp

    // when true, a missing or unplayable file falls back to the bundled chime
    property bool fallback: false
    readonly property string chimeUrl: Qt.resolvedUrl("../sounds/chime.wav").toString()
    property bool fellBack: false

    function play(path, volume) {
        var p = String(path);
        if (!p) return;
        var url = p.indexOf("://") >= 0 ? p : "file://" + p;
        fellBack = false;
        player.stop();
        if (player.source.toString() !== url) player.source = url;
        out.volume = Math.max(0, Math.min(1, volume / 100));
        player.play();
    }

    MediaPlayer {
        id: player
        audioOutput: AudioOutput { id: out }
        onErrorOccurred: (error, errorString) => {
            if (sp.fallback && !sp.fellBack && player.source.toString() !== sp.chimeUrl) {
                sp.fellBack = true;
                player.source = sp.chimeUrl;
                player.play();
            }
        }
    }
}
