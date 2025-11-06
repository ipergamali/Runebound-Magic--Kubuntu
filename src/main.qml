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
    property bool guardianCueFinished: false
    property bool finaleSceneReady: false
    property bool finaleSceneStarted: false
    property int currentHeroIndex: 0
    property int selectedHeroIndex: -1
    property var selectedHeroData: null
    property string currentHeroName: ""
    property string currentHeroDescription: ""
    property string selectedHeroName: ""
    property string heroNameInput: ""

    ListModel {
        id: heroCardModel
        ListElement {
            heroId: "mage"
            name: qsTr("Mage")
            description: qsTr("A master of elemental sorcery with unmatched area damage.")
            cardSource: "../assets/images/heroes_cards/mage.png"
        }
        ListElement {
            heroId: "warrior"
            name: qsTr("Warrior")
            description: qsTr("Heavy armor and relentless strength make the warrior unbreakable.")
            cardSource: "../assets/images/heroes_cards/warrior.png"
        }
        ListElement {
            heroId: "ranger"
            name: qsTr("Ranger")
            description: qsTr("Swift and precise, the ranger strikes from the shadows.")
            cardSource: "../assets/images/heroes_cards/ranger.png"
        }
        ListElement {
            heroId: "mystical_priestess"
            name: qsTr("Mystical Priestess")
            description: qsTr("Blessed by the runes, she heals allies and bends fate.")
            cardSource: "../assets/images/heroes_cards/mystical_priestess.png"
        }
    }

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
               sceneIndex === 3 ? "#f3e5c0" :
               sceneIndex === 4 ? "#120a1e" : "#000000"
        opacity: sceneIndex === 1 ? 0.0 :
                 sceneIndex === 2 ? 0.45 :
                 sceneIndex === 3 ? 0.3 :
                 sceneIndex === 4 ? 0.55 : 0.0
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
        id: finaleGuardian
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -70
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.08
        source: "../assets/images/heroes/peiestsess.png"
        fillMode: Image.PreserveAspectFit
        width: Math.min(parent.width * 0.28, parent.height * 0.5)
        smooth: true
        opacity: 0.0
        visible: opacity > 0.0
        z: 2
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Image {
        id: finaleWizard
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -70
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.08
        source: "../assets/images/heroes/black_wizard.png"
        fillMode: Image.PreserveAspectFit
        width: Math.min(parent.width * 0.28, parent.height * 0.5)
        smooth: true
        opacity: 0.0
        visible: opacity > 0.0
        z: 2
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }
    }

    Row {
        id: finaleGemRow
        anchors.centerIn: parent
        spacing: 30
        opacity: 0.0
        visible: opacity > 0.0
        z: 3
        Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad } }

        Image {
            id: finaleRedGem
            source: "../assets/images/tiles/red_gem.png"
            width: 96
            height: 96
            smooth: true
            opacity: 0.0
            Behavior on scale { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
            SequentialAnimation {
                id: finaleRedGlow
                running: sceneIndex === 4
                loops: Animation.Infinite
                onRunningChanged: if (!running) finaleRedGem.scale = 1.0
                NumberAnimation {
                    target: finaleRedGem
                    property: "scale"
                    from: 1.0; to: 1.12
                    duration: 900
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: finaleRedGem
                    property: "scale"
                    from: 1.12; to: 1.0
                    duration: 900
                    easing.type: Easing.InOutQuad
                }
            }
            SequentialAnimation {
                id: finaleRedFade
                running: false
                PauseAnimation { duration: 0 }
                NumberAnimation {
                    target: finaleRedGem
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: finaleBlueGem
            source: "../assets/images/tiles/blue_gem.png"
            width: 96
            height: 96
            smooth: true
            opacity: 0.0
            Behavior on scale { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
            SequentialAnimation {
                id: finaleBlueGlow
                running: sceneIndex === 4
                loops: Animation.Infinite
                onRunningChanged: if (!running) finaleBlueGem.scale = 1.0
                NumberAnimation {
                    target: finaleBlueGem
                    property: "scale"
                    from: 1.0; to: 1.12
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: finaleBlueGem
                    property: "scale"
                    from: 1.12; to: 1.0
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
            SequentialAnimation {
                id: finaleBlueFade
                running: false
                PauseAnimation { duration: 1000 }
                NumberAnimation {
                    target: finaleBlueGem
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: finaleTurquoiseGem
            source: "../assets/images/tiles/turquoise_gem.png"
            width: 96
            height: 96
            smooth: true
            opacity: 0.0
            Behavior on scale { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
            SequentialAnimation {
                id: finaleTurquoiseGlow
                running: sceneIndex === 4
                loops: Animation.Infinite
                onRunningChanged: if (!running) finaleTurquoiseGem.scale = 1.0
                NumberAnimation {
                    target: finaleTurquoiseGem
                    property: "scale"
                    from: 1.0; to: 1.12
                    duration: 1100
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: finaleTurquoiseGem
                    property: "scale"
                    from: 1.12; to: 1.0
                    duration: 1100
                    easing.type: Easing.InOutQuad
                }
            }
            SequentialAnimation {
                id: finaleTurquoiseFade
                running: false
                PauseAnimation { duration: 2000 }
                NumberAnimation {
                    target: finaleTurquoiseGem
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }
        }

        Image {
            id: finaleGreenGem
            source: "../assets/images/tiles/green_gem.png"
            width: 96
            height: 96
            smooth: true
            opacity: 0.0
            Behavior on scale { NumberAnimation { duration: 800; easing.type: Easing.InOutQuad } }
            SequentialAnimation {
                id: finaleGreenGlow
                running: sceneIndex === 4
                loops: Animation.Infinite
                onRunningChanged: if (!running) finaleGreenGem.scale = 1.0
                NumberAnimation {
                    target: finaleGreenGem
                    property: "scale"
                    from: 1.0; to: 1.12
                    duration: 1200
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    target: finaleGreenGem
                    property: "scale"
                    from: 1.12; to: 1.0
                    duration: 1200
                    easing.type: Easing.InOutQuad
                }
            }
            SequentialAnimation {
                id: finaleGreenFade
                running: false
                PauseAnimation { duration: 3000 }
                NumberAnimation {
                    target: finaleGreenGem
                    property: "opacity"
                    from: 0.0; to: 1.0
                    duration: 400
                    easing.type: Easing.InOutQuad
                }
            }
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
        anchors.bottomMargin: 60
        width: window.width * 0.7
        text: qsTr("\u201cBut balance is a chain meant to be broken\u2026 and I, the Black Wizard, will forge a new world from the ashes!\u201d")
        textFormat: Text.RichText
        font.pixelSize: 30
        font.family: signatureFont.name
        color: "#d7ffd6"
        horizontalAlignment: Text.AlignCenter
        wrapMode: Text.Wrap
        opacity: 0.0
        visible: sceneIndex === 2 || opacity > 0.0
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

    Text {
        id: finaleNarration
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        width: window.width * 0.75
        text: qsTr("The battle of runes begins. Match their power, wield their magic, and decide the fate of the realm.")
        textFormat: Text.RichText
        font.pixelSize: 32
        font.family: signatureFont.name
        color: "#f8eaff"
        horizontalAlignment: Text.AlignCenter
        wrapMode: Text.Wrap
        opacity: 0.0
        visible: sceneIndex === 4 || opacity > 0.0
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.InOutQuad } }
    }

    Button {
        id: lobbyButton
        text: qsTr("Lobby")
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 40
        anchors.bottomMargin: 40
        opacity: sceneIndex === 4 ? 1.0 : 0.0
        visible: opacity > 0.0
        enabled: sceneIndex === 4
        focusPolicy: Qt.NoFocus
        z: 4
        background: Rectangle {
            radius: 24
            color: "#1f1f28"
            border.color: "#9f8cff"
            border.width: 2
            implicitWidth: 140
            implicitHeight: 48
        }
        contentItem: Text {
            text: lobbyButton.text
            font.pixelSize: 20
            font.family: signatureFont.name
            color: "#f8eaff"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onClicked: openLobby()
    }

    Item {
        id: lobbyLayer
        anchors.fill: parent
        visible: sceneIndex === 5
        opacity: visible ? 1.0 : 0.0
        enabled: visible
        z: 3
        Component.onCompleted: updateHeroDetails()

        Image {
            id: lobbyBackdrop
            anchors.centerIn: parent
            width: parent.width * 0.85
            height: parent.height * 0.85
            source: "../assets/images/lobby/Game_Lobby.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        PathView {
            id: heroCarousel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.height * 0.08
            width: parent.width * 0.6
            height: parent.height * 0.4
            z: 1
            model: heroCardModel
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5
            highlightRangeMode: PathView.StrictlyEnforceRange
            snapMode: PathView.SnapOneItem
            pathItemCount: 5
            dragMargin: 80
            interactive: true
            clip: false
            path: Path {
                startX: heroCarousel.width * 0.15
                startY: heroCarousel.height * 0.55
                PathLine { x: heroCarousel.width * 0.85; y: heroCarousel.height * 0.55 }
            }
            onCurrentIndexChanged: updateHeroDetails()
            delegate: Item {
                width: heroCarousel.width * 0.28
                height: heroCarousel.height * 0.85
                property string cardSource: model.cardSource
                transformOrigin: Item.Center
                scale: PathView.isCurrentItem ? 1.0 : 0.75
                opacity: PathView.isCurrentItem ? 1.0 : 0.55

                Rectangle {
                    anchors.fill: parent
                    radius: 16
                    color: "transparent"
                    border.width: index === selectedHeroIndex ? 4 : (PathView.isCurrentItem ? 2 : 0)
                    border.color: index === selectedHeroIndex ? "#ffd166" : "#7c4cff"
                    z: 1
                }

                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    source: cardSource
                    smooth: true
                    z: 2
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: heroCarousel.currentIndex = index
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }

        Button {
            id: prevCardButton
            text: "<"
            anchors.verticalCenter: heroCarousel.verticalCenter
            anchors.left: lobbyBackdrop.left
            anchors.leftMargin: 40
            width: 64
            height: 64
            z: 2
            focusPolicy: Qt.NoFocus
            background: Rectangle {
                radius: 32
                color: "#1f2d35"
                border.color: "#7ed1c2"
                border.width: 2
            }
            contentItem: Text {
                text: prevCardButton.text
                font.pixelSize: 26
                font.family: signatureFont.name
                color: "#b8f0e5"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: previousHero()
        }

        Button {
            id: nextCardButton
            text: ">"
            anchors.verticalCenter: heroCarousel.verticalCenter
            anchors.right: lobbyBackdrop.right
            anchors.rightMargin: 40
            width: 64
            height: 64
            z: 2
            focusPolicy: Qt.NoFocus
            background: Rectangle {
                radius: 32
                color: "#1f2d35"
                border.color: "#7ed1c2"
                border.width: 2
            }
            contentItem: Text {
                text: nextCardButton.text
                font.pixelSize: 26
                font.family: signatureFont.name
                color: "#b8f0e5"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: nextHero()
        }

        Column {
            id: heroNameEntry
            anchors.horizontalCenter: lobbyBackdrop.horizontalCenter
            anchors.bottom: lobbyNavigationRow.top
            anchors.bottomMargin: lobbyBackdrop.height * 0.06
            width: lobbyBackdrop.width * 0.5
            spacing: 12
            z: 2

            Text {
                text: qsTr("Hero Name")
                font.pixelSize: 24
                font.family: signatureFont.name
                color: "#f8eaff"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            TextField {
                id: heroNameField
                width: parent.width
                text: window.heroNameInput
                onTextChanged: window.heroNameInput = text
                placeholderText: qsTr("Type the name of your hero")
                font.pixelSize: 20
                font.family: signatureFont.name
                color: "#f8eaff"
                horizontalAlignment: Text.AlignHCenter
                focusPolicy: Qt.StrongFocus
                selectByMouse: true
                cursorVisible: true
                padding: 12
                background: Rectangle {
                    radius: 22
                    color: "#1f2d35cc"
                    border.color: "#7ed1c2"
                    border.width: 2
                }
            }
        }

        Row {
            id: lobbyNavigationRow
            anchors.horizontalCenter: lobbyBackdrop.horizontalCenter
            anchors.bottom: lobbyBackdrop.bottom
            anchors.bottomMargin: lobbyBackdrop.height * 0.05
            spacing: 40
            z: 2

            Button {
                id: lobbyBackButton
                text: qsTr("Back")
                width: 160
                height: 52
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 26
                    color: "#1f2d35"
                    border.color: "#7ed1c2"
                    border.width: 2
                }
                contentItem: Text {
                    text: lobbyBackButton.text
                    font.pixelSize: 22
                    font.family: signatureFont.name
                    color: "#b8f0e5"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: goBack()
            }

            Button {
                id: lobbySelectButton
                text: qsTr("Select Hero")
                width: 200
                height: 52
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 26
                    color: "#513860"
                    border.color: "#d8b6ff"
                    border.width: 2
                }
                contentItem: Text {
                    text: lobbySelectButton.text
                    font.pixelSize: 22
                    font.family: signatureFont.name
                    color: "#f8eaff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: selectHero()
            }
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

        onMediaStatusChanged: function(status) {
            console.log("GuardianCue status:", status)
            if (status === MediaPlayer.EndOfMedia) {
                guardianCueFinished = true
                maybeStartFinaleScene()
            }
        }
    }

    MediaPlayer {
        id: finaleCue
        source: "../assets/sounds/4.mp3"
        autoPlay: false
        audioOutput: AudioOutput {
            volume: 0.85
            muted: false
        }

        onErrorOccurred: function(error, errorString) {
            console.error("FinaleCue error:", errorString)
        }

        onPlaybackStateChanged: function(state) {
            console.log("FinaleCue state:", state, "position:", position)
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

    Timer {
        id: finaleTransitionTimer
        interval: 1500
        repeat: false
        onTriggered: {
            finaleSceneReady = true
            maybeStartFinaleScene()
        }
    }

    function startIntro() {
        if (introStarted) return
        introStarted = true
        sceneIndex = 1
        wizardSceneStarted = false
        wizardSceneReady = false
        introCueFinished = false
        guardianSceneStarted = false
        guardianSceneReady = false
        wizardCueFinished = false
        guardianCueFinished = false
        finaleSceneReady = false
        finaleSceneStarted = false
        console.log("Intro sequence started")

        logoImage.opacity = 0.0
        backgroundImage.opacity = 1.0

        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()

        introCue.stop()
        introCue.play()
        wizardCue.stop()
        guardianCue.stop()
        finaleCue.stop()

        introNarration.opacity = 1.0
        wizardNarration.opacity = 0.0
        wizardImage.opacity = 0.0
        guardianNarration.opacity = 0.0
        guardianImage.opacity = 0.0
        finaleNarration.opacity = 0.0
        finaleGemRow.opacity = 0.0
        finaleGuardian.opacity = 0.0
        finaleWizard.opacity = 0.0
        finaleRedGem.opacity = 0.0
        finaleBlueGem.opacity = 0.0
        finaleTurquoiseGem.opacity = 0.0
        finaleGreenGem.opacity = 0.0
        lobbyButton.opacity = 0.0
        sceneTransitionTimer.stop()
        guardianTransitionTimer.stop()
        finaleTransitionTimer.stop()
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
        guardianCueFinished = false
        finaleSceneStarted = false
        finaleSceneReady = false
        finaleNarration.opacity = 0.0
        finaleGemRow.opacity = 0.0
        finaleGuardian.opacity = 0.0
        finaleWizard.opacity = 0.0
        finaleRedGem.opacity = 0.0
        finaleBlueGem.opacity = 0.0
        finaleTurquoiseGem.opacity = 0.0
        finaleGreenGem.opacity = 0.0
        lobbyButton.opacity = 0.0
        finaleTransitionTimer.stop()
        guardianTransitionTimer.start()
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

        guardianImage.opacity = 1.0
        guardianNarration.opacity = 1.0

        guardianCue.stop()
        guardianCue.play()
        finaleCue.stop()
        guardianTransitionTimer.stop()
        guardianCueFinished = false
        finaleSceneStarted = false
        finaleSceneReady = false
        finaleNarration.opacity = 0.0
        finaleGemRow.opacity = 0.0
        finaleGuardian.opacity = 0.0
        finaleWizard.opacity = 0.0
        finaleRedGem.opacity = 0.0
        finaleBlueGem.opacity = 0.0
        finaleTurquoiseGem.opacity = 0.0
        finaleGreenGem.opacity = 0.0
        lobbyButton.opacity = 0.0
        finaleTransitionTimer.stop()
        finaleTransitionTimer.start()
    }

    function maybeStartFinaleScene() {
        if (finaleSceneStarted)
            return
        if (!finaleSceneReady || !guardianCueFinished)
            return

        showFinaleScene()
    }

    function currentHeroData() {
        if (!heroCarousel || heroCardModel.count === 0)
            return null
        return heroCardModel.get(heroCarousel.currentIndex % heroCardModel.count)
    }

    function updateHeroDetails() {
        if (!heroCarousel)
            return
        if (heroCarousel.currentIndex < 0 && heroCardModel.count > 0) {
            heroCarousel.currentIndex = 0
            return
        }
        const hero = currentHeroData()
        if (!hero)
            return
        currentHeroIndex = heroCarousel.currentIndex
        currentHeroName = hero.name
        currentHeroDescription = hero.description
    }

    function nextHero() {
        if (heroCardModel.count === 0)
            return
        heroCarousel.currentIndex = (heroCarousel.currentIndex + 1) % heroCardModel.count
    }

    function previousHero() {
        if (heroCardModel.count === 0)
            return
        heroCarousel.currentIndex = (heroCarousel.currentIndex - 1 + heroCardModel.count) % heroCardModel.count
    }

    function selectHero() {
        const hero = currentHeroData()
        if (!hero)
            return
        selectedHeroIndex = heroCarousel.currentIndex
        selectedHeroData = hero
        selectedHeroName = hero.name
        console.log("✅ Selected hero:", hero.name)
    }

    function goBack() {
        returnToFinale()
    }

    function startBattle() {
        if (selectedHeroIndex < 0 || !selectedHeroData) {
            console.log("⚠️ Please select a hero before starting the battle.")
            return
        }
        console.log("🚀 Starting battle with:", selectedHeroData.name, "(", selectedHeroData.heroId, ")")
        // TODO: load BattleScene.qml when available
    }

    function showFinaleScene() {
        if (finaleSceneStarted)
            return

        console.log("Switching to finale scene")
        finaleSceneStarted = true
        sceneIndex = 4

        guardianNarration.opacity = 0.0
        guardianImage.opacity = 0.0

        guardianCue.stop()
        finaleCue.stop()
        finaleCue.position = 0
        finaleCue.play()
        finaleGuardian.opacity = 1.0
        finaleWizard.opacity = 1.0
        finaleGemRow.opacity = 1.0
        finaleNarration.opacity = 1.0
        finaleRedGem.opacity = 0.0
        finaleBlueGem.opacity = 0.0
        finaleTurquoiseGem.opacity = 0.0
        finaleGreenGem.opacity = 0.0
        lobbyButton.opacity = 1.0

        finaleRedFade.restart()
        finaleBlueFade.restart()
        finaleTurquoiseFade.restart()
        finaleGreenFade.restart()

        finaleTransitionTimer.stop()
    }

    function openLobby() {
        if (sceneIndex !== 4)
            return

        finaleCue.stop()
        finaleRedFade.running = false
        finaleBlueFade.running = false
        finaleTurquoiseFade.running = false
        finaleGreenFade.running = false

        finaleNarration.opacity = 0.0
        finaleGemRow.opacity = 0.0
        finaleGuardian.opacity = 0.0
        finaleWizard.opacity = 0.0
        finaleRedGem.opacity = 0.0
        finaleBlueGem.opacity = 0.0
        finaleTurquoiseGem.opacity = 0.0
        finaleGreenGem.opacity = 0.0
        lobbyButton.opacity = 0.0

        finaleSceneStarted = false
        sceneIndex = 5
        heroCarousel.currentIndex = 0
        currentHeroIndex = 0
        selectedHeroIndex = -1
        selectedHeroData = null
        selectedHeroName = ""
        heroNameInput = ""
        updateHeroDetails()
    }

    function returnToFinale() {
        if (sceneIndex !== 5)
            return

        finaleSceneStarted = false
        finaleSceneReady = true
        guardianCueFinished = true
        showFinaleScene()
    }

    Component.onCompleted: {
        console.log("ApplicationWindow ready. Click logo to start intro.")
        if (introTrack.playbackState !== MediaPlayer.PlayingState)
            introTrack.play()
    }
}
