from dataclasses import dataclass
from itertools import accumulate

from resources.major_system.models import MajorSystem
from resources.mind_palaces.models import MindPalace, Room

from .cards import CardRange, Deck, PracticeCard, RangeGroup
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
    cards = [
        PracticeCard(number=str(number), name=object_name, place=room.room_name)
        for number, (room, object_name) in enumerate(rooms_and_objects, start=1)
    ]
    return Deck(
        name=mind_palace.name,
        card_noun="object",
        completion_icon="🏛️",
        cards=cards,
        range_groups=_room_groups(mind_palace.rooms, cards),
    )


def _major_system_deck(major_system: MajorSystem) -> Deck:
    cards = sorted(
        (
            PracticeCard(number=number, name=word)
            for number, word in major_system.words.items()
        ),
        key=_position_with_zero_last,
    )
    return Deck(
        name=major_system.name,
        card_noun="word",
        completion_icon="🔢",
        cards=cards,
        range_groups=[
            RangeGroup(
                name="Range",
                question="Which range do you want to practice?",
                ranges=_cumulative_ranges(cards),
            )
        ],
    )


def _position_with_zero_last(card: PracticeCard) -> int:
    return int(card.number) or 10 ** len(card.number)


def _cumulative_ranges(cards: list[PracticeCard]) -> list[CardRange]:
    block_size = 10 ** (len(cards[0].number) - 1)
    return [
        CardRange(
            label=f"{cards[0].number}-{cards[last_index].number}",
            cards=cards[: last_index + 1],
        )
        for last_index in range(block_size - 1, len(cards) - 1, block_size)
    ]


def _room_groups(rooms: list[Room], cards: list[PracticeCard]) -> list[RangeGroup]:
    if len(rooms) < 2:
        return []
    spans = _room_spans(rooms)
    return [
        RangeGroup(
            name="Room",
            question="Which room?",
            ranges=[
                CardRange(label=f"{room.room_name} only", cards=cards[start:end])
                for room, start, end in spans
            ],
        ),
        RangeGroup(
            name="Up to room",
            question="Up to which room?",
            ranges=[
                CardRange(label=f"up to {room.room_name}", cards=cards[:end])
                for room, _, end in spans[:-1]
            ],
        ),
    ]


def _room_spans(rooms: list[Room]) -> list[tuple[Room, int, int]]:
    ends = list(accumulate(len(room.objects) for room in rooms))
    starts = [0, *ends[:-1]]
    return list(zip(rooms, starts, ends))
