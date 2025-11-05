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
    property int sceneIndex: 1
    property bool wizardSceneStarted: false
    property bool wizardSceneReady: false
    property bool introCueFinished: false
    property bool guardianSceneStarted: false
    property bool guardianSceneReady: false
    property bool wizardCueFinished: false

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

    Rectangle {
        id: sceneTint
        anchors.fill: parent
        color: sceneIndex === 2 ? "#0f2d1c" :
               sceneIndex === 3 ? "#f3e5c0" : "#000000"
        opacity: sceneIndex === 1 ? 0.0 :
                 sceneIndex === 2 ? 0.45 : 0.3
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Image {
        id: wizardImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "../assets/images/heroes/black_wizard.png"
        fillMode: Image.PreserveAspectFit
        width: Math.min(parent.width * 0.32, parent.height * 0.55)
        smooth: true
        opacity: 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Rectangle {
        id: guardianGlow
        anchors.centerIn: parent
        width: guardianImage.width * 1.4
        height: width
        radius: width / 2
        color: "#fff1c5"
        opacity: 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Image {
        id: guardianImage
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        source: "../assets/images/heroes/peiestsess.png"
        fillMode: Image.PreserveAspectFit
        width: Math.min(parent.width * 0.3, parent.height * 0.5)
        smooth: true
        opacity: 0.0
        visible: opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
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
        id: introColumn
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        width: window.width * 0.75
        spacing: 24
        visible: sceneIndex === 1

        Text {
            id: introNarration
            textFormat: Text.RichText
            text: qsTr("The world was once bound by the elemental runes \u2014 <span style=\"color:#ff5722\">Fire</span>,<br/><span style=\"color:#03a9f4\">Water</span>, <span style=\"color:#c5e1f5\">Air</span>, and <span style=\"color:#795548\">Earth</span> \u2014 that kept the balance of magic alive")
            font.pixelSize: 32
            font.family: signatureFont.name
            color: "#f5f5f5"
            maximumLineCount: 5       
            horizontalAlignment: Text.AlignCenter
            width: parent.width
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
        }

        Row {
            id: gemRow
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 24
            visible: introStarted && sceneIndex === 1

            Image {
                id: redGem
                source: "../assets/images/tiles/red_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: blueGem
                source: "../assets/images/tiles/blue_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: turquoiseGem
                source: "../assets/images/tiles/turquoise_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: greenGem
                source: "../assets/images/tiles/green_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }
        }

    }

    Text {
        id: wizardNarration
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: sceneIndex === 2 ? 60 : 160
        width: window.width * 0.7
        text: qsTr("\u201cBut balance is a chain meant to be broken\u2026 and I, the Black Wizard, will forge a new world from the ashes!\u201d")
        textFormat: Text.RichText
        font.pixelSize: 30
        font.family: signatureFont.name
        color: "#d7ffd6"
        horizontalAlignment: Text.AlignCenter
        wrapMode: Text.Wrap
        opacity: 0.0
        visible: (sceneIndex === 2 || sceneIndex === 3) || opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
    }

    Text {
        id: guardianNarration
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        width: window.width * 0.7
        text: qsTr("Yet hope remains. A lone guardian rises, chosen by the runes themselves, to stand against the growing darkness.")
        textFormat: Text.RichText
        font.pixelSize: 30
        font.family: signatureFont.name
        color: "#ffe8c2"
        horizontalAlignment: Text.AlignCenter
        wrapMode: Text.Wrap
        opacity: 0.0
        visible: sceneIndex === 3 || opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
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
            console.log("IntroCue status:", status)
            if (status === MediaPlayer.EndOfMedia) {
                introCueFinished = true
                maybeStartWizardScene()
            }
        }
    }

    MediaPlayer {
        id: wizardCue
        source: "../assets/sounds/2.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            volume: 0.85
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("WizardCue error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("WizardCue state:", state, "position:", position)
        }

        onMediaStatusChanged: function(status) {
            console.log("WizardCue status:", status)
            if (status === MediaPlayer.EndOfMedia) {
                wizardCueFinished = true
                maybeStartGuardianScene()
            }
        }
    }

    MediaPlayer {
        id: guardianCue
        source: "../assets/sounds/3.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            volume: 0.85
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("GuardianCue error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("GuardianCue state:", state, "position:", position)
        }
    }

    Timer {
        id: redGemTimer
        interval: 3000
        repeat: false
        onTriggered: redGem.opacity = 1.0
    }

    Timer {
        id: blueGemTimer
        interval: 4000
        repeat: false
        onTriggered: blueGem.opacity = 1.0
    }

    Timer {
        id: greenGemTimer
        interval: 6000
        repeat: false
        onTriggered: {
            greenGem.opacity = 1.0
            if (!sceneTransitionTimer.running && !wizardSceneStarted)
                sceneTransitionTimer.start()
        }
    }

    Timer {
        id: turquoiseGemTimer
        interval: 5000
        repeat: false
        onTriggered: turquoiseGem.opacity = 1.0
    }

    Timer {
        id: sceneTransitionTimer
        interval: 1200
        repeat: false
        onTriggered: {
            wizardSceneReady = true
            maybeStartWizardScene()
        }
    }

    Timer {
        id: guardianTransitionTimer
        interval: 1200
        repeat: false
        onTriggered: {
            guardianSceneReady = true
            maybeStartGuardianScene()
        }
    }

    function startIntro() {
        if (introStarted) return
        introStarted = true
        sceneIndex = 1
        wizardSceneStarted = false
        wizardSceneReady = false
        introCueFinished = false
        console.log("Intro sequence started")

        logoImage.opacity = 0.0
        backgroundImage.opacity = 1.0

        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()

        introCue.stop()
        introCue.play()
        wizardCue.stop()
        guardianCue.stop()

        introNarration.opacity = 1.0
        wizardNarration.opacity = 0.0
        wizardImage.opacity = 0.0
        guardianNarration.opacity = 0.0
        guardianImage.opacity = 0.0
        guardianGlow.opacity = 0.0
        sceneTransitionTimer.stop()
        guardianTransitionTimer.stop()
        redGem.opacity = 0.0
        blueGem.opacity = 0.0
        greenGem.opacity = 0.0
        turquoiseGem.opacity = 0.0

        redGemTimer.stop()
        blueGemTimer.stop()
        greenGemTimer.stop()
        turquoiseGemTimer.stop()

        redGemTimer.start()
        blueGemTimer.start()
        greenGemTimer.start()
        turquoiseGemTimer.start()
    }

    function maybeStartWizardScene() {
        if (wizardSceneStarted)
            return
        if (!wizardSceneReady || !introCueFinished)
            return

        showWizardScene()
    }

    function showWizardScene() {
        if (wizardSceneStarted)
            return

        console.log("Switching to wizard scene")
        wizardSceneStarted = true
        sceneIndex = 2

        introNarration.opacity = 0.0
        redGem.opacity = 0.0
        blueGem.opacity = 0.0
        turquoiseGem.opacity = 0.0
        greenGem.opacity = 0.0

        wizardImage.opacity = 1.0
        wizardNarration.opacity = 1.0

        if (introCue.playbackState === MediaPlayer.PlayingState)
            introCue.stop()

        wizardCue.stop()
        wizardCue.play()
        guardianTransitionTimer.stop()
        guardianSceneReady = false
        guardianSceneStarted = false
        wizardCueFinished = false
    }

    function maybeStartGuardianScene() {
        if (guardianSceneStarted)
            return
        if (!guardianSceneReady || !wizardCueFinished)
            return

        showGuardianScene()
    }

    function showGuardianScene() {
        if (guardianSceneStarted)
            return

        console.log("Switching to guardian scene")
        guardianSceneStarted = true
        sceneIndex = 3

        wizardNarration.opacity = 0.0
        wizardImage.opacity = 0.0

        guardianGlow.opacity = 0.25
        guardianImage.opacity = 1.0
        guardianNarration.opacity = 1.0

        guardianCue.stop()
        guardianCue.play()
    }

    Component.onCompleted: {
        console.log("ApplicationWindow ready. Click logo to start intro.")
        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()
    }
}
