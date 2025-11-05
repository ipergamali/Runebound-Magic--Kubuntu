import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 6.5

ApplicationWindow {
    id: window
    width: 1280
    height: 720
    visible: true
    color: "black"
    title: qsTr("Runebound Magic")

    property bool introStarted: false
    property bool secondSceneStarted: false

    FontLoader {
        id: signatureFont
        source: "../assets/fonts/whispering-signature-personal-use/WhisperingSignature.ttf"
        onStatusChanged: {
            console.log("FontLoader status:",
                        status === FontLoader.Ready ? "Ready" :
                        status === FontLoader.Loading ? "Loading" :
                        status === FontLoader.Error ? "Error" :
                        "Null")
            if (status === FontLoader.Error)
                console.error("FontLoader error:", name, source)
        }
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "../assets/images/intro/MysticalTempleRuins.png"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.0
        smooth: true
        Behavior on opacity {
            NumberAnimation { duration: 800; easing.type: Easing.InOutQuad }
        }
    }

    Image {
        id: logoImage
        anchors.centerIn: parent
        source: "../assets/images/logo/logo.png"
        fillMode: Image.PreserveAspectFit
        width: Math.min(parent.width * 0.4, parent.height * 0.4)
        height: width
        smooth: true
        opacity: 1.0
        Behavior on opacity {
            NumberAnimation { duration: 400; easing.type: Easing.InOutQuad }
        }
    }

    MouseArea {
        anchors.fill: logoImage
        enabled: !introStarted
        cursorShape: Qt.PointingHandCursor
        onClicked: startIntro()
    }

    Column {
        anchors.top: parent.top
        anchors.topMargin: 20
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 40
        anchors.rightMargin: 40

        Text {
            id: introNarration
            textFormat: Text.RichText
            text: qsTr("The world was once bound by the elemental runes \u2014 <span style=\"color:#ff5722\">Fire</span>,<br/><span style=\"color:#03a9f4\">Water</span>, <span style=\"color:#c5e1f5\">Air</span>, and <span style=\"color:#795548\">Earth</span> \u2014 that kept the balance of magic alive")
            font.pixelSize: 32
            font.family: signatureFont.name
            color: "#f5f5f5"
            maximumLineCount: 5       
            horizontalAlignment: Text.AlignCenter
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
        }
    }

    MediaPlayer {
        id: introTrack
        source: "../assets/music/soundtrack.mp3"
        autoPlay: true
        loops: MediaPlayer.Infinite
        audioOutput: AudioOutput {
            id: introOutput
            volume: 0.3
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("IntroTrack error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("IntroTrack state:", state, "position:", position)
        }

        Component.onCompleted: {
            console.log("IntroTrack ready, source:", source)
        }
    }

    MediaPlayer {
        id: introCue
        source: "../assets/sounds/1.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            volume: 0.8
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("IntroCue error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("IntroCue state:", state, "position:", position)
        }

        onMediaStatusChanged: function(status) {
            if (status === MediaPlayer.EndOfMedia) {
                console.log("IntroCue finished, scheduling second scene")
                if (!secondSceneStarted && !sceneTransitionDelay.running)
                    sceneTransitionDelay.start()
            }
        }
    }

    Timer {
        id: sceneTransitionDelay
        interval: 2000
        repeat: false
        onTriggered: startSecondScene()
    }

    MediaPlayer {
        id: secondSceneCue
        source: "../assets/sounds/2.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            volume: 0.8
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("SecondSceneCue error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("SecondSceneCue state:", state, "position:", position)
        }
    }

    function startIntro() {
        if (introStarted) return
        introStarted = true
        secondSceneStarted = false
        console.log("Intro sequence started")

        logoImage.opacity = 0.0
        backgroundImage.opacity = 1.0

        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()

        sceneTransitionDelay.stop()
        introCue.stop()
        introCue.play()
        secondSceneCue.stop()

        introNarration.opacity = 1.0
    }

    function startSecondScene() {
        if (secondSceneStarted)
            return

        secondSceneStarted = true
        console.log("Second scene starting with delayed cue")

        if (introCue.playbackState === MediaPlayer.PlayingState)
            introCue.stop()

        secondSceneCue.stop()
        secondSceneCue.play()
    }

    Component.onCompleted: {
        console.log("ApplicationWindow ready. Click logo to start intro.")
        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()
    }
}
