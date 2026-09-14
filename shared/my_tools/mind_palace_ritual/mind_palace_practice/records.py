from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime, timedelta

BEST_TIMES_KEPT = 10


@dataclass(frozen=True)
class BoardKey:
    deck_name: str
    cards_count: int
    ritual_name: str


@dataclass(frozen=True)
class TimedRun:
    seconds: float
    wrong_attempts: int
    achieved_at: datetime

    @property
    def elapsed(self) -> timedelta:
        return timedelta(seconds=self.seconds)

    @property
    def achieved_on(self) -> str:
        return self.achieved_at.date().isoformat()


@dataclass(frozen=True)
class Placement:
    key: BoardKey
    best_times: list[TimedRun]
    position: int | None


def completed_run(elapsed: timedelta, wrong_attempts: int) -> TimedRun:
    return TimedRun(
        seconds=round(elapsed.total_seconds(), 1),
        wrong_attempts=wrong_attempts,
        achieved_at=datetime.now(),
    )


def ranked(runs: Iterable[TimedRun]) -> list[TimedRun]:
    return sorted(runs, key=lambda run: (run.seconds, run.achieved_at))
