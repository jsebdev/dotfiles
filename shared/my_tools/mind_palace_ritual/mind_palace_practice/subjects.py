from dataclasses import dataclass

from major_system.models import MajorSystem
from mind_palaces.models import MindPalace

from .cards import CardRange, Deck, PracticeCard
from .catalog import available_major_systems, available_mind_palaces


@dataclass(frozen=True)
class Subject:
    name: str
    deck_noun: str
    decks: list[Deck]


def available_subjects() -> list[Subject]:
    subjects = [
        Subject(
            name="Mind palaces",
            deck_noun="mind palace",
            decks=[_mind_palace_deck(palace) for palace in available_mind_palaces()],
        ),
        Subject(
            name="Major system",
            deck_noun="major system",
            decks=[_major_system_deck(system) for system in available_major_systems()],
        ),
    ]
    return [subject for subject in subjects if subject.decks]


def _mind_palace_deck(mind_palace: MindPalace) -> Deck:
    rooms_and_objects = (
        (room, object_name)
        for room in mind_palace.rooms
        for object_name in room.objects
    )
    return Deck(
        name=mind_palace.name,
        card_noun="object",
        completion_icon="🏛️",
        cards=[
            PracticeCard(number=str(number), name=object_name, place=room.room_name)
            for number, (room, object_name) in enumerate(rooms_and_objects, start=1)
        ],
    )


def _major_system_deck(major_system: MajorSystem) -> Deck:
    cards = [
        PracticeCard(number=number, name=word)
        for number, word in sorted(major_system.words.items())
    ]
    return Deck(
        name=major_system.name,
        card_noun="word",
        completion_icon="🔢",
        cards=cards,
        ranges=_leading_digit_ranges(cards),
    )


def _leading_digit_ranges(cards: list[PracticeCard]) -> list[CardRange]:
    leading_digits = sorted({card.number[0] for card in cards})
    return [
        CardRange(
            label=_range_label(leading_digit, cards),
            cards=[card for card in cards if card.number.startswith(leading_digit)],
        )
        for leading_digit in leading_digits
    ]


def _range_label(leading_digit: str, cards: list[PracticeCard]) -> str:
    hidden_digits = len(cards[0].number) - 1
    return f"{leading_digit}{'x' * hidden_digits}"
