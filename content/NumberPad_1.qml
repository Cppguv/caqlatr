// Copyright (C) 2023 The Qt Company Ltd.// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

Item {
    id: controller

    required property bool isPortraitMode
    required property ApplicationState state
    readonly property color qtGreenColor: "#2CDE85"
    readonly property int spacing: 5

    property int portraitModeWidth: numberPad.width

    implicitWidth: portraitModeWidth
    implicitHeight: 48

    component OperatorButton: CalculatorButton {
        dimmable: true
        implicitWidth: 48
        textColor: controller.qtGreenColor

        onClicked: {
            controller.state.operatorPressed(text);
        }
    }

    //Component.onCompleted: updateDimmed()

    Rectangle {
        id: numberPad
        anchors.fill: parent
        //width: 100
        radius: 8
        color: "transparent"

        RowLayout {
            spacing: controller.spacing
            //anchors.right: parent.right

            OperatorButton {
                text: qsTr("След. ШАГ")
                fontSize: 16
                implicitWidth: 88
                //Layout.columnSpan: 3
            }

            OperatorButton {
                text: "\u21b6"  // anticlockwise top semicircle arrow
                implicitWidth: 38
            }
        }
    }
}
