from dataclasses import dataclass


@dataclass(frozen=True)
class PracticeCard:
    number: str
    name: str
    place: str = ""


@dataclass(frozen=True)
class Deck:
    name: str
    card_noun: str
    completion_icon: str
    cards: list[PracticeCard]
