from collections import defaultdict
from dataclasses import dataclass, field

from .record_files import RecordFiles
from .records import BEST_TIMES_KEPT, Board, BoardKey, Placement, TimedRun, ranked


@dataclass(frozen=True)
class RecordBook:
    files: RecordFiles = field(default_factory=RecordFiles)

    def boards(self) -> list[Board]:
        runs_of_board: dict[BoardKey, list[TimedRun]] = defaultdict(list)
        for record in self.files.every_record():
            runs_of_board[record.board_key].append(record.run)
        return sorted(
            (
                Board(key=board_key, best_times=ranked(runs))
                for board_key, runs in runs_of_board.items()
            ),
            key=_board_order,
        )

    def place(self, board_key: BoardKey, run: TimedRun) -> Placement:
        stored_records = self.files.of_board(board_key)
        best_times = ranked([record.run for record in stored_records] + [run])[
            :BEST_TIMES_KEPT
        ]
        if run in best_times:
            self.files.add(board_key, run)
        self.files.remove(
            record for record in stored_records if record.run not in best_times
        )
        return Placement(
            key=board_key,
            best_times=best_times,
            position=_position_of(run, best_times),
        )


def _board_order(board: Board) -> tuple[str, int, str]:
    return (board.key.deck_name, board.key.cards_count, board.key.ritual_name)


def _position_of(run: TimedRun, best_times: list[TimedRun]) -> int | None:
    return best_times.index(run) + 1 if run in best_times else None
