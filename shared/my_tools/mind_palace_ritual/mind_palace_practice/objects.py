from dataclasses import dataclass

from mind_palaces.models import MindPalace


@dataclass(frozen=True)
class NumberedObject:
    number: int
    object_name: str
    room_name: str


def numbered_objects(mind_palace: MindPalace) -> list[NumberedObject]:
    rooms_and_objects = (
        (room, object_name)
        for room in mind_palace.rooms
        for object_name in room.objects
    )
    return [
        NumberedObject(number=number, object_name=object_name, room_name=room.room_name)
        for number, (room, object_name) in enumerate(rooms_and_objects, start=1)
    ]
