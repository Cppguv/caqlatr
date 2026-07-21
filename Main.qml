// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import Qt.labs.platform
import QtQuick.Dialogs as Dialogs
import Interface 1.0

Controls.ApplicationWindow {
    id: mainRoot
    visible: true
    width: 320
    height: 480
    minimumWidth: Math.max(numberPad.portraitModeWidth, premisesText.minWidth) + root.margin * 2
    minimumHeight: premisesText.minHeight + numberPad.height + targetLine.height + root.margin * 7
    color: root.backgroundColor

    // 1. Хранилище последнего активного элемента
    property var lastFocusedTextArea: premises

    MenuBar {
        id: menuBar
        Menu {
            id: fileMenu
            title: qsTr("Файл")
            // Action { text: qsTr("Открыть") }
            // Action { text: qsTr("Выход") }
            // icon.name: "document-open"
            // onClicked: fileOpenDialog.open()
            MenuItem {
                text: qsTr("Открыть")
                icon.name: "document-open"
                onTriggered: fileOpenDialog.open()
            }

            MenuItem {
                text: qsTr("Сохранить")
                icon.name: "document-save"
                onTriggered: fileSaveDialog.open()
            }

            MenuItem {
                text: qsTr("Выход")
                onTriggered: quitOut()
            }
        }

        Menu {
            id: helpMenu
            title: qsTr("Справка")
            MenuItem {
                text: qsTr("Помощь")
                //onTriggered: aboutDialog.open()
            }
            MenuItem {
                text: qsTr("О программе...")
                onTriggered: aboutDialog.open()
            }
        }
    }

    FileDialog {
        id: fileOpenDialog
        title: "Select an image file"
        folder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)
        nameFilters: ["Image files (*.png *.jpeg *.jpg)",]
        onAccepted: {
            image.source = fileOpenDialog.fileUrl;
        }
    }

    Controls.Dialog {
        id: aboutDialog
        title: "О программе"
        anchors.centerIn: parent
        modal: true
        width: 370

        // Настройка кнопок (Ok)
        standardButtons: Controls.Dialog.Ok

        contentItem: Column {
            spacing: 15
            topPadding: 10
            bottomPadding: 10

            Text {
                text: appInfo.name
                font.pixelSize: 16
                //font.bold: true
                color: "gray"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
            }
            Text {
                text: "Версия: " + appInfo.version
                font.pixelSize: 14
                color: "gray"
                width: parent.width
            }
            Text {
                text: "Организация: " + appInfo.organization
                font.pixelSize: 12
                color: "gray"
                width: parent.width
            }
        }
    }

    Controls.Dialog {
        id: warningDialog
        title: "Предупреждение"
        // informativeText: "Создано на Qt Quick. \nВсе права защищены."
        // Dialogs.icon: StandardIcon.Information
        modal: true
        // implicitWidth: parent.width
        // implicitHeight: parent.height
        anchors.centerIn: parent
        width: 400
        standardButtons: Controls.Dialog.Ok
        Text {
            font.pixelSize: 16
            //font.bold: true
            color: "gray"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Обязательно заполните оба поля ПОСЫЛКИ и ЦЕЛЬ"
        }
    }

    Item {
        id: root
        anchors.fill: parent
        anchors.topMargin: parent.SafeArea.margins.top
        anchors.leftMargin: parent.SafeArea.margins.left
        anchors.rightMargin: parent.SafeArea.margins.right
        anchors.bottomMargin: parent.SafeArea.margins.bottom

        readonly property int margin: 18
        readonly property color backgroundColor: "#222222"

        property bool isPortraitMode: true
        //property bool isStepMode: false

        BackendBridge {
            id: backend
            onOutputTextChanged: {
                viewBox.text = backend.outputText;
            }
        }

        ApplicationState {
            id: state
            vs: root.isPortraitMode
            onDataProcessed: result => {
                root.isPortraitMode = result;
            }
        }

        ColumnLayout {
            id: portraitMode
            anchors.fill: parent
            visible: root.isPortraitMode

            Text {
                Layout.fillWidth: true
                text: qsTr("Автоматическое доказательство\nлогических выражений методом резолюций")
                color: "#FFFFFF"
                font.pixelSize: 18
                font.bold: true
                //font.family: Constants.font.family
                font.family: "Arial"
                Layout.alignment: horizontalAlignment
                horizontalAlignment: Text.AlignHCenter
                topPadding: 10
            }

            Text {
                text: qsTr("Посылки (только латиница и символы логических операций):")
                color: "#FFFFFF"
                font.pixelSize: 14
                font.family: "Arial"
                font.italic: true
                leftPadding: root.margin
                //topPadding: 10
            }

            Controls.ScrollView {
                id: premisesText
                readonly property int minWidth: 210
                readonly property int minHeight: 60
                Layout.minimumWidth: minWidth
                Layout.minimumHeight: minHeight
                Layout.fillWidth: true
                Layout.fillHeight: true
                // Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: root.margin
                Layout.rightMargin: root.margin
                Layout.topMargin: 0
                Layout.bottomMargin: root.margin / 2
                focus: true

                Controls.TextArea {
                    id: premises
                    //anchors.top: editText.bottom
                    font.pixelSize: 22
                    color: "#FFFFFF"
                    placeholderText: qsTr("Каждая формула с новой строки")
                    placeholderTextColor: "gray"
                    font.capitalization: "AllUppercase"
                    background: Rectangle {
                        color: "#262626" // Желаемый цвет фона
                        border.color: "#A9A9A9" // Опционально: цвет рамки
                        radius: 8 // Опционально: скругление углов
                    }
                    focus: true

                    // Регулярное выражение: всё, что НЕ латиница и НЕ символы операций
                    property var filterRegex: /[^a-zA-Z\ufe41\u02c4\u02c5\u2b95\u2b0c()\n]/g

                    // Регулярное выражение:
                    // ^[a-zA-Z\u2b95]*$
                    // [] - набор разрешенных символов
                    // a-z - строчные латинские
                    // A-Z - прописные латинские
                    // \u2b95 - символ стрелки
                    // * - любое количество символов
                    // \n - символ перевода строки

                    onTextChanged: {
                        // Проверяем, есть ли запрещенные символы
                        if (filterRegex.test(text)) {
                            let cursor = cursorPosition;
                            // Удаляем лишнее
                            text = text.replace(filterRegex, "");
                            // Возвращаем курсор на место (чтобы не прыгал в начало)
                            cursorPosition = Math.min(cursor, text.length);
                        }
                    }

                    onActiveFocusChanged: if (activeFocus)
                        lastFocusedTextArea = premises
                }
            }

            Row {
                id: targetLine
                Layout.alignment: Qt.AlignHCenter
                leftPadding: root.margin
                rightPadding: root.margin

                Text {
                    id: goalText
                    text: qsTr("Цель: ")
                    color: "#FFFFFF"
                    font.pixelSize: 14
                    //font.family: Constants.font.family
                    font.family: "Arial"
                    font.italic: true
                    rightPadding: 8
                    anchors.verticalCenter: parent.verticalCenter
                }

                Controls.TextField {
                    id: goal
                    placeholderText: qsTr("Формула для доказательства")
                    leftPadding: 10
                    placeholderTextColor: "gray"
                    color: "#FFFFFF"
                    font.pixelSize: 22
                    font.capitalization: "AllUppercase"
                    //Layout.rightMargin: root.margin
                    background: Rectangle {
                        implicitWidth: portraitMode.width - goalText.width - root.margin * 2
                        implicitHeight: 40
                        color: "#262626"
                        border.color: "#A9A9A9"
                        radius: 8
                    }

                    // Регулярное выражение: всё, что НЕ латиница и НЕ символы операций
                    property var filterRegex: /[^a-zA-Z\ufe41\u02c4\u02c5\u2b95\u2b0c()]/g

                    // Регулярное выражение:
                    // ^[a-zA-Z\u2b95]*$
                    // [] - набор разрешенных символов
                    // a-z - строчные латинские
                    // A-Z - прописные латинские
                    // \u2b95 - символ стрелки
                    // * - любое количество символов

                    onTextChanged: {
                        // Проверяем, есть ли запрещенные символы
                        if (filterRegex.test(text)) {
                            let cursor = cursorPosition;
                            // Удаляем лишнее
                            text = text.replace(filterRegex, "");
                            // Возвращаем курсор на место (чтобы не прыгал в начало)
                            cursorPosition = Math.min(cursor, text.length);
                        }
                    }

                    onActiveFocusChanged: if (activeFocus)
                        lastFocusedTextArea = goal
                }
            }

            NumberPad {
                id: numberPad
                isPortraitMode: root.isPortraitMode
                state: state
                Layout.alignment: Qt.AlignHCenter
                Layout.bottomMargin: root.margin
                Layout.topMargin: root.margin / 2
            }
        }

        ColumnLayout {
            id: portraitMode_1
            anchors.fill: parent
            visible: !root.isPortraitMode
            //spacing: 8

            Text {
                id: title
                Layout.fillWidth: true
                text: qsTr("Автоматическое доказательство\nлогических выражений методом резолюций")
                color: "#FFFFFF"
                font.pixelSize: 18
                font.bold: true
                //font.family: Constants.font.family
                font.family: "Arial"
                Layout.alignment: horizontalAlignment
                horizontalAlignment: Text.AlignHCenter
                topPadding: 10
            }

            Text {
                id: title_1
                Layout.alignment: Qt.AlignLeft
                text: qsTr("Ход доказательства:")
                color: "#FFFFFF"
                font.pixelSize: 14
                //font.family: Constants.font.family
                font.family: "Arial"
                font.italic: true
                leftPadding: root.margin
                topPadding: 8
                bottomPadding: 8
            }

            Controls.ScrollView {
                id: viewText
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                Layout.leftMargin: root.margin
                Layout.rightMargin: root.margin

                Controls.TextArea {
                    id: viewBox
                    font.pixelSize: 22
                    color: "#FFFFFF"
                    font.capitalization: "AllUppercase"
                    readOnly: true
                    background: Rectangle {
                        color: "#262626" // Желаемый цвет фона
                        border.color: "#A9A9A9" // Опционально: цвет рамки
                        radius: 8 // Опционально: скругление углов
                        //height: 180
                    }
                }
            }

            NumberPad_1 {
                id: numberPad_1
                isPortraitMode: root.isPortraitMode
                state: state
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: root.margin + 88 + 5 +38
                Layout.bottomMargin: root.margin
                Layout.topMargin: 8
            }
        }
    }
}
