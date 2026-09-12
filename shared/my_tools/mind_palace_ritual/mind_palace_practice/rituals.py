import random
from dataclasses import dataclass
from typing import Protocol

from .cards import Deck, PracticeCard


@dataclass(frozen=True)
class Question:
    prompt: str
    expected_answer: str
    card: PracticeCard

    def accepts(self, answer: str) -> bool:
        return _comparable(answer) == _comparable(self.expected_answer)


def _comparable(answer: str) -> str:
    return " ".join(answer.replace("_", " ").lower().split())


class Ritual(Protocol):
    @property
    def name(self) -> str: ...

    def question_for(self, card: PracticeCard) -> Question: ...


@dataclass(frozen=True)
class NumberToNameRitual:
    card_noun: str

    @property
    def name(self) -> str:
        return f"Number to {self.card_noun}"

    def question_for(self, card: PracticeCard) -> Question:
        return Question(
            prompt=f"Which {self.card_noun} is number {card.number}?",
            expected_answer=card.name,
            card=card,
        )


@dataclass(frozen=True)
class NameToNumberRitual:
    card_noun: str

    @property
    def name(self) -> str:
        return f"{self.card_noun.capitalize()} to number"

    def question_for(self, card: PracticeCard) -> Question:
        return Question(
            prompt=f"Which number is '{card.name}'?",
            expected_answer=card.number,
            card=card,
        )


@dataclass(frozen=True)
class MixedRitual:
    rituals: list[Ritual]
    name = "Mixed"

    def question_for(self, card: PracticeCard) -> Question:
        return random.choice(self.rituals).question_for(card)


def available_rituals(deck: Deck) -> list[Ritual]:
    one_way_rituals: list[Ritual] = [
        NumberToNameRitual(deck.card_noun),
        NameToNumberRitual(deck.card_noun),
    ]
    return [*one_way_rituals, MixedRitual(one_way_rituals)]
