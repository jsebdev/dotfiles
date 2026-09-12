from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Protocol, TypeVar

from .cards import Deck
from .modes import Mode, available_modes
from .rituals import Ritual, available_rituals
from .subjects import Subject

Option = TypeVar("Option")


class SelectionUserInterface(Protocol):
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option: ...


@dataclass(frozen=True)
class PracticeChoice:
    deck: Deck
    ritual: Ritual
    mode: Mode


def ask_practice_choice(
    user_interface: SelectionUserInterface,
    subjects: Sequence[Subject],
) -> PracticeChoice:
    subject = _choose_subject(user_interface, subjects)
    deck = _choose_deck(user_interface, subject)
    return PracticeChoice(
        deck=deck,
        ritual=user_interface.choose(
            "Which ritual do you want to practice?",
            available_rituals(deck),
            lambda ritual: ritual.name,
        ),
        mode=user_interface.choose(
            "Which mode do you want to play in?",
            available_modes(),
            lambda mode: f"{mode.name} ({mode.description})",
        ),
    )


def _choose_subject(
    user_interface: SelectionUserInterface, subjects: Sequence[Subject]
) -> Subject:
    if len(subjects) == 1:
        return subjects[0]
    return user_interface.choose(
        "What do you want to practice?",
        subjects,
        lambda subject: subject.name,
    )


def _choose_deck(user_interface: SelectionUserInterface, subject: Subject) -> Deck:
    if len(subject.decks) == 1:
        return subject.decks[0]
    return user_interface.choose(
        f"Which {subject.deck_noun} do you want to practice?",
        subject.decks,
        lambda deck: deck.name,
    )
