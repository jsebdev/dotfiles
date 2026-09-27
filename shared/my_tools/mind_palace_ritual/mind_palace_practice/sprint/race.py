from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum, auto

from .milestones import MilestoneLadder
from .records import SprintEnding, SprintRun


class KeyVerdict(Enum):
    CORRECT = auto()
    MISSED = auto()
    WRONG = auto()
    COMPLETED = auto()


@dataclass(frozen=True)
class Mistake:
    position: int
    typed: str
    expected: str


@dataclass
class Sprint:
    sequence_name: str
    expected: str
    ladder: MilestoneLadder
    distance: int = 0
    splits: dict[int, float] = field(default_factory=dict)
    mistake: Mistake | None = None
    missed_positions: list[int] = field(default_factory=list)
    started_at: float | None = None
    last_correct_at: float | None = None

    def press(self, digit: str, at: float) -> KeyVerdict:
        if self.started_at is None:
            self.started_at = at
        position = self.distance + 1
        expected_digit = self.expected[self.distance]
        if digit != expected_digit:
            self.mistake = Mistake(
                position=position, typed=digit, expected=expected_digit
            )
            if self.was_missed(position):
                return KeyVerdict.WRONG
            self.missed_positions.append(position)
            return KeyVerdict.MISSED
        self.distance += 1
        self.last_correct_at = at
        if self.ladder.is_milestone(self.distance):
            self.splits[self.distance] = at - self.started_at
        if self.distance == len(self.expected):
            return KeyVerdict.COMPLETED
        return KeyVerdict.CORRECT

    def was_missed(self, position: int) -> bool:
        return self.missed_positions[-1:] == [position]

    def finished_run(self, ending: SprintEnding, achieved_at: datetime) -> SprintRun:
        return SprintRun(
            sequence_name=self.sequence_name,
            distance=self.distance,
            seconds=self._elapsed_seconds(),
            splits=tuple(sorted(self.splits.items())),
            misses=len(self.missed_positions),
            ending=ending,
            achieved_at=achieved_at,
        )

    def _elapsed_seconds(self) -> float:
        if self.started_at is None or self.last_correct_at is None:
            return 0.0
        return round(self.last_correct_at - self.started_at, 3)
