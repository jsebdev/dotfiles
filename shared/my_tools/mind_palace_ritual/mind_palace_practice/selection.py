from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Protocol, TypeVar

from .cards import Deck, RangeGroup
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
    deck = _choose_range(user_interface, _choose_deck(user_interface, subject))
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
        "Which technique do you want to practice?",
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


def _choose_range(user_interface: SelectionUserInterface, deck: Deck) -> Deck:
    if not deck.range_groups:
        return deck
    if len(deck.range_groups) == 1:
        group = deck.range_groups[0]
        return _choose_narrowed_deck(
            user_interface, group.question, [deck, *_narrowed_decks(deck, group)]
        )
    group = _choose_range_group(user_interface, deck)
    if not group.ranges:
        return deck
    return _choose_narrowed_deck(
        user_interface, group.question, _narrowed_decks(deck, group)
    )


def _choose_range_group(
    user_interface: SelectionUserInterface, deck: Deck
) -> RangeGroup:
    return user_interface.choose(
        "How much do you want to practice?",
        [_whole_deck_group(deck), *deck.range_groups],
        lambda group: group.name,
    )


def _whole_deck_group(deck: Deck) -> RangeGroup:
    return RangeGroup(
        name=f"All ({len(deck.cards)} {deck.card_noun}s)",
        question="",
        ranges=[],
    )


def _narrowed_decks(deck: Deck, group: RangeGroup) -> list[Deck]:
    return [deck.narrowed_to(card_range) for card_range in group.ranges]


def _choose_narrowed_deck(
    user_interface: SelectionUserInterface, question: str, decks: Sequence[Deck]
) -> Deck:
    return user_interface.choose(question, decks, _range_label)


def _range_label(deck: Deck) -> str:
    return f"{deck.range_label or 'All'} ({len(deck.cards)} {deck.card_noun}s)"
