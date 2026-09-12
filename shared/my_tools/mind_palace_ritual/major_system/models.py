from dataclasses import dataclass


@dataclass
class MajorSystem:
    name: str
    words: dict[str, str]
