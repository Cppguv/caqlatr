// Copyright (C) 2026 The Qt Company Ltd && Mary Khmylova
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

// флаг отражающй состояние работы программы в автоматическом или пошаговом режиме
let stepMode = false;

// функция обратоки нажатий буквенных клавиш
function letterPressed(op) {
    lastFocusedTextArea.insert(lastFocusedTextArea.cursorPosition, op.toString());
    // Возвращаем фокус полю ввода, чтобы можно было печатать дальше
    lastFocusedTextArea.forceActiveFocus();
}

// функция обратоки нажатий клавиш операций
function operatorPressed(op) {

    // обработка нажатия кнопки BackSpace (стирание последнего символа слева от текущего положения курсора)
    if (op === "bs") {
        if (lastFocusedTextArea.cursorPosition > 0) {
            // Запоминаем текущую позицию курсора
            let pos = lastFocusedTextArea.cursorPosition;
            // Удаляем один символ перед курсором
            lastFocusedTextArea.text = lastFocusedTextArea.text.substring(0, pos - 1) + lastFocusedTextArea.text.substring(pos);
            // Возвращаем курсор на правильное место
            lastFocusedTextArea.cursorPosition = pos - 1;
        }
        // Возвращаем фокус полю ввода, чтобы можно было печатать дальше
        lastFocusedTextArea.forceActiveFocus();
        return;
    }

    // обработка нажатия кнопки "Автомат. пример"
    if (op === "Автомат. пример") {
        premises.clear();
        goal.clear();
        viewBox.clear();
        premises.text = "A\nA\u2b95B\n\ufe41B";
        goal.text = "A";
        premises.cursorPosition = premises.length;
        return;
    }

    // обработка нажатия кнопки ШАГ
    if (op === "ШАГ") {
        stepMode = true;
        if (premises.text && goal.text) {
            backend.prove(premises.text.toUpperCase(), goal.text.toUpperCase(), stepMode);
            vs = !vs;
        } else {
            // не заполнены поля ПОСЫЛКИ либо ЦЕЛЬ
            warningDialog.open()
        }
        //backend.prove("A", "A", stepMode);
        return;
    }

    // обработка нажатия кнопки ДОКАЗАТЬ
    if (op === "ДОКАЗАТЬ") {
        viewBox.clear();
        stepMode = false;
        if (premises.text && goal.text) {
            backend.prove(premises.text.toUpperCase(), goal.text.toUpperCase(), stepMode);
            vs = !vs;
        } else {
            // не заполнены поля ПОСЫЛКИ либо ЦЕЛЬ
            warningDialog.open()
        }
        return;
    }

    // обработка нажатия Enter (переход на новую строку)
    if (op === "Enter") {
        if (lastFocusedTextArea === premises) {
            lastFocusedTextArea.insert(lastFocusedTextArea.cursorPosition, "\n");
            // Возвращаем фокус полю ввода, чтобы можно было печатать дальше
            lastFocusedTextArea.forceActiveFocus();
        }
        return;
    }

    // обработка нажатия кнопок смены экранов "посылок" и "хода доказательства"
    if ((op === "\u21b7") || (op === "\u21b6")) {
        vs = !vs;
    }

    // стирание содержимого всех текстовых полей (областей)
    if (op === "AC") {
        premises.clear();
        goal.clear();
        viewBox.clear();
        lastFocusedTextArea.forceActiveFocus();
    }
}
