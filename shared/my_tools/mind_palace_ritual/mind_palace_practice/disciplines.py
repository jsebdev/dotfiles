from typing import Protocol

from .palace_discipline import MindPalaceDiscipline
from .sprint.discipline import DigitSprintDiscipline


class Discipline(Protocol):
    name: str

    def can_practice(self) -> bool: ...

    def practice(self) -> None: ...

    def has_best_times(self) -> bool: ...

    def show_best_times(self) -> None: ...


def available_disciplines() -> list[Discipline]:
    return [MindPalaceDiscipline(), DigitSprintDiscipline()]
