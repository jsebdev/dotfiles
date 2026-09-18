from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Protocol, TypeVar

from .cards import Deck, RangeGroup
from .modes import Mode, available_modes
from .index_question import IndexQuestion
from .rituals import Ritual, available_rituals

Option = TypeVar("Option")


class SelectionUserInterface(Protocol):
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option: ...

    def ask_index(self, question: IndexQuestion) -> int: ...


@dataclass(frozen=True)
class PracticeChoice:
    deck: Deck
    ritual: Ritual
    mode: Mode


def ask_practice_choice(
    user_interface: SelectionUserInterface,
    decks: Sequence[Deck],
) -> PracticeChoice:
    deck = _choose_range(user_interface, _choose_deck(user_interface, decks))
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


def _choose_deck(user_interface: SelectionUserInterface, decks: Sequence[Deck]) -> Deck:
    if len(decks) == 1:
        return decks[0]
    return user_interface.choose(
        "Which mind palace do you want to practice?",
        decks,
        lambda deck: deck.name,
    )


@dataclass(frozen=True)
class _RangeOption:
    name: str
    narrow: Callable[[SelectionUserInterface, Deck], Deck]


def _choose_range(user_interface: SelectionUserInterface, deck: Deck) -> Deck:
    option = user_interface.choose(
        "How much do you want to practice?",
        _range_options(deck),
        lambda range_option: range_option.name,
    )
    return option.narrow(user_interface, deck)


def _range_options(deck: Deck) -> list[_RangeOption]:
    return [
        _whole_deck_option(deck),
        *[_range_group_option(group) for group in deck.range_groups],
        _chosen_span_option(deck),
    ]


def _whole_deck_option(deck: Deck) -> _RangeOption:
    return _RangeOption(
        name=f"All ({len(deck.cards)} {deck.card_noun}s)",
        narrow=lambda user_interface, chosen_deck: chosen_deck,
    )


def _range_group_option(group: RangeGroup) -> _RangeOption:
    return _RangeOption(
        name=group.name,
        narrow=lambda user_interface, chosen_deck: _choose_narrowed_deck(
            user_interface, group.question, _narrowed_decks(chosen_deck, group)
        ),
    )


def _chosen_span_option(deck: Deck) -> _RangeOption:
    return _RangeOption(
        name=f"Range of {deck.card_noun}s",
        narrow=_ask_span,
    )


def _ask_span(user_interface: SelectionUserInterface, deck: Deck) -> Deck:
    last_index = deck.last_card_index
    first_chosen = user_interface.ask_index(
        IndexQuestion(
            prompt=f"Which is the first {deck.card_noun}?",
            lowest=deck.first_card_index,
            highest=last_index,
        )
    )
    last_chosen = user_interface.ask_index(
        IndexQuestion(
            prompt=f"Which is the last {deck.card_noun}?",
            lowest=first_chosen,
            highest=last_index,
        )
    )
    return deck.narrowed_to(deck.span_between(first_chosen, last_chosen))


def _narrowed_decks(deck: Deck, group: RangeGroup) -> list[Deck]:
    return [deck.narrowed_to(card_range) for card_range in group.ranges]


def _choose_narrowed_deck(
    user_interface: SelectionUserInterface, question: str, decks: Sequence[Deck]
) -> Deck:
    return user_interface.choose(question, decks, _range_label)


def _range_label(deck: Deck) -> str:
    return f"{deck.range_label or 'All'} ({len(deck.cards)} {deck.card_noun}s)"
