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
    property string currentUserId: ""
    property var inventoryItems: []
    property bool savedHeroesOverlayVisible: false
    property bool savedUsersLoading: false
    property var savedUserList: []
    property var inventoryCategories: [
        { title: qsTr("Champions"), type: "hero" },
        { title: qsTr("Weapons"), type: "weapon" },
        { title: qsTr("Armor"), type: "armor" },
        { title: qsTr("Shields"), type: "shield" },
        { title: qsTr("Accessories"), type: "accessory" },
        { title: qsTr("Consumables"), type: "consumable" },
        { title: qsTr("Spells & Scrolls"), type: "spell" },
        { title: qsTr("Runes & Gems"), type: "rune" },
        { title: qsTr("Crafting Materials"), type: "material" },
        { title: qsTr("Quest Items"), type: "quest" },
        { title: qsTr("Gold & Currency"), type: "currency" }
    ]
    property int inventorySlotsPerRow: 5
    property int match3Rows: 8
    property int match3Columns: 5
    property real match3BoardWidthPx: 1000
    property real match3BoardHeightPx: 1500
    property real match3BoardPaddingPx: 50
    property string match3OpponentCardSource: "qrc:/RuneboundMagic/assets/images/heroes_cards/black _magician.png"
    property var match3Grid: []
    property bool match3Busy: false
    property int match3SelectedRow: -1
    property int match3SelectedColumn: -1
    property int match3HeroScore: 0
    property int match3OpponentScore: 0
    property int match3HeroHealth: 0
    property int match3HeroMaxHealth: 0
    property int match3OpponentHealth: 0
    property int match3OpponentMaxHealth: 120
    property int match3SkullDamage: 12
    property bool match3BattleOver: false
    property bool match3OpponentAutoPlay: true
    property bool match3OpponentPendingMove: false
    property bool match3CurrentCascadeIsOpponent: false
    property string match3StatusMessage: ""
    property bool battleBoardReady: false
    property var match3TileTypes: [
        { id: "red", source: "qrc:/RuneboundMagic/assets/images/tiles/red_gem.png" },
        { id: "blue", source: "qrc:/RuneboundMagic/assets/images/tiles/blue_gem.png" },
        { id: "green", source: "qrc:/RuneboundMagic/assets/images/tiles/green_gem.png" },
        { id: "turquoise", source: "qrc:/RuneboundMagic/assets/images/tiles/turquoise_gem.png" },
        { id: "skull", source: "qrc:/RuneboundMagic/assets/images/tiles/skull.png" }
    ]

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

    ListModel {
        id: match3TileModel
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
            anchors.bottomMargin: lobbyBackdrop.height * 0.02
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
                height: 44
                text: window.heroNameInput
                onTextChanged: {
                    window.heroNameInput = text
                    window.lobbyStatusMessage = ""
                    window.lobbyStatusIsError = false
                }
                placeholderText: qsTr("Type the name of your hero")
                font.pixelSize: 18
                font.family: signatureFont.name
                color: "#f8eaff"
                horizontalAlignment: Text.AlignHCenter
                focusPolicy: Qt.StrongFocus
                selectByMouse: true
                cursorVisible: true
                padding: 8
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                background: Rectangle {
                    radius: 22
                    color: "#1f2d35cc"
                    border.color: "#7ed1c2"
                    border.width: 2
                }
            }

            Button {
                id: savedHeroesButton
                text: qsTr("Saved Heroes")
                width: parent.width
                height: 48
                focusPolicy: Qt.NoFocus
                background: Rectangle {
                    radius: 22
                    color: "#1f2d35"
                    border.color: "#7ed1c2"
                    border.width: 2
                }
                contentItem: Text {
                    text: savedHeroesButton.text
                    font.pixelSize: 20
                    font.family: signatureFont.name
                    color: "#b8f0e5"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                onClicked: openSavedHeroesOverlay()
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
                        onClicked: window.openInventoryOverlay()
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
    }

    Item {
        id: battleSceneLayer
        anchors.fill: parent
        visible: sceneIndex === 7
        opacity: visible ? 1.0 : 0.0
        enabled: visible
        z: 4

        Image {
            anchors.fill: parent
            source: "qrc:/RuneboundMagic/assets/images/intro/MysticalTempleRuins.png"
            fillMode: Image.PreserveAspectCrop
            smooth: true
            opacity: 0.35
        }

        Rectangle {
            anchors.fill: parent
            color: "#04030ad9"
        }

        Button {
            id: exitBattleButton
            anchors.left: parent.left
            anchors.leftMargin: 32
            anchors.top: parent.top
            anchors.topMargin: 32
            text: qsTr("Back to Summary")
            width: 180
            height: 48
            focusPolicy: Qt.NoFocus
            background: Rectangle {
                radius: 24
                color: "#1f2d35"
                border.color: "#7ed1c2"
                border.width: 2
            }
            contentItem: Text {
                text: exitBattleButton.text
                font.pixelSize: 18
                font.family: signatureFont.name
                color: "#b8f0e5"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: showHeroSummary()
        }

        Row {
            id: battleDisplayRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: parent.height * 0.02
            spacing: Math.min(parent.width * 0.04, 60)
            z: 2

            Item {
                id: battleHeroCard
                width: boardContainer.width * 0.65
                height: width * 1.45
                Rectangle {
                    anchors.fill: parent
                    radius: 18
                    color: "#00000066"
                    border.color: "#d8b6ff66"
                    border.width: 1
                }
                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: selectedHeroData && selectedHeroData.cardSource ? selectedHeroData.cardSource : ""
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }

            Item {
                id: boardContainer
                property real boardAspect: window.match3BoardHeightPx / window.match3BoardWidthPx
                width: Math.min(battleSceneLayer.width * 0.42, battleSceneLayer.height * 0.8 / boardAspect)
                height: width * boardAspect
                property real boardScale: width / window.match3BoardWidthPx

                Image {
                    id: battleBoardImage
                    anchors.centerIn: parent
                    width: parent.width
                    height: parent.height
                    source: "qrc:/RuneboundMagic/assets/images/Board/board.png"
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }

                Item {
                    id: tileArea
                    anchors.centerIn: parent
                    property real usableWidth: (window.match3BoardWidthPx - window.match3BoardPaddingPx * 2) * boardContainer.boardScale
                    property real usableHeight: (window.match3BoardHeightPx - window.match3BoardPaddingPx * 2) * boardContainer.boardScale
                    width: usableWidth
                    height: usableHeight
                    clip: true
                    z: 2
                    visible: battleBoardReady

                    Repeater {
                        model: match3TileModel
                        delegate: Item {
                            property int cellRow: tileRow
                            property int cellColumn: tileColumn
                            required property int tileRow
                            required property int tileColumn
                            required property string tileSource
                            width: tileArea.width / window.match3Columns
                            height: tileArea.height / window.match3Rows
                            x: tileColumn * width
                            y: tileRow * height
                            Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }
                            Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.InOutQuad } }

                            Rectangle {
                                anchors.fill: parent
                                color: "#00000055"
                                border.color: "#00000088"
                                border.width: 1
                                radius: 6
                            }

                            Image {
                                anchors.centerIn: parent
                                width: parent.width * 0.9
                                height: width
                                source: "qrc:/RuneboundMagic/assets/images/circle.png"
                                visible: window.match3SelectedRow === cellRow && window.match3SelectedColumn === cellColumn || tileInputArea.pressed
                                opacity: visible ? 0.95 : 0.0
                                Behavior on opacity { NumberAnimation { duration: 120; easing.type: Easing.InOutQuad } }
                                z: 1
                            }

                            Image {
                                anchors.fill: parent
                                source: tileSource
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: tileSource && tileSource.length
                            }

                            MouseArea {
                                id: tileInputArea
                                anchors.fill: parent
                                enabled: battleBoardReady && !window.match3Busy && !window.match3BattleOver
                                cursorShape: Qt.PointingHandCursor
                                property real pressX: 0
                                property real pressY: 0
                                property bool dragCandidate: false
                                readonly property real dragThreshold: 18
                                onPressed: function(mouse) {
                                    pressX = mouse.x
                                    pressY = mouse.y
                                    dragCandidate = false
                                }
                                onPositionChanged: function(mouse) {
                                    if (!enabled)
                                        return
                                    const dx = mouse.x - pressX
                                    const dy = mouse.y - pressY
                                    dragCandidate = Math.abs(dx) > dragThreshold || Math.abs(dy) > dragThreshold
                                }
                                onReleased: function(mouse) {
                                    if (!enabled)
                                        return
                                    const dx = mouse.x - pressX
                                    const dy = mouse.y - pressY
                                    if (Math.abs(dx) > dragThreshold || Math.abs(dy) > dragThreshold) {
                                        window.handleMatch3Drag(cellRow, cellColumn, dx, dy)
                                    } else {
                                        window.handleMatch3TileClick(cellRow, cellColumn)
                                    }
                                }
                                onCanceled: {
                                    window.handleMatch3TileClick(cellRow, cellColumn)
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: qsTr("Preparing battle...")
                    font.pixelSize: 22
                    font.family: signatureFont.name
                    color: "#f8eaff"
                    visible: !battleBoardReady
                }
            }

            Item {
                id: battleOpponentCard
                width: boardContainer.width * 0.65
                height: width * 1.45
                Rectangle {
                    anchors.fill: parent
                    radius: 18
                    color: "#00000066"
                    border.color: "#ffd16666"
                    border.width: 1
                }
                Image {
                    anchors.fill: parent
                    anchors.margins: 6
                    source: window.match3OpponentCardSource
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
            }
        }

        Row {
            id: battleStatsRow
            anchors.top: battleDisplayRow.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 60
            z: 2

            Column {
                spacing: 4
                Text {
                    text: selectedHeroName && selectedHeroName.length
                          ? qsTr("Hero: %1").arg(selectedHeroName)
                          : qsTr("Hero: --")
                    font.pixelSize: 18
                    font.family: signatureFont.name
                    color: "#f8eaff"
                }
                Text {
                    text: qsTr("Difficulty: %1").arg(window.currentDifficulty)
                    font.pixelSize: 16
                    font.family: signatureFont.name
                    color: "#ffd166"
                }
            }

            Column {
                spacing: 4
                Text {
                    text: qsTr("Hero Score: %1").arg(window.match3HeroScore)
                    font.pixelSize: 18
                    font.family: signatureFont.name
                    color: "#b8f0e5"
                }
                Text {
                    text: qsTr("Hero Health: %1 / %2").arg(window.match3HeroHealth).arg(window.match3HeroMaxHealth)
                    font.pixelSize: 16
                    font.family: signatureFont.name
                    color: "#ffb3a7"
                }
            }

            Column {
                spacing: 4
                Text {
                    text: qsTr("Magician Score: %1").arg(window.match3OpponentScore)
                    font.pixelSize: 18
                    font.family: signatureFont.name
                    color: "#b8f0e5"
                }
                Text {
                    text: qsTr("Magician Health: %1 / %2").arg(window.match3OpponentHealth).arg(window.match3OpponentMaxHealth)
                    font.pixelSize: 16
                    font.family: signatureFont.name
                    color: "#ffd166"
                }
            }
        }

        Text {
            anchors.top: battleStatsRow.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            text: window.match3StatusMessage
            font.pixelSize: 16
            font.family: signatureFont.name
            color: "#f8eaff"
            opacity: window.match3StatusMessage.length ? 1.0 : 0.0
        }
    }

    Item {
        id: overlayLayer
        anchors.fill: parent
        z: 6

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
                                    property var categoryData: modelData
                                    property var categoryItems: window.itemsForCategory(categoryData)
                                    property int slotCount: Math.max(window.inventorySlotsPerRow,
                                                                     categoryItems.length)

                                    Text {
                                        text: categoryData.title
                                        font.pixelSize: 18
                                        font.family: signatureFont.name
                                        color: "#ffd166"
                                        width: inventoryContent.width * 0.25
                                    }

                                    Row {
                                        spacing: 12
                                        Repeater {
                                            model: slotCount
                                            delegate: Rectangle {
                                                width: 72
                                                height: 72
                                                radius: 8
                                                property bool hasItem: index < categoryItems.length
                                                color: hasItem ? "#d3b77c33" : "#b89c5a22"
                                                border.color: "#c9ad6f"
                                                border.width: 2

                                                Column {
                                                    anchors.centerIn: parent
                                                    spacing: 4
                                                    visible: hasItem

                                                    Image {
                                                        width: 40
                                                        height: 40
                                                        anchors.horizontalCenter: parent.horizontalCenter
                                                        source: hasItem && categoryItems[index].icon
                                                                ? (categoryItems[index].icon.startsWith("qrc:/")
                                                                   ? categoryItems[index].icon
                                                                   : "qrc:/RuneboundMagic/" + categoryItems[index].icon)
                                                                : ""
                                                        fillMode: Image.PreserveAspectFit
                                                        visible: source && source.length
                                                    }

                                                    Text {
                                                        text: hasItem
                                                              ? (categoryItems[index].displayName
                                                                 ? categoryItems[index].displayName
                                                                 : categoryItems[index].itemId)
                                                              : ""
                                                        font.pixelSize: 11
                                                        font.family: signatureFont.name
                                                        color: "#f8eaff"
                                                        horizontalAlignment: Text.AlignHCenter
                                                        width: parent.width
                                                        wrapMode: Text.WordWrap
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
        }

        Item {
            id: savedHeroesOverlay
            anchors.fill: parent
            visible: savedHeroesOverlayVisible
            opacity: visible ? 1.0 : 0.0
            enabled: visible
            z: 8

        Rectangle {
            anchors.fill: parent
            color: "#020107d8"
        }

        Rectangle {
            id: savedHeroesPanel
            anchors.centerIn: parent
            width: parent.width * 0.7
            height: parent.height * 0.75
            radius: 24
            color: "#141022"
            border.color: "#7ed1c2"
            border.width: 2

            Column {
                anchors.fill: parent
                anchors.margins: 28
                spacing: 16

                Row {
                    width: parent.width
                    spacing: 16

                    Text {
                        text: qsTr("Saved Heroes")
                        font.pixelSize: 28
                        font.family: signatureFont.name
                        color: "#f8eaff"
                        width: parent.width * 0.7
                    }

                    Button {
                        id: savedHeroesCloseButton
                        text: qsTr("Close")
                        width: 120
                        height: 44
                        focusPolicy: Qt.NoFocus
                        background: Rectangle {
                            radius: 20
                            color: "#1f2d35"
                            border.color: "#7ed1c2"
                            border.width: 2
                        }
                        contentItem: Text {
                            text: savedHeroesCloseButton.text
                            font.pixelSize: 18
                            font.family: signatureFont.name
                            color: "#b8f0e5"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        onClicked: closeSavedHeroesOverlay()
                    }
                }

                Loader {
                    active: savedUsersLoading
                    sourceComponent: Item {
                        width: parent ? parent.width : 0
                        height: 40
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("Loading...")
                            font.pixelSize: 18
                            font.family: signatureFont.name
                            color: "#ffd166"
                        }
                    }
                }

                Flickable {
                    id: savedHeroesFlick
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.top: parent.top
                    anchors.topMargin: 96
                    contentWidth: width
                    contentHeight: savedHeroesColumn.implicitHeight
                    clip: true

                    Column {
                        id: savedHeroesColumn
                        width: savedHeroesFlick.width
                        spacing: 12

                        Repeater {
                            model: window.savedUserList
                            delegate: Rectangle {
                                width: savedHeroesColumn.width
                                height: 120
                                radius: 18
                                color: "#1d1430"
                                border.color: "#d8b6ff"
                                border.width: 1

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 16

                                    Image {
                                        width: 88
                                        height: 88
                                        fillMode: Image.PreserveAspectFit
                                        source: {
                                            const heroId = (modelData.profile && modelData.profile.heroId) ? modelData.profile.heroId : ""
                                            const hero = window.heroDataById(heroId)
                                            return hero && hero.cardSource ? hero.cardSource : ""
                                        }
                                    }

                                    Column {
                                        width: parent.width * 0.6
                                        spacing: 6

                                        Text {
                                            text: (modelData.profile && modelData.profile.heroName)
                                                  ? modelData.profile.heroName
                                                  : modelData.profile && modelData.profile.heroId
                                                    ? modelData.profile.heroId
                                                    : qsTr("Unknown Hero")
                                            font.pixelSize: 22
                                            font.family: signatureFont.name
                                            color: "#f8eaff"
                                        }

                                        Text {
                                            text: modelData.profile && modelData.profile.username
                                                  ? qsTr("Player: %1").arg(modelData.profile.username)
                                                  : ""
                                            font.pixelSize: 16
                                            font.family: signatureFont.name
                                            color: "#b8f0e5"
                                        }

                                        Text {
                                            text: modelData.profile && modelData.profile.difficulty
                                                  ? qsTr("Difficulty: %1").arg(modelData.profile.difficulty)
                                                  : ""
                                            font.pixelSize: 16
                                            font.family: signatureFont.name
                                            color: "#ffd166"
                                        }
                                    }

                                    Button {
                                        id: loadSavedHeroButton
                                        text: qsTr("Load")
                                        width: 110
                                        height: 44
                                        focusPolicy: Qt.NoFocus
                                        background: Rectangle {
                                            radius: 20
                                            color: "#513860"
                                            border.color: "#d8b6ff"
                                            border.width: 2
                                        }
                                        contentItem: Text {
                                            text: loadSavedHeroButton.text
                                            font.pixelSize: 18
                                            font.family: signatureFont.name
                                            color: "#f8eaff"
                                            horizontalAlignment: Text.AlignHCenter
                                            verticalAlignment: Text.AlignVCenter
                                        }
                                        onClicked: applySavedHero(modelData)
                                    }
                                }
                            }
                        }

                        Item {
                            width: 1
                            height: window.savedUserList.length === 0 && !savedUsersLoading ? 80 : 0
                            visible: window.savedUserList.length === 0 && !savedUsersLoading
                            Text {
                                anchors.centerIn: parent
                                text: qsTr("No saved heroes found.")
                                font.pixelSize: 18
                                font.family: signatureFont.name
                                color: "#b8f0e5"
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
            if (savedHeroesOverlayVisible)
                savedUsersLoading = false
        }
        function onDocumentsFetched(collectionPath, documents) {
            if (collectionPath === "users") {
                window.savedUsersLoading = false
                window.savedUserList = documents.map(function(entry) { return entry })
                return
            }
            if (!window.currentUserId || !window.currentUserId.length)
                return
            const expectedPath = "users/" + window.currentUserId + "/inventory"
            if (collectionPath.indexOf(expectedPath) !== 0)
                return
            window.inventoryItems = documents.map(function(entry) { return entry })
        }
        function onDocumentWritten(documentPath) {
            if (!window.currentUserId || !window.currentUserId.length)
                return
            const inventoryPrefix = "users/" + window.currentUserId + "/inventory/"
            if (documentPath.indexOf(inventoryPrefix) === 0)
                window.loadUserInventory()
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

    function heroDataByIndex(index) {
        if (index < 0 || !heroCardModel || heroCardModel.count === 0)
            return null
        return heroCardModel.get(index % heroCardModel.count)
    }

    function currentHeroData() {
        if (!heroCarousel || heroCardModel.count === 0)
            return null
        return heroCardModel.get(heroCarousel.currentIndex % heroCardModel.count)
    }

    function heroDataById(heroId) {
        if (!heroId || !heroCardModel)
            return null
        for (let i = 0; i < heroCardModel.count; ++i) {
            const hero = heroCardModel.get(i)
            if (hero.heroId === heroId)
                return hero
        }
        return null
    }

    function heroIndexById(heroId) {
        if (!heroId || !heroCardModel)
            return -1
        for (let i = 0; i < heroCardModel.count; ++i) {
            if (heroCardModel.get(i).heroId === heroId)
                return i
        }
        return -1
    }

    function difficultyIndexForName(name) {
        if (!name || !difficultyOptions || !difficultyOptions.length)
            return -1
        const lower = name.toLowerCase()
        for (let i = 0; i < difficultyOptions.length; ++i) {
            if (difficultyOptions[i].toLowerCase() === lower)
                return i
        }
        return -1
    }

    function normalizedUserId(name) {
        if (!name || !name.length)
            return ""
        const slug = name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "")
        if (slug.length > 0)
            return slug
        return "user-" + Math.floor(Date.now() / 1000)
    }

    function openInventoryOverlay() {
        if (!currentUserId || !currentUserId.length) {
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Save a hero before viewing inventory.")
            return
        }
        inventoryOverlayVisible = true
        loadUserInventory()
    }

    function openSavedHeroesOverlay() {
        if (!firestore || typeof firestore.listDocuments !== "function" || !firestore.ready) {
            lobbyStatusIsError = true
            lobbyStatusMessage = qsTr("⚠️ Database service is not available.")
            return
        }
        savedHeroesOverlayVisible = true
        savedUsersLoading = true
        savedUserList = []
        firestore.listDocuments("users")
    }

    function closeSavedHeroesOverlay() {
        savedHeroesOverlayVisible = false
        savedUsersLoading = false
    }

    function loadUserInventory() {
        if (!currentUserId || !currentUserId.length)
            return
        if (!firestore || typeof firestore.listDocuments !== "function")
            return
        firestore.listDocuments("users/" + currentUserId + "/inventory")
    }

    function itemsForCategory(category) {
        if (!category || !inventoryItems || inventoryItems.length === 0)
            return []
        const expectedType = category.type ? category.type.toLowerCase() : ""
        const expectedSlot = category.slot ? category.slot.toLowerCase() : ""
        return inventoryItems.filter(function(item) {
            if (!item)
                return false
            const itemType = item.type ? item.type.toLowerCase() : ""
            const itemSlot = item.slot ? item.slot.toLowerCase() : ""
            if (expectedType.length && itemType === expectedType)
                return true
            if (expectedSlot.length && itemSlot === expectedSlot)
                return true
            return false
        })
    }

    function applySavedHero(userDoc) {
        if (!userDoc)
            return
        const profile = userDoc.profile || {}
        const heroId = profile.heroId || userDoc.heroId || ""
        const username = profile.username || userDoc.userName || ""
        if (username && username.length)
            heroNameInput = username
        const docId = userDoc.id || normalizedUserId(username)
        if (docId && docId.length)
            currentUserId = docId
        const difficultyName = profile.difficulty || ""
        const difficultyIdx = difficultyIndexForName(difficultyName)
        if (difficultyIdx >= 0)
            difficultyIndex = difficultyIdx
        savedHeroesOverlayVisible = false
        savedUsersLoading = false
        const heroIndex = heroIndexById(heroId)
        if (heroIndex >= 0) {
            heroCarousel.currentIndex = heroIndex
            currentHeroIndex = heroIndex
            updateHeroDetails()
        }
        inventoryItems = []
        loadUserInventory()
        lobbyStatusIsError = false
        lobbyStatusMessage = qsTr("Loaded hero %1").arg(profile.heroName || heroId || username)
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

        const userId = normalizedUserId(enteredName)
        currentUserId = userId
        inventoryItems = []

        const heroStats = {
            health: hero.health !== undefined ? hero.health : 0,
            mana: hero.mana !== undefined ? hero.mana : 0,
            power: hero.power !== undefined ? hero.power : 0,
            element: hero.element !== undefined && hero.element.length ? hero.element : qsTr("Unknown")
        }
        const selectedDifficulty = window.currentDifficulty || window.difficultyOptions[0]
        const nowIso = new Date().toISOString()

        const payload = {
            userName: enteredName,
            heroId: hero.heroId,
            heroName: hero.name,
            difficulty: selectedDifficulty,
            stats: heroStats,
            savedAt: nowIso
        }

        lobbyStatusIsError = false
        lobbyStatusMessage = qsTr("Saving selection...")
        firestore.createDocument("heroSelections", payload)
        const heroInventoryEntry = {
            itemId: hero.heroId,
            displayName: hero.name,
            acquiredAt: nowIso,
            equipped: true,
            slot: "hero",
            type: "hero",
            icon: hero.cardSource
        }
        const inventoryWrites = [{
            documentId: hero.heroId,
            payload: heroInventoryEntry
        }]

        if (hero.heroId === "ranger") {
            inventoryWrites.push({
                documentId: "weapon_crossbow_aurora",
                payload: {
                    itemId: "weapon_crossbow_aurora",
                    displayName: qsTr("Aurora Repeater"),
                    acquiredAt: nowIso,
                    equipped: true,
                    slot: "weapon",
                    type: "weapon",
                    quantity: 1,
                    icon: "assets/images/weapons/crossbow.png"
                }
            })
        }
        if (hero.heroId === "mystical_priestess") {
            inventoryWrites.push({
                documentId: "weapon_rod_runewarden",
                payload: {
                    itemId: "weapon_rod_runewarden",
                    displayName: qsTr("Runewarden Rod"),
                    acquiredAt: nowIso,
                    equipped: true,
                    slot: "weapon",
                    type: "weapon",
                    quantity: 1,
                    icon: "assets/images/weapons/rod.png"
                }
            })
        }

        const userDocument = {
            profile: {
                username: enteredName,
                heroId: hero.heroId,
                heroName: hero.name,
                difficulty: selectedDifficulty,
                createdAt: nowIso,
                lastSelectionAt: nowIso,
                stats: heroStats
            }
        }
        firestore.setDocument("users/" + userId, userDocument)
        for (let i = 0; i < inventoryWrites.length; ++i) {
            const entry = inventoryWrites[i]
            firestore.setDocument("users/" + userId + "/inventory/" + entry.documentId, entry.payload)
        }
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

    function match3ModelIndex(row, column) {
        return row * match3Columns + column
    }

    function match3TileAt(row, column) {
        if (!match3Grid || row < 0 || row >= match3Rows || column < 0 || column >= match3Columns)
            return null
        if (!match3Grid[row])
            return null
        return match3Grid[row][column] || null
    }

    function setMatch3Tile(row, column, tile) {
        if (!match3Grid[row])
            match3Grid[row] = []
        match3Grid[row][column] = tile
    }

    function createRandomMatch3Tile(row, column, avoidTypes) {
        if (!match3TileTypes || match3TileTypes.length === 0)
            return null
        const maxAttempts = Math.max(match3TileTypes.length * 3, 10)
        let selected = null
        for (let attempt = 0; attempt < maxAttempts; ++attempt) {
            const candidate = match3TileTypes[Math.floor(Math.random() * match3TileTypes.length)]
            if (!avoidTypes || avoidTypes.indexOf(candidate.id) === -1) {
                selected = candidate
                break
            }
        }
        if (!selected)
            selected = match3TileTypes[Math.floor(Math.random() * match3TileTypes.length)]
        return {
            typeId: selected.id,
            source: selected.source,
            key: selected.id + "_" + Date.now() + "_" + Math.random().toString(36).slice(2)
        }
    }

    function syncMatch3Model() {
        const totalCells = match3Rows * match3Columns
        if (match3TileModel.count !== totalCells) {
            match3TileModel.clear()
            for (let row = 0; row < match3Rows; ++row) {
                for (let column = 0; column < match3Columns; ++column) {
                    const tile = match3TileAt(row, column)
                    match3TileModel.append({
                        tileRow: row,
                        tileColumn: column,
                        tileType: tile ? tile.typeId : "",
                        tileSource: tile ? tile.source : "",
                        tileKey: tile ? tile.key : ""
                    })
                }
            }
        } else {
            let index = 0
            for (let row = 0; row < match3Rows; ++row) {
                for (let column = 0; column < match3Columns; ++column) {
                    const tile = match3TileAt(row, column)
                    match3TileModel.set(index, {
                        tileRow: row,
                        tileColumn: column,
                        tileType: tile ? tile.typeId : "",
                        tileSource: tile ? tile.source : "",
                        tileKey: tile ? tile.key : ""
                    })
                    ++index
                }
            }
        }
        battleBoardReady = match3TileModel.count === totalCells
    }

    function clearMatch3Selection() {
        match3SelectedRow = -1
        match3SelectedColumn = -1
    }

    function match3TilesAreAdjacent(row1, column1, row2, column2) {
        return Math.abs(row1 - row2) + Math.abs(column1 - column2) === 1
    }

    function handleMatch3TileClick(row, column) {
        if (!battleBoardReady || match3Busy)
            return
        if (match3SelectedRow === -1 || match3SelectedColumn === -1) {
            match3SelectedRow = row
            match3SelectedColumn = column
            return
        }
        if (match3SelectedRow === row && match3SelectedColumn === column) {
            clearMatch3Selection()
            return
        }
        if (match3TilesAreAdjacent(match3SelectedRow, match3SelectedColumn, row, column)) {
            attemptMatch3Swap(match3SelectedRow, match3SelectedColumn, row, column)
        } else {
            match3SelectedRow = row
            match3SelectedColumn = column
        }
    }

    function attemptMatch3Swap(row1, column1, row2, column2, initiatedByOpponent) {
        const opponentMove = initiatedByOpponent === true
        if (!battleBoardReady || match3Busy)
            return false
        if (row2 < 0 || row2 >= match3Rows || column2 < 0 || column2 >= match3Columns)
            return false
        if (!match3TilesAreAdjacent(row1, column1, row2, column2))
            return false
        match3Busy = true
        swapMatch3Tiles(row1, column1, row2, column2)
        syncMatch3Model()
        const sourceRow = row1
        const sourceColumn = column1
        const targetRow = row2
        const targetColumn = column2
        const immediateMatches = findAllMatch3Matches()
        if (!immediateMatches.length) {
            swapMatch3Tiles(sourceRow, sourceColumn, targetRow, targetColumn)
            syncMatch3Model()
            match3Busy = false
            clearMatch3Selection()
            if (!opponentMove)
                match3StatusMessage = qsTr("No match. Try a different swap.")
            return false
        }
        match3CurrentCascadeIsOpponent = opponentMove
        if (!opponentMove)
            match3OpponentPendingMove = true
        clearMatch3Selection()
        const pendingMatches = immediateMatches.slice()
        Qt.callLater(function() {
            resolveMatch3Cascade(pendingMatches)
        })
        return true
    }

    function handleMatch3Drag(row, column, deltaX, deltaY) {
        if (!battleBoardReady || match3Busy)
            return
        const minDistance = 18
        const absX = Math.abs(deltaX)
        const absY = Math.abs(deltaY)
        if (absX < minDistance && absY < minDistance) {
            handleMatch3TileClick(row, column)
            return
        }
        let targetRow = row
        let targetColumn = column
        if (absX > absY)
            targetColumn += deltaX > 0 ? 1 : -1
        else
            targetRow += deltaY > 0 ? 1 : -1
        attemptMatch3Swap(row, column, targetRow, targetColumn)
    }

    function autoplayOpponentMove() {
        if (!match3OpponentAutoPlay || match3BattleOver || sceneIndex !== 7)
            return
        if (!battleBoardReady || match3Busy)
            return
        match3StatusMessage = qsTr("The Black Magician strikes back!")
        let attempts = match3Rows * match3Columns * 4
        while (attempts-- > 0) {
            const row = Math.floor(Math.random() * match3Rows)
            const column = Math.floor(Math.random() * match3Columns)
            const directions = [
                { dr: 1, dc: 0 },
                { dr: -1, dc: 0 },
                { dr: 0, dc: 1 },
                { dr: 0, dc: -1 }
            ]
            const dir = directions[Math.floor(Math.random() * directions.length)]
            const targetRow = row + dir.dr
            const targetColumn = column + dir.dc
            if (attemptMatch3Swap(row, column, targetRow, targetColumn, true))
                return
        }
    }

    function applySkullDamage(skullCount, initiatedByOpponent) {
        if (skullCount <= 0)
            return
        const damage = skullCount * match3SkullDamage
        match3HeroHealth = Math.max(0, match3HeroHealth - damage)
        match3StatusMessage = initiatedByOpponent
                              ? qsTr("The Black Magician's skulls hit you for %1 damage!").arg(damage)
                              : qsTr("Skulls explode! You take %1 damage.").arg(damage)
        if (match3HeroHealth <= 0)
            endMatch3Battle(false)
    }

    function endMatch3Battle(victory) {
        match3BattleOver = true
        match3Busy = false
        match3StatusMessage = victory ? qsTr("Victory!") : qsTr("Defeated by the Black Magician.")
    }

    function swapMatch3Tiles(row1, column1, row2, column2) {
        const temp = match3TileAt(row1, column1)
        setMatch3Tile(row1, column1, match3TileAt(row2, column2))
        setMatch3Tile(row2, column2, temp)
    }

    function findAllMatch3Matches() {
        const matches = {}
        // Horizontal check
        for (let row = 0; row < match3Rows; ++row) {
            let runType = ""
            let runStart = 0
            let runLength = 0
            for (let column = 0; column < match3Columns; ++column) {
                const tile = match3TileAt(row, column)
                const tileType = tile ? tile.typeId : ""
                if (tileType && tileType === runType) {
                    runLength += 1
                } else {
                    if (runType && runLength >= 3) {
                        for (let offset = 0; offset < runLength; ++offset)
                            matches[row + "," + (runStart + offset)] = true
                    }
                    runType = tileType
                    runStart = column
                    runLength = tileType ? 1 : 0
                }
            }
            if (runType && runLength >= 3) {
                for (let offset = 0; offset < runLength; ++offset)
                    matches[row + "," + (runStart + offset)] = true
            }
        }
        // Vertical check
        for (let column = 0; column < match3Columns; ++column) {
            let runType = ""
            let runStart = 0
            let runLength = 0
            for (let row = 0; row < match3Rows; ++row) {
                const tile = match3TileAt(row, column)
                const tileType = tile ? tile.typeId : ""
                if (tileType && tileType === runType) {
                    runLength += 1
                } else {
                    if (runType && runLength >= 3) {
                        for (let offset = 0; offset < runLength; ++offset)
                            matches[(runStart + offset) + "," + column] = true
                    }
                    runType = tileType
                    runStart = row
                    runLength = tileType ? 1 : 0
                }
            }
            if (runType && runLength >= 3) {
                for (let offset = 0; offset < runLength; ++offset)
                    matches[(runStart + offset) + "," + column] = true
            }
        }
        return Object.keys(matches).map(function(key) {
            const parts = key.split(",")
            return { row: parseInt(parts[0]), column: parseInt(parts[1]) }
        })
    }

    function clearMatchedTiles(matchList, initiatedByOpponent) {
        if (!matchList || !matchList.length)
            return 0
        let skullCount = 0
        for (let i = 0; i < matchList.length; ++i) {
            const entry = matchList[i]
            const tile = match3TileAt(entry.row, entry.column)
            if (tile) {
                if (initiatedByOpponent)
                    match3OpponentScore += 10
                else
                    match3HeroScore += 10
                if (tile.typeId === "skull")
                    skullCount += 1
            }
            setMatch3Tile(entry.row, entry.column, null)
        }
        if (skullCount > 0)
            applySkullDamage(skullCount, initiatedByOpponent)
        return matchList.length
    }

    function collapseMatch3Columns() {
        for (let column = 0; column < match3Columns; ++column) {
            let writeRow = match3Rows - 1
            for (let row = match3Rows - 1; row >= 0; --row) {
                const tile = match3TileAt(row, column)
                if (tile) {
                    if (writeRow !== row) {
                        setMatch3Tile(writeRow, column, tile)
                        setMatch3Tile(row, column, null)
                    }
                    writeRow -= 1
                }
            }
            while (writeRow >= 0) {
                const avoid = []
                if (writeRow <= match3Rows - 3) {
                    const belowOne = match3TileAt(writeRow + 1, column)
                    const belowTwo = match3TileAt(writeRow + 2, column)
                    if (belowOne && belowTwo && belowOne.typeId === belowTwo.typeId)
                        avoid.push(belowOne.typeId)
                }
                const newTile = createRandomMatch3Tile(writeRow, column, avoid)
                setMatch3Tile(writeRow, column, newTile)
                writeRow -= 1
            }
        }
    }

    function resolveMatch3Cascade(initialMatches) {
        if (match3BattleOver)
            return
        const matches = initialMatches && initialMatches.length ? initialMatches : findAllMatch3Matches()
        if (!matches.length) {
            match3Busy = false
            if (match3BattleOver)
                return
            if (match3OpponentPendingMove && match3OpponentAutoPlay) {
                match3OpponentPendingMove = false
                match3CurrentCascadeIsOpponent = false
                Qt.callLater(function() { autoplayOpponentMove() })
            } else {
                match3OpponentPendingMove = false
                match3CurrentCascadeIsOpponent = false
                match3StatusMessage = qsTr("Your move! Beware the skulls.")
            }
            return
        }
        clearMatchedTiles(matches, match3CurrentCascadeIsOpponent)
        if (match3BattleOver) {
            match3Busy = false
            return
        }
        collapseMatch3Columns()
        syncMatch3Model()
        Qt.callLater(function() {
            resolveMatch3Cascade(findAllMatch3Matches())
        })
    }

    function initializeMatch3Board() {
        battleBoardReady = false
        match3Busy = false
        match3SelectedRow = -1
        match3SelectedColumn = -1
        match3Grid = []
        match3TileModel.clear()
        if (!match3TileTypes || match3TileTypes.length === 0) {
            console.warn("⚠️ No tile definitions available for the match-3 board.")
            return
        }
        for (let row = 0; row < match3Rows; ++row) {
            match3Grid[row] = []
            for (let column = 0; column < match3Columns; ++column) {
                const avoidTypes = []
                if (column >= 2) {
                    const leftOne = match3TileAt(row, column - 1)
                    const leftTwo = match3TileAt(row, column - 2)
                    if (leftOne && leftTwo && leftOne.typeId === leftTwo.typeId)
                        avoidTypes.push(leftOne.typeId)
                }
                if (row >= 2) {
                    const upOne = match3TileAt(row - 1, column)
                    const upTwo = match3TileAt(row - 2, column)
                    if (upOne && upTwo && upOne.typeId === upTwo.typeId)
                        avoidTypes.push(upOne.typeId)
                }
                const tileDefinition = createRandomMatch3Tile(row, column, avoidTypes)
                setMatch3Tile(row, column, tileDefinition)
            }
        }
        syncMatch3Model()
        battleBoardReady = true
    }

    function startBattle() {
        if (selectedHeroIndex < 0 || !selectedHeroData) {
            console.log("⚠️ Please select a hero before starting the battle.")
            return
        }
        console.log("🚀 Starting battle with:", selectedHeroData.name, "(", selectedHeroData.heroId, ")")
        match3Busy = false
        match3BattleOver = false
        match3StatusMessage = qsTr("Your move! Match gems to attack.")
        match3OpponentPendingMove = false
        match3CurrentCascadeIsOpponent = false
        match3HeroScore = 0
        match3OpponentScore = 0
        match3HeroMaxHealth = selectedHeroData && selectedHeroData.health !== undefined ? selectedHeroData.health : 100
        match3HeroHealth = match3HeroMaxHealth
        match3OpponentHealth = match3OpponentMaxHealth
        clearMatch3Selection()
        initializeMatch3Board()
        if (!battleBoardReady) {
            console.warn("⚠️ Failed to initialize the match-3 board.")
            return
        }
        inventoryOverlayVisible = false
        savedHeroesOverlayVisible = false
        sceneIndex = 7
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
        savedHeroesOverlayVisible = false
        savedUsersLoading = false
        savedUserList = []
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
