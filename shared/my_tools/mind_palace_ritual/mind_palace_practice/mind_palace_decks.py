from itertools import accumulate

from resources.mind_palaces.models import MindPalace, Room

from .cards import CardRange, Deck, PracticeCard, RangeGroup
from .catalog import available_mind_palaces


def available_decks() -> list[Deck]:
    return [_mind_palace_deck(palace) for palace in available_mind_palaces()]


def _mind_palace_deck(mind_palace: MindPalace) -> Deck:
    rooms_and_objects = (
        (room, object_name)
        for room in mind_palace.rooms
        for object_name in room.objects
    )
    cards = [
        PracticeCard(index=str(index), name=object_name, place=room.room_name)
        for index, (room, object_name) in enumerate(rooms_and_objects)
    ]
    return Deck(
        name=mind_palace.name,
        card_noun="object",
        completion_icon="🏛️",
        cards=cards,
        range_groups=_room_groups(mind_palace.rooms, cards),
    )


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
