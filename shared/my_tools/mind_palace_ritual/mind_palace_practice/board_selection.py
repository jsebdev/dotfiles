from collections.abc import Callable, Sequence
from dataclasses import dataclass

from .cards import Deck
from .mind_palace_decks import available_decks
from .records import Board, BoardKey
from .rituals import Ritual, available_rituals
from .selection import SelectionUserInterface


class EveryOption:
    label = "All"


EVERY_OPTION = EveryOption()


@dataclass(frozen=True)
class BoardChoice:
    key: BoardKey
    base_deck_name: str
    card_noun: str
    range_label: str


def ask_boards_to_show(
    user_interface: SelectionUserInterface, boards: Sequence[Board]
) -> list[Board]:
    choices = _choices_for(boards)
    choices = _narrowed(
        user_interface,
        "Which mind palace do you want to see?",
        choices,
        _base_deck_label,
    )
    choices = _narrowed_by_range(user_interface, choices)
    choices = _narrowed(
        user_interface, "Which ritual do you want to see?", choices, _ritual_label
    )
    return _boards_of(choices, boards)


def _narrowed_by_range(
    user_interface: SelectionUserInterface, choices: Sequence[BoardChoice]
) -> list[BoardChoice]:
    if len({choice.base_deck_name for choice in choices}) > 1:
        return list(choices)
    return _narrowed(
        user_interface, "Which range do you want to see?", choices, _range_label
    )


def _narrowed(
    user_interface: SelectionUserInterface,
    question: str,
    choices: Sequence[BoardChoice],
    label: Callable[[BoardChoice], str],
) -> list[BoardChoice]:
    grouped = _grouped_by_label(choices, label)
    if len(grouped) < 2:
        return list(choices)
    chosen = user_interface.choose(question, [EVERY_OPTION, *grouped], _option_label)
    return list(choices) if chosen is EVERY_OPTION else grouped[chosen]


def _option_label(option: EveryOption | str) -> str:
    return option.label if isinstance(option, EveryOption) else option


def _grouped_by_label(
    choices: Sequence[BoardChoice], label: Callable[[BoardChoice], str]
) -> dict[str, list[BoardChoice]]:
    grouped: dict[str, list[BoardChoice]] = {}
    for choice in choices:
        grouped.setdefault(label(choice), []).append(choice)
    return grouped


def _base_deck_label(choice: BoardChoice) -> str:
    return choice.base_deck_name


def _range_label(choice: BoardChoice) -> str:
    span = choice.range_label or EveryOption.label
    return f"{span} ({choice.key.cards_count} {choice.card_noun}s)"


def _ritual_label(choice: BoardChoice) -> str:
    return choice.key.ritual_name


def _boards_of(choices: Sequence[BoardChoice], boards: Sequence[Board]) -> list[Board]:
    chosen_keys = {choice.key for choice in choices}
    return [board for board in boards if board.key in chosen_keys]


def _choices_for(boards: Sequence[Board]) -> list[BoardChoice]:
    catalog = _catalog_choices()
    return [catalog.get(board.key) or _unknown_choice(board.key) for board in boards]


def _catalog_choices() -> dict[BoardKey, BoardChoice]:
    choices = (
        _catalog_choice(deck, variant, ritual)
        for deck in available_decks()
        for variant in _deck_variants(deck)
        for ritual in available_rituals(deck)
    )
    return {choice.key: choice for choice in choices}


def _deck_variants(deck: Deck) -> list[Deck]:
    narrowed = [
        deck.narrowed_to(card_range)
        for group in deck.range_groups
        for card_range in group.ranges
    ]
    return [deck, *narrowed]


def _catalog_choice(deck: Deck, variant: Deck, ritual: Ritual) -> BoardChoice:
    return BoardChoice(
        key=BoardKey(
            deck_name=variant.name,
            cards_count=len(variant.cards),
            ritual_name=ritual.name,
        ),
        base_deck_name=deck.name,
        card_noun=deck.card_noun,
        range_label=variant.range_label,
    )


def _unknown_choice(board_key: BoardKey) -> BoardChoice:
    return BoardChoice(
        key=board_key,
        base_deck_name=board_key.deck_name,
        card_noun="card",
        range_label="",
    )
