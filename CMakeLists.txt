# Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
# SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

cmake_minimum_required(VERSION 3.16)
project(calqlatr LANGUAGES CXX)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)   # Включает автоматическую компиляцию ресурсов

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)
find_package(Python3 REQUIRED COMPONENTS Interpreter Development)

qt_standard_project_setup(REQUIRES 6.9)

qt_add_executable(calqlatr WIN32
    main.cpp
)

target_link_libraries(calqlatr PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Python3::Python
)

qt_add_qml_module(calqlatr
    URI calqlatr
    QML_FILES
        "Main.qml"
        "content/ApplicationState.qml"
        "content/NumberPad.qml"
        "content/CalculatorButton.qml"
        "content/BackspaceButton.qml"
        "content/calculator.js"
        "content/NumberPad_1.qml"
    RESOURCES
        "content/images/backspace.svg"
        "content/images/backspace_fill.svg"
        SOURCES AppInfo.h
        RESOURCES
        RESOURCES Backend.py Interface.py
)

if(WIN32)
    target_sources(calqlatr PRIVATE windows/calqlatr.rc)
endif()

# Копируем Python-скрипт в папку сборки
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/Interface.py
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Interface.py
    COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_SOURCE_DIR}/Backend.py
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/Backend.py
    COMMENT "Копирование бэкенда на Python..."
)

install(TARGETS calqlatr
    BUNDLE  DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)

qt_generate_deploy_qml_app_script(
    TARGET calqlatr
    OUTPUT_SCRIPT deploy_script
    MACOS_BUNDLE_POST_BUILD
    NO_UNSUPPORTED_PLATFORM_ERROR
    DEPLOY_USER_QML_MODULES_ON_UNSUPPORTED_PLATFORM
)
install(SCRIPT ${deploy_script})
