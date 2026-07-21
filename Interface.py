#!/usr/bin/env python3

# Copyright (C) 2026  Mary Khmylova

import sys
import json
import codecs
import Backend as bk

######################################################


def main():
    try:
        raw_data = sys.stdin.read()

        if not raw_data:
            response = {"error": "No input provided"}
            print(json.dumps(response, ensure_ascii=False))
            return

        data = json.loads(raw_data)

        if "inputPremises" not in data:
            response = {"error": "Missing 'inputPremises' field in JSON"}
            print(json.dumps(response, ensure_ascii=False))
            return

        if "inputGoal" not in data:
            response = {"error": "Missing 'inputGoal' field in JSON"}
            print(json.dumps(response, ensure_ascii=False))
            return

        if "isStepMode" not in data:
                response = {"error": "Missing 'isStepMode' field in JSON"}
                print(json.dumps(response, ensure_ascii=False))
                return

        # Получаем посылки и цель из JSON
        premises_raw = data["inputPremises"]
        goal_raw = data["inputGoal"]
        stepMode = data["isStepMode"]

        # Предварительная очистка символов, как это делалось в bk.run
        def clean_input(text):
            return text.replace('\ufe41','!').replace('\u02c4','&').replace('\u02c5','|').replace('\u2b95','->').replace('\u2b0c','<->')
            #return text.replace('¬','!').replace('∧','&').replace('∨','|').replace('→','->').replace('↔','<->')

        # Вызываем логику парсинга напрямую из модуля bk (Backend)
        premises = [bk.parse(clean_input(line)) for line in premises_raw.splitlines() if line.strip()]
        goal = bk.parse(clean_input(goal_raw))
        neg_goal = bk.Not(goal)

        # Собираем дизъюнкты
        clauses = set()
        for p in premises:
            clauses |= bk.extract_clauses(bk.to_cnf(p))
        clauses |= bk.extract_clauses(bk.to_cnf(neg_goal))

        # Запускаем метод резолюций напрямую
        success, resolution_steps = bk.resolution(list(clauses))

        # Формируем красивый текстовый результат, имитируя вывод на экран
        output_lines = []

        # Если успешно, то есть есть конечное количество шагов, то выводим доказательство во фронтенд
        if success:
                output_lines.append("ПОСЫЛКИ:")
                for i, p in enumerate(premises, 1):
                    output_lines.append(f"{i}) {bk.formula_str(p)}")

                output_lines.append("\nЦЕЛЬ ДОКАЗАТЕЛЬСТВА:")
                output_lines.append(bk.formula_str(goal))

                output_lines.append("\nОТРИЦАНИЕ ЦЕЛИ:")
                output_lines.append(bk.formula_str(neg_goal))

                output_lines.append("\nНАЧАЛЬНЫЕ ДИЗЪЮНКТЫ:")
                for i, c in enumerate(clauses, 1):
                    output_lines.append(f"{i}) {bk.clause_str(c)}")

                if not stepMode:
                        output_lines.append("\nШАГИ РЕЗОЛЮЦИИ:")
                        for i, (c1, c2, r) in enumerate(resolution_steps, 1):
                            output_lines.append(f"Шаг {i}: ({bk.clause_str(c1)}) , ({bk.clause_str(c2)}) ⟹ ({bk.clause_str(r)})")
                            if not r:
                                output_lines.append("\nПОЛУЧЕН ПУСТОЙ ДИЗЪЮНКТ □\nПРОТИВОРЕЧИЕ. ТЕОРЕМА ДОКАЗАНА.")
                else:
                        output_lines.append(f"\nisStepMode: {stepMode}")

        # если не успешно, шагов нет, значит Резолюции не возможны, что и выводим во фронтенд
        else:
                output_lines.append("Резолюции невозможны (нет комплементарных литералов)!")

        result = "\n".join(output_lines)

        # Передаем результат в JSON (ensure_ascii=False важен для корректного вывода кириллицы и логических знаков)
        response = {"result": result}
        print(json.dumps(response, ensure_ascii=False))

    except json.JSONDecodeError as e:
        response = {"error": f"JSON parsing error: {str(e)}"}
        print(json.dumps(response, ensure_ascii=False))
    except Exception as e:
        response = {"error": f"Unexpected error: {str(e)}"}
        print(json.dumps(response, ensure_ascii=False))



if __name__ == "__main__":
    # Ensure stdin is read as UTF-8
    sys.stdin = codecs.getreader('utf-8')(sys.stdin.detach())
    sys.stdout = codecs.getwriter('utf-8')(sys.stdout.detach())
    main()