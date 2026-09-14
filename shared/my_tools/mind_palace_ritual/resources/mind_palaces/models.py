from dataclasses import dataclass


@dataclass
class Room:
    room_name: str
    objects: list[str]
    description: str = ""


@dataclass
class MindPalace:
    name: str
    rooms: list[Room]
