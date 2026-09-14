from dataclasses import dataclass, field

from .record_files import RecordFiles
from .records import BEST_TIMES_KEPT, BoardKey, Placement, TimedRun, ranked


@dataclass(frozen=True)
class RecordBook:
    files: RecordFiles = field(default_factory=RecordFiles)

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


def _position_of(run: TimedRun, best_times: list[TimedRun]) -> int | None:
    return best_times.index(run) + 1 if run in best_times else None
