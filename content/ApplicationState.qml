// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

import QtQuick
import QtQml
import "calculator.js" as CalcEngine

QtObject {
    required property bool vs
    signal dataProcessed(bool result)

    function operatorPressed(operator) {
        CalcEngine.operatorPressed(operator);
        dataProcessed(vs)
    }
    function letterPressed(letter) {
        CalcEngine.letterPressed(letter);
    }
}
