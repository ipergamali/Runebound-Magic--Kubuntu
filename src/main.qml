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
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 80
        spacing: 16

        Text {
            id: fireText
            text: qsTr("Fire")
            font.pixelSize: 48
            font.family: signatureFont.name
            color: "#ff5722"
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: waterText
            text: qsTr("Water")
            font.pixelSize: 48
            font.family: signatureFont.name
            color: "#03a9f4"
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: airText
            text: qsTr("Air")
            font.pixelSize: 48
            font.family: signatureFont.name
            color: "#c5e1f5"
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        }

        Text {
            id: earthText
            text: qsTr("Earth")
            font.pixelSize: 48
            font.family: signatureFont.name
            color: "#795548"
            opacity: 0.0
            Behavior on opacity { NumberAnimation { duration: 350; easing.type: Easing.InOutQuad } }
        }
    }

    MediaPlayer {
        id: introTrack
        source: "../assets/sounds/1.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            id: introOutput
            volume: 0.95
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

    Timer { id: fireTimer; interval: 3000; repeat: false; onTriggered: fireText.opacity = 1.0 }
    Timer { id: waterTimer; interval: 4000; repeat: false; onTriggered: waterText.opacity = 1.0 }
    Timer { id: airTimer; interval: 5000; repeat: false; onTriggered: airText.opacity = 1.0 }
    Timer { id: earthTimer; interval: 6000; repeat: false; onTriggered: earthText.opacity = 1.0 }

    function startIntro() {
        if (introStarted) return
        introStarted = true
        console.log("Intro sequence started")

        logoImage.opacity = 0.0
        backgroundImage.opacity = 1.0

        introTrack.stop()
        introTrack.play()

        fireTimer.restart()
        waterTimer.restart()
        airTimer.restart()
        earthTimer.restart()
    }

    Component.onCompleted: {
        console.log("ApplicationWindow ready. Click logo to start intro.")
    }
}
