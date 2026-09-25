from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import Protocol, TypeVar

from .records import SprintBoard, SprintBoardKey

Option = TypeVar("Option")


class BoardChooser(Protocol):
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option: ...


@dataclass(frozen=True)
class _BoardOption:
    label: str
    key: SprintBoardKey | None


def ask_boards_to_show(
    chooser: BoardChooser, boards: Sequence[SprintBoard]
) -> list[SprintBoard]:
    sequence_name = _chosen_sequence_name(chooser, boards)
    boards_of_sequence = [
        board for board in boards if board.key.sequence_name == sequence_name
    ]
    return _chosen_boards(chooser, boards_of_sequence)


def _chosen_sequence_name(chooser: BoardChooser, boards: Sequence[SprintBoard]) -> str:
    sequence_names = sorted({board.key.sequence_name for board in boards})
    if len(sequence_names) == 1:
        return sequence_names[0]
    return chooser.choose("Which sequence?", sequence_names, lambda name: name)


def _chosen_boards(
    chooser: BoardChooser, boards: Sequence[SprintBoard]
) -> list[SprintBoard]:
    options = _board_options(boards)
    chosen = chooser.choose("Which board?", options, lambda option: option.label)
    if chosen.key is None:
        return list(boards)
    return [board for board in boards if board.key == chosen.key]


def _board_options(boards: Sequence[SprintBoard]) -> list[_BoardOption]:
    ordered_boards = sorted(boards, key=_board_sort_key)
    return [
        _BoardOption(label="All", key=None),
        *[
            _BoardOption(label=_label_for(board.key), key=board.key)
            for board in ordered_boards
        ],
    ]


def _board_sort_key(board: SprintBoard) -> tuple[int, int]:
    milestone = board.key.milestone
    return (0, 0) if milestone is None else (1, milestone)


def _label_for(board_key: SprintBoardKey) -> str:
    return (
        "Distance" if board_key.milestone is None else f"{board_key.milestone} digits"
    )
