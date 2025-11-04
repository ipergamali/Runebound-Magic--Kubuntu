cmake_minimum_required(VERSION 3.16)
project(RuneboundMagic LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2 Multimedia)

qt_add_executable(RuneboundMagicApp
    src/main.cpp
)

qt_add_qml_module(RuneboundMagicApp
    URI RuneboundMagic
    VERSION 1.0
    QML_FILES
        src/main.qml
    RESOURCES
        assets/images/logo/logo.png
        assets/images/intro/MysticalTempleRuins.png
        assets/sounds/1.mp3
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
)
