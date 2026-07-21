#!/usr/bin/env python3
from dataclasses import dataclass
from typing import Union, Set, Tuple, List
import ipywidgets as widgets
from IPython.display import display, clear_output


#  AST формулы (дерево)

@dataclass(frozen=True)
class Var:
    name: str

@dataclass(frozen=True)
class Not:
    operand: any

@dataclass(frozen=True)
class And:
    left: any
    right: any

@dataclass(frozen=True)
class Or:
    left: any
    right: any

@dataclass(frozen=True)
class Implies:
    left: any
    right: any


#   Парсер формул

import re

TOKEN_REGEX = r'\s*(->|[()!&|]|[A-Z])'

def tokenize(s):
    return re.findall(TOKEN_REGEX, s)

def parse_formula(tokens):
    def parse_imp():
        left = parse_or()
        if tokens and tokens[0] == '->':
            tokens.pop(0)
            right = parse_imp()
            return Implies(left, right)
        return left

    def parse_or():
        left = parse_and()
        while tokens and tokens[0] == '|':
            tokens.pop(0)
            right = parse_and()
            left = Or(left, right)
        return left

    def parse_and():
        left = parse_not()
        while tokens and tokens[0] == '&':
            tokens.pop(0)
            right = parse_not()
            left = And(left, right)
        return left

    def parse_not():
        if tokens[0] == '!':
            tokens.pop(0)
            return Not(parse_not())
        if tokens[0] == '(':
            tokens.pop(0)
            expr = parse_imp()
            tokens.pop(0)
            return expr
        return Var(tokens.pop(0))

    return parse_imp()

def parse(s):
    tokens = tokenize(s)
    return parse_formula(tokens)


#  Приведение к КНФ

def remove_implications(f):
    if isinstance(f, Implies):
        return Or(Not(remove_implications(f.left)), remove_implications(f.right))
    if isinstance(f, And):
        return And(remove_implications(f.left), remove_implications(f.right))
    if isinstance(f, Or):
        return Or(remove_implications(f.left), remove_implications(f.right))
    if isinstance(f, Not):
        return Not(remove_implications(f.operand))
    return f


#  Проталкивание отрицаний

def push_negations(f):
    if isinstance(f, Not):
        g = f.operand
        if isinstance(g, Not):
            return push_negations(g.operand)
        if isinstance(g, And):
            return Or(push_negations(Not(g.left)), push_negations(Not(g.right)))
        if isinstance(g, Or):
            return And(push_negations(Not(g.left)), push_negations(Not(g.right)))
        return f
    if isinstance(f, And):
        return And(push_negations(f.left), push_negations(f.right))
    if isinstance(f, Or):
        return Or(push_negations(f.left), push_negations(f.right))
    return f


#  Распределение ∨ над ∧

def distribute(f):
    if isinstance(f, Or):
        a, b = f.left, f.right
        if isinstance(a, And):
            return And(distribute(Or(a.left, b)), distribute(Or(a.right, b)))
        if isinstance(b, And):
            return And(distribute(Or(a, b.left)), distribute(Or(a, b.right)))
    if isinstance(f, And):
        return And(distribute(f.left), distribute(f.right))
    return f


#  Полная КНФ

def to_cnf(f):
    f = remove_implications(f)
    f = push_negations(f)
    while True:
        new_f = distribute(f)
        if new_f == f:
            break
        f = new_f
    return f


#  Построение дизъюнктов

def extract_clauses(formula):
    clauses = set()

    def collect(f):
        if isinstance(f, And):
            collect(f.left)
            collect(f.right)
        else:
            clauses.add(frozenset(extract_literals(f)))

    def extract_literals(f):
        if isinstance(f, Or):
            return extract_literals(f.left) | extract_literals(f.right)
        elif isinstance(f, Not) and isinstance(f.operand, Var):
            return {f}
        elif isinstance(f, Var):
            return {f}
        else:
            raise ValueError(f"Недопустимый литерал: {f}")

    collect(formula)
    return clauses


#  Метод резолюций

def resolve(c1, c2):
    resolvents = []

    for l1 in c1:
        for l2 in c2:
            # l1 и l2 — комплементарные?
            if (isinstance(l1, Var) and isinstance(l2, Not) and l2.operand == l1) or \
               (isinstance(l2, Var) and isinstance(l1, Not) and l1.operand == l2):

                new_clause = (c1 | c2) - {l1, l2}
                resolvents.append(new_clause)

    return resolvents


def resolution(initial_clauses):
    clauses = list(initial_clauses)
    new = True
    steps = []

    while new:
        new = False
        n = len(clauses)

        for i in range(n):
            for j in range(i):
                c1 = clauses[i]
                c2 = clauses[j]

                resolvents = resolve(c1, c2)

                for r in resolvents:
                    if r not in clauses:
                        steps.append((c1, c2, r))

                        # ПУСТОЙ ДИЗЪЮНКТ
                        if not r:
                            return True, steps

                        clauses.append(r)
                        new = True

    return False, steps


#  Вывод доказательства

def clause_str(c):
    if not c:
        return "□"

    def lit_str(l):
        if isinstance(l, Var):
            return l.name
        if isinstance(l, Not) and isinstance(l.operand, Var):
            return f"\ufe41{l.operand.name}"
            #return f"¬{l.operand.name}"
        return str(l)

    return " \u02c5 ".join(sorted(lit_str(l) for l in c))
    #return " ∨ ".join(sorted(lit_str(l) for l in c))



