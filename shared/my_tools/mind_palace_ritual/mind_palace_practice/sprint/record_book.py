from dataclasses import dataclass, field

from .record_files import SprintRecordFiles
from .records import (
    SprintBoard,
    SprintPlacement,
    SprintPlacements,
    SprintRun,
    board_keys_of,
    kept_runs,
    sprint_boards,
)


@dataclass(frozen=True)
class SprintRecordBook:
    files: SprintRecordFiles = field(default_factory=SprintRecordFiles)

    def boards(self) -> list[SprintBoard]:
        return sprint_boards(record.run for record in self.files.every_record())

    def place(self, run: SprintRun) -> SprintPlacements:
        stored_records = self.files.of_sequence(run.sequence_name)
        all_runs = [record.run for record in stored_records] + [run]
        kept = kept_runs(all_runs)
        if run in kept:
            self.files.add(run)
        self.files.remove(record for record in stored_records if record.run not in kept)
        boards_by_key = {board.key: board for board in sprint_boards(all_runs)}
        placements = [_placement(boards_by_key[key], run) for key in board_keys_of(run)]
        return SprintPlacements(
            run=run,
            distance_placement=placements[0],
            milestone_placements=placements[1:],
        )


def _placement(board: SprintBoard, run: SprintRun) -> SprintPlacement:
    best_times = board.best_times
    position = best_times.index(run) + 1 if run in best_times else None
    return SprintPlacement(board_key=board.key, position=position)
