from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime, timedelta
from enum import Enum, auto

from ..records import BEST_TIMES_KEPT


class SprintEnding(Enum):
    MISTAKE = auto()
    COMPLETED = auto()


@dataclass(frozen=True)
class SprintRun:
    sequence_name: str
    distance: int
    seconds: float
    splits: tuple[tuple[int, float], ...]
    ending: SprintEnding
    achieved_at: datetime

    @property
    def elapsed(self) -> timedelta:
        return timedelta(seconds=self.seconds)

    @property
    def achieved_on(self) -> str:
        return self.achieved_at.date().isoformat()

    @property
    def milestones_reached(self) -> list[int]:
        return [milestone for milestone, _ in self.splits]

    def split_seconds(self, milestone: int) -> float:
        return dict(self.splits)[milestone]


@dataclass(frozen=True)
class SprintBoardKey:
    sequence_name: str
    milestone: int | None = None


@dataclass(frozen=True)
class SprintBoard:
    key: SprintBoardKey
    best_times: list[SprintRun]


@dataclass(frozen=True)
class SprintPlacement:
    board_key: SprintBoardKey
    position: int | None


@dataclass(frozen=True)
class SprintPlacements:
    run: SprintRun
    distance_placement: SprintPlacement
    milestone_placements: list[SprintPlacement]


def board_keys_of(run: SprintRun) -> list[SprintBoardKey]:
    return [
        SprintBoardKey(sequence_name=run.sequence_name),
        *[
            SprintBoardKey(sequence_name=run.sequence_name, milestone=milestone)
            for milestone in run.milestones_reached
        ],
    ]


def ranked_for(board_key: SprintBoardKey, runs: Iterable[SprintRun]) -> list[SprintRun]:
    matching = [run for run in runs if board_key in board_keys_of(run)]
    if board_key.milestone is None:
        return sorted(matching, key=_distance_order)
    return sorted(matching, key=lambda run: _split_order(run, board_key.milestone))


def sprint_boards(runs: Iterable[SprintRun]) -> list[SprintBoard]:
    runs = list(runs)
    keys = {board_key for run in runs for board_key in board_keys_of(run)}
    return sorted(
        (
            SprintBoard(key=key, best_times=ranked_for(key, runs)[:BEST_TIMES_KEPT])
            for key in keys
        ),
        key=_board_order,
    )


def kept_runs(runs: Iterable[SprintRun]) -> set[SprintRun]:
    runs = list(runs)
    keys = {board_key for run in runs for board_key in board_keys_of(run)}
    kept: set[SprintRun] = set()
    for key in keys:
        kept.update(ranked_for(key, runs)[:BEST_TIMES_KEPT])
    return kept


def _distance_order(run: SprintRun) -> tuple[int, float, datetime]:
    return (-run.distance, run.seconds, run.achieved_at)


def _split_order(run: SprintRun, milestone: int) -> tuple[float, datetime]:
    return (run.split_seconds(milestone), run.achieved_at)


def _board_order(board: SprintBoard) -> tuple[str, int]:
    milestone = board.key.milestone
    return (board.key.sequence_name, -1 if milestone is None else milestone)
