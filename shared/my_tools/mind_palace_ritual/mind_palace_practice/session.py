from collections.abc import Iterable
from typing import Protocol

from .cards import PracticeCard
from .rituals import AnswerVerdict, Question, Ritual
from .scoreboard import Scoreboard


class PracticeUserInterface(Protocol):
    def ask_answer(self, question: Question) -> str: ...

    def show_correct_answer(self, card: PracticeCard) -> None: ...

    def show_wrong_answer(self) -> None: ...

    def show_misspelled_answer(self, expected_answer: str) -> None: ...


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
    while True:
        verdict = question.judge(user_interface.ask_answer(question))
        if verdict is AnswerVerdict.MISSPELLED:
            user_interface.show_misspelled_answer(question.expected_answer)
        if verdict is not AnswerVerdict.WRONG:
            return wrong_attempts
        wrong_attempts += 1
        user_interface.show_wrong_answer()
