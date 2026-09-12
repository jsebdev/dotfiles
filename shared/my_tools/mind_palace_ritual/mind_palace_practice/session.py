from collections.abc import Iterable
from typing import Protocol

from .cards import PracticeCard
from .rituals import Question, Ritual
from .scoreboard import Scoreboard


class PracticeUserInterface(Protocol):
    def ask_answer(self, question: Question) -> str: ...

    def show_correct_answer(self, card: PracticeCard) -> None: ...

    def show_wrong_answer(self) -> None: ...


def practice(
    targets: Iterable[PracticeCard],
    ritual: Ritual,
    user_interface: PracticeUserInterface,
    scoreboard: Scoreboard,
) -> None:
    for card in targets:
        question = ritual.question_for(card)
        wrong_attempts = _answer_until_correct(question, user_interface)
        user_interface.show_correct_answer(card)
        scoreboard.record(card, wrong_attempts)


def _answer_until_correct(
    question: Question, user_interface: PracticeUserInterface
) -> int:
    wrong_attempts = 0
    while not question.accepts(user_interface.ask_answer(question)):
        wrong_attempts += 1
        user_interface.show_wrong_answer()
    return wrong_attempts
