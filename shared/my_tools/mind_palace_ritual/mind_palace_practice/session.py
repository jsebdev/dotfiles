from collections.abc import Iterable
from typing import Protocol

from .objects import NumberedObject
from .rituals import Question, Ritual
from .scoreboard import Scoreboard


class PracticeUserInterface(Protocol):
    def ask_answer(self, question: Question) -> str: ...

    def show_correct_answer(self, target: NumberedObject) -> None: ...

    def show_wrong_answer(self) -> None: ...


def practice(
    targets: Iterable[NumberedObject],
    ritual: Ritual,
    user_interface: PracticeUserInterface,
    scoreboard: Scoreboard,
) -> None:
    for target in targets:
        question = ritual.question_for(target)
        wrong_attempts = _answer_until_correct(question, user_interface)
        user_interface.show_correct_answer(target)
        scoreboard.record(target, wrong_attempts)


def _answer_until_correct(
    question: Question, user_interface: PracticeUserInterface
) -> int:
    wrong_attempts = 0
    while not question.accepts(user_interface.ask_answer(question)):
        wrong_attempts += 1
        user_interface.show_wrong_answer()
    return wrong_attempts
