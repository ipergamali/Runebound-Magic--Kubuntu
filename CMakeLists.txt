cmake_minimum_required(VERSION 3.16)
project(RuneboundMagic LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Multimedia Network)

qt_add_executable(RuneboundMagicApp
    src/main.cpp
    src/firebasefirestore.cpp
)

qt_add_qml_module(RuneboundMagicApp
    URI RuneboundMagic
    VERSION 1.0
    QML_FILES
        src/main.qml
    RESOURCES
        assets/images/logo/logo.png
        assets/images/intro/MysticalTempleRuins.png
        assets/images/heroes/black_wizard.png
        assets/images/heroes/peiestsess.png
        assets/images/lobby/Game_Lobby.png
        assets/images/Board/board.png
        assets/images/heroes_cards/mage.png
        assets/images/heroes_cards/warrior.png
        assets/images/heroes_cards/ranger.png
        assets/images/heroes_cards/mystical_priestess.png
        "assets/images/heroes_cards/black _magician.png"
        assets/images/Armour/boots/boots.png
        assets/images/Armour/boots/boots_b.png
        assets/images/Armour/boots/buttos_c.png
        assets/images/Armour/chest/chest.png
        assets/images/Armour/chest/chest_b.png
        assets/images/Armour/chest/chest-women.png
        assets/images/Armour/chest/chest-women_b.png
        assets/images/Armour/gloves/gloves.png
        assets/images/Armour/gloves/gloves_b.png
        assets/images/Armour/helmet/helmet.png
        assets/images/Armour/helmet/helmet_b.png
        assets/images/Accessories/amulet.png
        assets/images/Accessories/amulet_b.png
        assets/images/Accessories/belt.png
        assets/images/Accessories/beld_b.png
        assets/images/Accessories/ring.png
        assets/images/shield/shield.png
        assets/images/shield/shield_b.png
        assets/images/weapons/crossbow.png
        assets/images/weapons/mage_staff.png
        assets/images/weapons/rod.png
        assets/images/weapons/shord.png
        assets/images/Inventory/iventory.png
        assets/images/tiles/red_gem.png
        assets/images/tiles/blue_gem.png
        assets/images/tiles/turquoise_gem.png
        assets/images/tiles/green_gem.png
        assets/images/tiles/skull.png
        assets/images/circle.png
        assets/sounds/1.mp3
        assets/sounds/2.mp3
        assets/sounds/3.mp3
        assets/sounds/4.mp3
        assets/music/soundtrack.mp3
        assets/fonts/whispering-signature-personal-use/WhisperingSignature.ttf
)

target_link_libraries(RuneboundMagicApp
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Multimedia
        Qt6::Network
)