def print_steps(clauses, steps):
    text = "Множество дизъюнктов:\n"
    for i, c in enumerate(clauses, 1):
        text += f"{i}) {clause_str(c)}\n"

    text += "\nШаги резолюции:\n"
    for i, (c1, c2, r) in enumerate(steps, 1):
        text += (
            f"Шаг {i}:\n"
            f"({clause_str(c1)}) , ({clause_str(c2)}) ⟹ ({clause_str(r)})\n\n"
        )
    return text

# --- КРАСИВЫЙ ВЫВОД ФОРМУЛ ---

def formula_str(f):
    if isinstance(f, Var):
        return f.name
    if isinstance(f, Not):
        return f"\ufe41{formula_str(f.operand)}"
        #return f"¬{formula_str(f.operand)}"
    if isinstance(f, And):
        return f"({formula_str(f.left)} \u02c4 {formula_str(f.right)})"
        #return f"({formula_str(f.left)} ∧ {formula_str(f.right)})"
    if isinstance(f, Or):
        return f"({formula_str(f.left)} \u02c5 {formula_str(f.right)})"
        #return f"({formula_str(f.left)} ∨ {formula_str(f.right)})"
    if isinstance(f, Implies):
        return f"({formula_str(f.left)} \u2b95 {formula_str(f.right)})"
        #return f"({formula_str(f.left)} → {formula_str(f.right)})"




# # Интерфейс (GUI)

#%%
premises_box = widgets.Textarea(
    description='Посылки:',
    placeholder='Каждая формула с новой строки',
    layout=widgets.Layout(width='450px', height='120px')
)

goal_box = widgets.Text(
    description='Цель:',
    placeholder='Формула для доказательства'
)

output = widgets.Output()

# --- КНОПКИ СИМВОЛОВ ---
def insert_symbol(box, symbol):
    box.value += symbol

symbols = ['¬', '∧', '∨', '→', '(', ')']
symbol_buttons = []

for s in symbols:
    b = widgets.Button(description=s, layout=widgets.Layout(width='40px'))
    b.on_click(lambda _, s=s: insert_symbol(goal_box, s.replace('¬','!').replace('∧','&').replace('∨','|').replace('→','->')))
    symbol_buttons.append(b)

symbol_row = widgets.HBox(symbol_buttons)

# --- СОСТОЯНИЕ ---
resolution_steps = []
current_step = 0
initial_clauses = []

# --- АВТОМАТИЧЕСКИЙ ПРИМЕР ---
def auto_example(_):
    premises_box.value = "A\nA -> B\n¬B"
    goal_box.value = "A"

# --- ЗАПУСК ДОКАЗАТЕЛЬСТВА ---
def run(_):
    global resolution_steps, current_step, initial_clauses
    with output:
        clear_output()
        current_step = 0

        premises = [parse(line.replace('¬','!').replace('∧','&').replace('∨','|').replace('→','->'))
                    for line in premises_box.value.splitlines() if line.strip()]
        goal = parse(goal_box.value.replace('¬','!').replace('∧','&').replace('∨','|').replace('→','->'))

        print("ПОСЫЛКИ:")
        for i, p in enumerate(premises, 1):
            print(f"{i}) {formula_str(p)}")

        print("\nЦЕЛЬ ДОКАЗАТЕЛЬСТВА:")
        print(formula_str(goal))

        print("\nОТРИЦАНИЕ ЦЕЛИ:")
        neg_goal = Not(goal)
        print(formula_str(neg_goal))


        clauses = set()
        for p in premises:
            clauses |= extract_clauses(to_cnf(p))
        clauses |= extract_clauses(to_cnf(neg_goal))

        initial_clauses = list(clauses)

        print("\nНАЧАЛЬНЫЕ ДИЗЪЮНКТЫ:")
        for i, c in enumerate(initial_clauses, 1):
            print(f"{i}) {clause_str(c)}")

        result, resolution_steps = resolution(initial_clauses)

        if not resolution_steps:
            print("\nРезолюции невозможны (нет комплементарных литералов).")
        else:
            print("\nНажмите «Следующий шаг» для выполнения резолюции.")

# --- ПОШАГОВОЕ ВЫПОЛНЕНИЕ ---
def next_step(_):
    global current_step
    with output:
        if current_step >= len(resolution_steps):
            print("\nДоказательство завершено.")
            return

        c1, c2, r = resolution_steps[current_step]
        print(f"\nШАГ {current_step + 1}:")
        print(f"({clause_str(c1)}) , ({clause_str(c2)}) ⟹ ({clause_str(r)})")

        if not r:
            print("\nПОЛУЧЕН ПУСТОЙ ДИЗЪЮНКТ □")
            print("ПРОТИВОРЕЧИЕ. ТЕОРЕМА ДОКАЗАНА.")

        current_step += 1

# --- КНОПКИ ---
prove_btn = widgets.Button(description="Доказать")
step_btn = widgets.Button(description="Следующий шаг")
example_btn = widgets.Button(description="Автоматический пример")

prove_btn.on_click(run)
step_btn.on_click(next_step)
example_btn.on_click(auto_example)


if __name__ == "__main__":
    display(
    premises_box,
    goal_box,
    symbol_row,
    widgets.HBox([prove_btn, step_btn, example_btn]),
    output
)
