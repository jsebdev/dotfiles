import json
from dataclasses import asdict, dataclass
from datetime import date, timedelta
from pathlib import Path

BEST_TIMES_KEPT = 10
RECORDS_FILE = Path(__file__).resolve().parent.parent / "practice_records.json"


@dataclass(frozen=True)
class BoardKey:
    deck_name: str
    cards_count: int
    ritual_name: str


@dataclass(frozen=True)
class TimedRun:
    seconds: float
    wrong_attempts: int
    achieved_on: str

    @property
    def elapsed(self) -> timedelta:
        return timedelta(seconds=self.seconds)


@dataclass(frozen=True)
class Placement:
    key: BoardKey
    best_times: list[TimedRun]
    position: int | None


Boards = dict[BoardKey, list[TimedRun]]


def completed_run(elapsed: timedelta, wrong_attempts: int) -> TimedRun:
    return TimedRun(
        seconds=round(elapsed.total_seconds(), 1),
        wrong_attempts=wrong_attempts,
        achieved_on=date.today().isoformat(),
    )


@dataclass(frozen=True)
class RecordBook:
    path: Path = RECORDS_FILE

    def place(self, key: BoardKey, run: TimedRun) -> Placement:
        boards = self._load()
        previous_best_times = boards.get(key, [])
        position = _position_of(run, previous_best_times)
        boards[key] = sorted(
            [*previous_best_times, run], key=lambda best: best.seconds
        )[:BEST_TIMES_KEPT]
        self._save(boards)
        return Placement(
            key=key,
            best_times=boards[key],
            position=position if position <= BEST_TIMES_KEPT else None,
        )

    def _load(self) -> Boards:
        if not self.path.exists():
            return {}
        return {
            BoardKey(
                deck_name=board["deck"],
                cards_count=board["cards"],
                ritual_name=board["ritual"],
            ): [TimedRun(**run) for run in board["best_times"]]
            for board in json.loads(self.path.read_text())
        }

    def _save(self, boards: Boards) -> None:
        stored_boards = [
            {
                "deck": key.deck_name,
                "cards": key.cards_count,
                "ritual": key.ritual_name,
                "best_times": [asdict(run) for run in best_times],
            }
            for key, best_times in sorted(boards.items(), key=_board_order)
        ]
        self.path.write_text(json.dumps(stored_boards, indent=2) + "\n")


def _position_of(run: TimedRun, best_times: list[TimedRun]) -> int:
    faster_or_equal = sum(1 for best in best_times if best.seconds <= run.seconds)
    return faster_or_equal + 1


def _board_order(board: tuple[BoardKey, list[TimedRun]]) -> tuple[str, int, str]:
    key, _ = board
    return key.deck_name, key.cards_count, key.ritual_name
