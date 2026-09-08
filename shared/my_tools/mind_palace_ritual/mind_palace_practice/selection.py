from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Protocol, TypeVar

from mind_palaces.models import MindPalace

from .modes import Mode, available_modes
from .rituals import Ritual, available_rituals

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
    mind_palace: MindPalace
    ritual: Ritual
    mode: Mode


def ask_practice_choice(
    user_interface: SelectionUserInterface,
    mind_palaces: Sequence[MindPalace],
) -> PracticeChoice:
    return PracticeChoice(
        mind_palace=user_interface.choose(
            "Which mind palace do you want to practice?",
            mind_palaces,
            lambda mind_palace: mind_palace.name,
        ),
        ritual=user_interface.choose(
            "Which ritual do you want to practice?",
            available_rituals(),
            lambda ritual: ritual.name,
        ),
        mode=user_interface.choose(
            "Which mode do you want to play in?",
            available_modes(),
            lambda mode: f"{mode.name} ({mode.description})",
        ),
    )
