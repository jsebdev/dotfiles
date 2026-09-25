from datetime import datetime

from mind_palace_practice.sprint.record_book import SprintRecordBook
from mind_palace_practice.sprint.record_files import SprintRecordFiles
from mind_palace_practice.sprint.records import SprintBoardKey, SprintEnding, SprintRun


def _run(distance, seconds, splits, achieved_at):
    return SprintRun(
        sequence_name="Euler's number",
        distance=distance,
        seconds=seconds,
        splits=tuple(sorted(splits.items())),
        ending=SprintEnding.MISTAKE,
        achieved_at=achieved_at,
    )


def test_place_reports_first_position_for_the_only_recorded_run(tmp_path):
    book = SprintRecordBook(files=SprintRecordFiles(directory=tmp_path))
    run = _run(15, 5.0, {10: 4.0}, datetime(2026, 1, 1))

    placements = book.place(run)

    assert placements.distance_placement.position == 1
    assert len(placements.milestone_placements) == 1
    assert placements.milestone_placements[0].board_key.milestone == 10
    assert placements.milestone_placements[0].position == 1


def test_place_persists_the_run_so_it_is_returned_by_boards(tmp_path):
    book = SprintRecordBook(files=SprintRecordFiles(directory=tmp_path))
    run = _run(15, 5.0, {10: 4.0}, datetime(2026, 1, 1))

    book.place(run)
    boards = book.boards()

    distance_board = next(
        board
        for board in boards
        if board.key == SprintBoardKey(sequence_name="Euler's number")
    )
    assert run in distance_board.best_times


def test_place_drops_the_run_that_falls_out_of_the_only_board_it_belonged_to(tmp_path):
    book = SprintRecordBook(files=SprintRecordFiles(directory=tmp_path))
    for day in range(1, 11):
        book.place(_run(5, float(100 - day), {}, datetime(2026, 1, day)))
    weakest_before = book.boards()[0].best_times[-1]

    placements = book.place(_run(5, 1.0, {}, datetime(2026, 2, 1)))

    remaining = {run.achieved_at for run in book.boards()[0].best_times}
    assert weakest_before.achieved_at not in remaining
    assert placements.run.achieved_at in remaining


def test_place_reports_no_position_on_a_board_the_run_falls_outside_of(tmp_path):
    book = SprintRecordBook(files=SprintRecordFiles(directory=tmp_path))
    for day in range(1, 11):
        book.place(_run(500, float(50 + day), {10: 20.0}, datetime(2026, 1, day + 1)))

    placements = book.place(_run(50, 90.0, {10: 1.0}, datetime(2026, 2, 1)))

    assert placements.distance_placement.position is None
    assert len(placements.milestone_placements) == 1
    assert placements.milestone_placements[0].position == 1
