from collections.abc import Iterable
from dataclasses import dataclass
from typing import Protocol

from .cards import PracticeCard
from .rituals import AnswerVerdict, Question, Ritual
from .scoreboard import Scoreboard

WRONG_ATTEMPTS_BEFORE_REVEAL = 3


class PracticeUserInterface(Protocol):
    def ask_answer(self, question: Question) -> str: ...

    def show_correct_answer(self, card: PracticeCard) -> None: ...

    def show_revealed_answer(self, card: PracticeCard) -> None: ...

    def show_wrong_answer(self) -> None: ...

    def show_misspelled_answer(self, expected_answer: str) -> None: ...


@dataclass(frozen=True)
class AnsweringOutcome:
    wrong_attempts: int
    solved: bool


def practice(
    targets: Iterable[PracticeCard],
    ritual: Ritual,
    user_interface: PracticeUserInterface,
    scoreboard: Scoreboard,
) -> None:
    for card in targets:
        question = ritual.question_for(card)
        outcome = _answer_until_solved_or_revealed(question, user_interface)
        if outcome.solved:
            user_interface.show_correct_answer(card)
        else:
            user_interface.show_revealed_answer(card)
        scoreboard.record(card, outcome.wrong_attempts)


def _answer_until_solved_or_revealed(
    question: Question, user_interface: PracticeUserInterface
) -> AnsweringOutcome:
    wrong_attempts = 0
    while wrong_attempts < WRONG_ATTEMPTS_BEFORE_REVEAL:
        verdict = question.judge(user_interface.ask_answer(question))
        if verdict is AnswerVerdict.MISSPELLED:
            user_interface.show_misspelled_answer(question.expected_answer)
        if verdict is not AnswerVerdict.WRONG:
            return AnsweringOutcome(wrong_attempts, solved=True)
        wrong_attempts += 1
        if wrong_attempts < WRONG_ATTEMPTS_BEFORE_REVEAL:
            user_interface.show_wrong_answer()
    return AnsweringOutcome(wrong_attempts, solved=False)
