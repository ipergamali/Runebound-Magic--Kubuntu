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
    property string lobbyStatusMessage: ""
    property bool lobbyStatusIsError: false
    property var difficultyOptions: [qsTr("Easy"), qsTr("Normal"), qsTr("Hard")]
    property int difficultyIndex: 1
    property string currentDifficulty: difficultyOptions.length > 0
                                     ? difficultyOptions[Math.max(0, Math.min(difficultyOptions.length - 1, difficultyIndex))]
                                     : ""
    property int currentHeroHealth: 0
    property int currentHeroMana: 0
    property int currentHeroPower: 0
    property string currentHeroElement: qsTr("Unknown")
    property bool inventoryOverlayVisible: false
    property var inventoryCategories: [
        qsTr("Weapons"),
        qsTr("Armor"),
        qsTr("Shields"),
        qsTr("Accessories"),
        qsTr("Consumables"),
        qsTr("Spells & Scrolls"),
        qsTr("Runes & Gems"),
        qsTr("Crafting Materials"),
        qsTr("Quest Items"),
        qsTr("Gold & Currency")
    ]
    property int inventorySlotsPerRow: 5

    ListModel {
        id: heroCardModel
        ListElement {
            heroId: "mage"
            name: qsTr("Mage")
            description: qsTr("A master of elemental sorcery with unmatched area damage.")
            cardSource: "qrc:/RuneboundMagic/assets/images/heroes_cards/mage.png"
            health: 80
            mana: 140
            power: 95
            element: qsTr("Arcane")
        }
        ListElement {
            heroId: "warrior"
            name: qsTr("Warrior")
            description: qsTr("Heavy armor and relentless strength make the warrior unbreakable.")
            cardSource: "qrc:/RuneboundMagic/assets/images/heroes_cards/warrior.png"
            health: 130
            mana: 60
            power: 90
            element: qsTr("Steel")
        }
        ListElement {
            heroId: "ranger"
            name: qsTr("Ranger")
            description: qsTr("Swift and precise, the ranger strikes from the shadows.")
            cardSource: "qrc:/RuneboundMagic/assets/images/heroes_cards/ranger.png"
            health: 90
            mana: 80
            power: 85
            element: qsTr("Wind")
        }
        ListElement {
            heroId: "mystical_priestess"
            name: qsTr("Mystical Priestess")
            description: qsTr("Blessed by the runes, she heals allies and bends fate.")
            cardSource: "qrc:/RuneboundMagic/assets/images/heroes_cards/mystical_priestess.png"
            health: 95
            mana: 150
            power: 72
            element: qsTr("Spirit")
        }
    }

    FontLoader {
        id: signatureFont
        source: "qrc:/RuneboundMagic/assets/fonts/whispering-signature-personal-use/WhisperingSignature.ttf"
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

    AudioOutput {
        id: introOutput
        volume: 0.3
        muted: false
        onMutedChanged: console.log("IntroOutput muted:", muted)
        onVolumeChanged: console.log("IntroOutput volume:", volume)
        Component.onCompleted: console.log("IntroOutput device:", device.description)
    }

    AudioOutput {
        id: introCueOutput
        volume: 0.9
        muted: false
        onMutedChanged: console.log("IntroCueOutput muted:", muted)
        onVolumeChanged: console.log("IntroCueOutput volume:", volume)
        Component.onCompleted: console.log("IntroCueOutput device:", device.description)
    }

    AudioOutput {
        id: wizardOutput
        volume: 1.0
        muted: false
        onMutedChanged: console.log("WizardOutput muted:", muted)
        onVolumeChanged: console.log("WizardOutput volume:", volume)
        Component.onCompleted: console.log("WizardOutput device:", device.description)
    }

    AudioOutput {
        id: guardianOutput
        volume: 1.0
        muted: false
        onMutedChanged: console.log("GuardianOutput muted:", muted)
        onVolumeChanged: console.log("GuardianOutput volume:", volume)
        Component.onCompleted: console.log("GuardianOutput device:", device.description)
    }

    AudioOutput {
        id: finaleOutput
        volume: 1.0
        muted: false
        onMutedChanged: console.log("FinaleOutput muted:", muted)
        onVolumeChanged: console.log("FinaleOutput volume:", volume)
        Component.onCompleted: console.log("FinaleOutput device:", device.description)
    }

    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "qrc:/RuneboundMagic/assets/images/intro/MysticalTempleRuins.png"
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
        source: "qrc:/RuneboundMagic/assets/images/heroes/black_wizard.png"
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
        source: "qrc:/RuneboundMagic/assets/images/heroes/peiestsess.png"
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
        source: "qrc:/RuneboundMagic/assets/images/heroes/peiestsess.png"
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
        source: "qrc:/RuneboundMagic/assets/images/heroes/black_wizard.png"
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
            source: "qrc:/RuneboundMagic/assets/images/tiles/red_gem.png"
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
            source: "qrc:/RuneboundMagic/assets/images/tiles/blue_gem.png"
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
            source: "qrc:/RuneboundMagic/assets/images/tiles/turquoise_gem.png"
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
            source: "qrc:/RuneboundMagic/assets/images/tiles/green_gem.png"
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
        source: "qrc:/RuneboundMagic/assets/images/logo/logo.png"
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
            source: "qrc:/RuneboundMagic/assets/images/tiles/red_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: blueGem
            source: "qrc:/RuneboundMagic/assets/images/tiles/blue_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: turquoiseGem
            source: "qrc:/RuneboundMagic/assets/images/tiles/turquoise_gem.png"
                width: 90
                height: 90
                fillMode: Image.PreserveAspectFit
                smooth: true
                opacity: 0.0
                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.InOutQuad } }
            }

            Image {
                id: greenGem
            source: "qrc:/RuneboundMagic/assets/images/tiles/green_gem.png"
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
            source: "qrc:/RuneboundMagic/assets/images/lobby/Game_Lobby.png"
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Column {
            id: difficultyBanner
            anchors.horizontalCenter: lobbyBackdrop.horizontalCenter
            anchors.top: lobbyBackdrop.top
            anchors.topMargin: lobbyBackdrop.height * 0.04
            width: lobbyBackdrop.width * 0.4
            spacing: 8
            z: 3

            Text {
                text: qsTr("Difficulty")
                font.pixelSize: 24
                font.family: signatureFont.name
                color: "#f8eaff"
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            ComboBox {
                id: difficultySelector
                width: parent.width
                model: window.difficultyOptions
                focusPolicy: Qt.NoFocus
                font.pixelSize: 20
                font.family: signatureFont.name
                indicator: Rectangle {
                    implicitWidth: 18
                    implicitHeight: 10
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    anchors.rightMargin: 18
                    color: "#f8eaff"
                    border.width: 0
                }
                contentItem: Text {
                    text: difficultySelector.displayText
                    font.pixelSize: difficultySelector.font.pixelSize
                    font.family: difficultySelector.font.family
                    color: "#f8eaff"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                background: Rectangle {
                    radius: 22
                    color: "#1f2d35cc"
                    border.color: "#d8b6ff"
                    border.width: 2
                }
                delegate: ItemDelegate {
                    width: difficultySelector.width
                    contentItem: Text {
                        text: modelData
                        color: "#1f1f28"
                        font.pixelSize: 18
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: difficultySelector.highlightedIndex === index
                }
                onActivated: window.difficultyIndex = currentIndex
                Component.onCompleted: currentIndex = Math.max(0,
                                                              Math.min(model.length - 1, window.difficultyIndex))
                Connections {
                    target: window
                    function onDifficultyIndexChanged() {
                        if (!difficultySelector)
                            return
                        const clamped = Math.max(0,
                                                 Math.min(window.difficultyOptions.length - 1,
                                                          window.difficultyIndex))
                        if (difficultySelector.currentIndex !== clamped)
                            difficultySelector.currentIndex = clamped
                    }
                }
            }
        }

        PathView {
            id: heroCarousel
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: -parent.height * 0.14
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
                onTextChanged: {
                    window.heroNameInput = text
                    window.lobbyStatusMessage = ""
                    window.lobbyStatusIsError = false
                }
                placeholderText: qsTr("Type the name of your hero")
                font.pixelSize: 20
                font.family: signatureFont.name
                color: "#f8eaff"
                horizontalAlignment: Text.AlignHCenter
                focusPolicy: Qt.StrongFocus
                selectByMouse: true
                cursorVisible: true
                padding: 12
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                background: Rectangle {
                    radius: 22
                    color: "#1f2d35cc"
                    border.color: "#7ed1c2"
                    border.width: 2
                }
            }

            Text {
                text: window.lobbyStatusMessage
                font.pixelSize: 16
                font.family: signatureFont.name
                color: window.lobbyStatusIsError ? "#ffb3a7" : "#b8f0e5"
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                width: parent.width
                opacity: window.lobbyStatusMessage.length > 0 ? 1.0 : 0.0
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
                enabled: window.heroNameInput && window.heroNameInput.trim().length > 0
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

    Item {
        id: heroSummaryLayer
        anchors.fill: parent
        visible: sceneIndex === 6
        opacity: visible ? 1.0 : 0.0
        enabled: visible
        z: 4

        Rectangle {
            anchors.fill: parent
            color: "#050209d9"
        }

        Rectangle {
            id: heroSummaryPanel
            anchors.centerIn: parent
            width: parent.width * 0.75
            height: parent.height * 0.75
            radius: 28
            color: "#140d1f"
            border.color: "#7ed1c2"
            border.width: 2
            opacity: 0.95

            Column {
                anchors.fill: parent
                anchors.margins: 32
                spacing: 24

                Text {
                    text: qsTr("Hero Ready")
                    font.pixelSize: 30
                    font.family: signatureFont.name
                    color: "#f8eaff"
                    horizontalAlignment: Text.AlignHCenter
                    width: parent.width
                }

                Row {
                    width: parent.width
                    spacing: 40

                    MouseArea {
                        id: inventoryTriggerArea
                        anchors.verticalCenter: parent.verticalCenter
                        width: 140
                        height: heroSummaryPanel.height * 0.45
                        cursorShape: Qt.PointingHandCursor
                        onClicked: window.inventoryOverlayVisible = true
                        hoverEnabled: true

                        Rectangle {
                            anchors.fill: parent
                            radius: 12
                            color: inventoryTriggerArea.containsMouse ? "#ffffff11" : "transparent"
                            border.color: "#d8b6ff55"
                            border.width: 1
                        }

                        Column {
                            anchors.centerIn: parent
                            spacing: 6
                            width: parent.width
                            z: 1

                            Image {
                                id: inventoryIcon
                                source: "qrc:/RuneboundMagic/assets/images/Inventory/iventory.png"
                                width: 96
                                height: 96
                                anchors.horizontalCenter: parent.horizontalCenter
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                            }

                            Text {
                                text: qsTr("Inventory")
                                font.pixelSize: 20
                                font.family: signatureFont.name
                                color: "#b8f0e5"
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width * 0.35
                        height: heroSummaryPanel.height * 0.45
                        radius: 18
                        color: "#1a1324"
                        border.color: "#d8b6ff"
                        border.width: 2
                        z: 1

                        Image {
                            anchors.fill: parent
                            anchors.margins: 12
                            source: selectedHeroData && selectedHeroData.cardSource
                                    ? selectedHeroData.cardSource
                                    : ""
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        width: parent.width * 0.45

                        Text {
                            text: heroNameInput && heroNameInput.length
                                  ? qsTr("Chosen Name: %1").arg(heroNameInput)
                                  : qsTr("Chosen Name: %1").arg(selectedHeroName)
                            font.pixelSize: 22
                            font.family: signatureFont.name
                            color: "#b8f0e5"
                            wrapMode: Text.Wrap
                        }

                        Text {
                            text: qsTr("Hero: %1").arg(selectedHeroName || qsTr("Unknown"))
                            font.pixelSize: 22
                            font.family: signatureFont.name
                            color: "#b8f0e5"
                        }

                        Text {
                            text: qsTr("Difficulty: %1").arg(window.currentDifficulty || window.difficultyOptions[0])
                            font.pixelSize: 20
                            font.family: signatureFont.name
                            color: "#ffd166"
                        }

                        Column {
                            spacing: 6

                            Text {
                                text: qsTr("Health: %1").arg(selectedHeroData && selectedHeroData.health !== undefined
                                                            ? selectedHeroData.health : 0)
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#f8eaff"
                            }
                            Text {
                                text: qsTr("Mana: %1").arg(selectedHeroData && selectedHeroData.mana !== undefined
                                                          ? selectedHeroData.mana : 0)
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#f8eaff"
                            }
                            Text {
                                text: qsTr("Power: %1").arg(selectedHeroData && selectedHeroData.power !== undefined
                                                           ? selectedHeroData.power : 0)
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#f8eaff"
                            }
                            Text {
                                text: qsTr("Element: %1").arg(selectedHeroData && selectedHeroData.element
                                                              ? selectedHeroData.element
                                                              : qsTr("Unknown"))
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#f8eaff"
                            }
                        }
                    }
                }

                Text {
                    text: window.lobbyStatusMessage
                    font.pixelSize: 16
                    font.family: signatureFont.name
                    color: window.lobbyStatusIsError ? "#ffb3a7" : "#b8f0e5"
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    width: parent.width
                    opacity: window.lobbyStatusMessage.length ? 1.0 : 0.0
                }

                Row {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 32

                    Button {
                        id: changeHeroButton
                        text: qsTr("Change Hero")
                        width: 200
                        height: 52
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            radius: 26
                            color: "#1f2d35"
                            border.color: "#7ed1c2"
                            border.width: 2
                        }
                        contentItem: Text {
                            text: changeHeroButton.text
                            font.pixelSize: 22
                            font.family: signatureFont.name
                            color: "#b8f0e5"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: returnToLobbySelection()
                    }

                    Button {
                        id: battleButton
                        text: qsTr("Start Battle")
                        width: 200
                        height: 52
                        enabled: !!selectedHeroData
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            radius: 26
                            color: "#513860"
                            border.color: "#d8b6ff"
                            border.width: 2
                        }
                        contentItem: Text {
                            text: battleButton.text
                            font.pixelSize: 22
                            font.family: signatureFont.name
                            color: "#f8eaff"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: startBattle()
                    }
                }
            }
        }

        Item {
            id: inventoryOverlay
            anchors.fill: parent
            visible: window.inventoryOverlayVisible
            opacity: visible ? 1.0 : 0.0
            enabled: visible
            z: 6

            Rectangle {
                anchors.fill: parent
                color: "#030207d0"
            }

            Rectangle {
                id: inventoryPanel
                anchors.centerIn: parent
                width: heroSummaryPanel.width
                height: heroSummaryPanel.height
                radius: 28
                color: "#0f0a15"
                border.color: "#d8b6ff"
                border.width: 2

                Item {
                    anchors.fill: parent
                    anchors.margins: 32

                    Row {
                        id: inventoryHeader
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 16

                        Text {
                            text: qsTr("Hero Inventory")
                            font.pixelSize: 30
                            font.family: signatureFont.name
                            color: "#f8eaff"
                            horizontalAlignment: Text.AlignLeft
                            width: parent.width * 0.7
                        }
                        Button {
                            id: closeInventoryButton
                            text: qsTr("Close")
                            width: 140
                            height: 48
                            focusPolicy: Qt.NoFocus
                            background: Rectangle {
                                radius: 22
                                color: "#190f28"
                                border.color: "#7ed1c2"
                                border.width: 2
                            }
                            contentItem: Text {
                                text: closeInventoryButton.text
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#b8f0e5"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                            onClicked: window.inventoryOverlayVisible = false
                        }
                    }

                    Flickable {
                        id: inventoryFlick
                        anchors.top: inventoryHeader.bottom
                        anchors.topMargin: 18
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        contentWidth: width
                        contentHeight: inventoryContent.implicitHeight
                        clip: true

                        Column {
                            id: inventoryContent
                            width: inventoryFlick.width
                            spacing: 12

                            Repeater {
                                model: window.inventoryCategories
                                delegate: Row {
                                    spacing: 18
                                    width: inventoryContent.width
                                    property string categoryName: modelData

                                    Text {
                                        text: categoryName
                                        font.pixelSize: 18
                                        font.family: signatureFont.name
                                        color: "#ffd166"
                                        width: inventoryContent.width * 0.25
                                    }

                                    Row {
                                        spacing: 12
                                        Repeater {
                                            model: window.inventorySlotsPerRow
                                            delegate: Rectangle {
                                                width: 64
                                                height: 64
                                                radius: 8
                                                color: "#b89c5a22"
                                                border.color: "#c9ad6f"
                                                border.width: 2
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: typeof firestore !== "undefined" ? firestore : null
        function onDocumentCreated(collectionPath, documentName) {
            if (collectionPath !== "heroSelections")
                return
            lobbyStatusIsError = false
            lobbyStatusMessage = qsTr("Selection saved successfully!")
            console.log("✅ Firestore document created:", documentName)
        }
        function onLastErrorChanged() {
            if (!firestore || !firestore.lastError || firestore.lastError.length === 0)
                return
            lobbyStatusIsError = true
            lobbyStatusMessage = firestore.lastError
            console.log("⚠️ Firestore error:", firestore.lastError)
        }
    }

    MediaPlayer {
        id: introTrack
        source: "qrc:/RuneboundMagic/assets/music/soundtrack.mp3"
        autoPlay: true
        loops: MediaPlayer.Infinite
        audioOutput: introOutput

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
        source: "qrc:/RuneboundMagic/assets/sounds/1.mp3"
        autoPlay: false
        audioOutput: introCueOutput

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
        source: "qrc:/RuneboundMagic/assets/sounds/2.mp3"
        autoPlay: false
        audioOutput: wizardOutput

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
        Component.onCompleted: console.log("WizardCue ready, source:", source)
    }

    MediaPlayer {
        id: guardianCue
        source: "qrc:/RuneboundMagic/assets/sounds/3.mp3"
        autoPlay: false
        audioOutput: guardianOutput

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
        source: "qrc:/RuneboundMagic/assets/sounds/4.mp3"
        autoPlay: false
        audioOutput: finaleOutput

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
        if (introCueOutput.muted) {
            console.log("IntroCueOutput muted before play, unmuting.")
            introCueOutput.muted = false
        }
        if (introCueOutput.volume < 0.5) {
            introCueOutput.volume = 0.9
            console.log("IntroCueOutput volume reset to", introCueOutput.volume)
        }
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

        if (wizardOutput.muted) {
            console.log("WizardOutput muted before play, unmuting.")
            wizardOutput.muted = false
        }
        if (wizardOutput.volume < 0.99) {
            wizardOutput.volume = 1.0
            console.log("WizardOutput volume reset to", wizardOutput.volume)
        }

        wizardCue.stop()
        console.log("WizardCue status before play:", wizardCue.mediaStatus,
                    "state:", wizardCue.playbackState,
                    "error:", wizardCue.error, "hasAudio:", wizardCue.hasAudio)
        wizardCue.play()
        console.log("WizardCue play() called, new state:", wizardCue.playbackState)
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

        if (guardianOutput.muted) {
            console.log("GuardianOutput muted before play, unmuting.")
            guardianOutput.muted = false
        }
        if (guardianOutput.volume < 0.99) {
            guardianOutput.volume = 1.0
            console.log("GuardianOutput volume reset to", guardianOutput.volume)
        }

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
        currentHeroHealth = hero.health !== undefined ? hero.health : 0
        currentHeroMana = hero.mana !== undefined ? hero.mana : 0
        currentHeroPower = hero.power !== undefined ? hero.power : 0
        currentHeroElement = hero.element !== undefined && hero.element.length
                             ? hero.element
                             : qsTr("Unknown")
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
        if (!hero) {
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Please pick a hero before saving.")
            return
        }

        const enteredName = heroNameInput ? heroNameInput.trim() : ""
        if (!enteredName.length) {
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Enter the hero name before saving.")
            if (heroNameField)
                heroNameField.forceActiveFocus()
            return
        }

        selectedHeroIndex = heroCarousel.currentIndex
        selectedHeroData = hero
        selectedHeroName = hero.name
        heroNameInput = enteredName

        const hasFirestore = typeof firestore !== "undefined" && firestore !== null
        if (!hasFirestore || typeof firestore.createDocument !== "function") {
            console.log("⚠️ Firestore service is unavailable in QML context.")
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Database service is not available.")
            return
        }

        if (!firestore.ready) {
            console.log("⚠️ Firestore configuration incomplete or not ready.")
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Unable to connect to the database. Try again later.")
            return
        }

        const heroStats = {
            health: hero.health !== undefined ? hero.health : 0,
            mana: hero.mana !== undefined ? hero.mana : 0,
            power: hero.power !== undefined ? hero.power : 0,
            element: hero.element !== undefined && hero.element.length ? hero.element : qsTr("Unknown")
        }

        const payload = {
            userName: enteredName,
            heroId: hero.heroId,
            heroName: hero.name,
            difficulty: window.currentDifficulty || window.difficultyOptions[0],
            stats: heroStats,
            savedAt: new Date().toISOString()
        }

        lobbyStatusIsError = false
        lobbyStatusMessage = qsTr("Saving selection...")
        firestore.createDocument("heroSelections", payload)
        console.log("✅ Selected hero:", hero.name, "for player:", enteredName)
        showHeroSummary()
    }

    function showHeroSummary() {
        sceneIndex = 6
        inventoryOverlayVisible = false
    }

    function returnToLobbySelection() {
        sceneIndex = 5
        inventoryOverlayVisible = false
        if (selectedHeroIndex >= 0 && heroCarousel)
            heroCarousel.currentIndex = selectedHeroIndex
        updateHeroDetails()
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
        if (finaleOutput.muted) {
            console.log("FinaleOutput muted before play, unmuting.")
            finaleOutput.muted = false
        }
        if (finaleOutput.volume < 0.99) {
            finaleOutput.volume = 1.0
            console.log("FinaleOutput volume reset to", finaleOutput.volume)
        }
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
        lobbyStatusMessage = ""
        lobbyStatusIsError = false
        difficultyIndex = 1
        inventoryOverlayVisible = false
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
