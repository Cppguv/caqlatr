// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: controller

    required property bool isPortraitMode
    required property ApplicationState state

    readonly property color qtGreenColor: "#2CDE85"
    readonly property color backspaceRedColor: "#DE2C2C"
    readonly property int spacing: 5

    property int portraitModeWidth: mainGrid.width
    property int landscapeModeWidth: mainGrid.width

    implicitWidth: portraitModeWidth
    implicitHeight: mainGrid.height

    // function updateDimmed() {
    //     for (let i = 0; i < mainGrid.children.length; i++) {
    //         mainGrid.children[i].dimmed = state.isButtonDisabled(mainGrid.children[i].text);
    //     }
    // }

    component LetterButton: CalculatorButton {
        onClicked: {
            controller.state.letterPressed(text);
            //controller.updateDimmed();
        }
    }

    component OperatorButton: CalculatorButton {
        dimmable: true
        implicitWidth: 48
        textColor: controller.qtGreenColor

        onClicked: {
            controller.state.operatorPressed(text);
            //controller.updateDimmed();
        }
    }

    //Component.onCompleted: updateDimmed()

    Rectangle {
        id: numberPad
        anchors.fill: parent
        radius: 8
        color: "transparent"

        GridLayout {
            id: mainGrid
            columns: 11
            columnSpacing: controller.spacing
            rowSpacing: controller.spacing

            // first row
            LetterButton {
                text: "Q"
            }
            LetterButton {
                text: "W"
            }
            LetterButton {
                text: "E"
            }
            LetterButton {
                text: "R"
            }
            LetterButton {
                text: "T"
            }
            LetterButton {
                text: "Y"
            }
            LetterButton {
                text: "U"
            }
            LetterButton {
                text: "I"
            }
            LetterButton {
                text: "O"
            }
            LetterButton {
                text: "P"
            }
            OperatorButton {
                text: "AC"
                textColor: controller.backspaceRedColor
                accentColor: controller.backspaceRedColor
            }

            // second row
            LetterButton {
                text: "A"
            }
            LetterButton {
                text: "S"
            }
            LetterButton {
                text: "D"
            }
            LetterButton {
                text: "F"
            }
            LetterButton {
                text: "G"
            }
            LetterButton {
                text: "H"
            }
            LetterButton {
                text: "J"
            }
            LetterButton {
                text: "K"
            }
            LetterButton {
                text: "L"
            }
            OperatorButton {
                text: "\u21b7"  // clockwise top semicircle arrow
                //text: "\u21b6"  // anticlockwise top semicircle arrow
                implicitWidth: 38
            }
            BackspaceButton {
                onClicked: {
                    controller.state.operatorPressed(this.text);
                    //controller.updateDimmed();
                }
            }

            // third row
            LetterButton {
                text: "Z"
            }
            LetterButton {
                text: "X"
            }
            LetterButton {
                text: "C"
            }
            LetterButton {
                text: "V"
            }
            LetterButton {
                text: "B"
            }
            LetterButton {
                text: "N"
            }
            LetterButton {
                text: "M"
            }
            OperatorButton {
                text: qsTr("Автомат. пример")
                fontSize: 14
                implicitWidth: 124
                Layout.columnSpan: 3
            }
            OperatorButton {
                text: qsTr("ШАГ")
                fontSize: 16
                //implicitHeight: 81
                //Layout.rowSpan: 2
            }

            //forth row
            LetterButton {
                text: "("
            }
            LetterButton {
                text: ")"
            }
            // https://www.compart.com/en/unicode/search?q=bracket#characters
            // vertical left coner bracket
            LetterButton {
                fontSize: 16
                text: "\ufe41"
            }
            // up arrow
            LetterButton {
                //text: "\u2bb9"
                //text: "\u2303"
                fontSize: 16
                text: "\u02c4"
            }
            // down arrow
            LetterButton {
                //text: "\u2304"
                fontSize: 16
                text: "\u02c5"
            }
            // left arrow
            LetterButton {
                text: "\u2b95"
                //text: "\u2192"
                //text: "\u27f9"
            }
            // left right arrow
            LetterButton {
                text: "\u2b0c"
            }
            OperatorButton {
                text: qsTr("ДОКАЗАТЬ")
                fontSize: 16
                implicitWidth: 124
                Layout.columnSpan: 3
            }
            OperatorButton {
                text: qsTr("Enter")
                fontSize: 16
            }
        }
    }
}
