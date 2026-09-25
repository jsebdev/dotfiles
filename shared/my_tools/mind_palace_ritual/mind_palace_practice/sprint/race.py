from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum, auto

from .milestones import MilestoneLadder
from .records import SprintEnding, SprintRun


class KeyVerdict(Enum):
    CORRECT = auto()
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
    started_at: float | None = None
    last_correct_at: float | None = None

    def press(self, digit: str, at: float) -> KeyVerdict:
        if self.started_at is None:
            self.started_at = at
        expected_digit = self.expected[self.distance]
        if digit != expected_digit:
            self.mistake = Mistake(
                position=self.distance + 1, typed=digit, expected=expected_digit
            )
            return KeyVerdict.WRONG
        self.distance += 1
        self.last_correct_at = at
        if self.ladder.is_milestone(self.distance):
            self.splits[self.distance] = at - self.started_at
        if self.distance == len(self.expected):
            return KeyVerdict.COMPLETED
        return KeyVerdict.CORRECT

    def finished_run(self, ending: SprintEnding, achieved_at: datetime) -> SprintRun:
        return SprintRun(
            sequence_name=self.sequence_name,
            distance=self.distance,
            seconds=self._elapsed_seconds(),
            splits=tuple(sorted(self.splits.items())),
            ending=ending,
            achieved_at=achieved_at,
        )

    def _elapsed_seconds(self) -> float:
        if self.started_at is None or self.last_correct_at is None:
            return 0.0
        return round(self.last_correct_at - self.started_at, 3)
