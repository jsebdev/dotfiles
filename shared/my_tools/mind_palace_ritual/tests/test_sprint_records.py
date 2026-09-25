from datetime import datetime

from mind_palace_practice.records import BEST_TIMES_KEPT
from mind_palace_practice.sprint.records import (
    SprintBoardKey,
    SprintEnding,
    SprintRun,
    board_keys_of,
    kept_runs,
    ranked_for,
    sprint_boards,
)


def _run(distance, seconds, splits, achieved_at, sequence_name="Test"):
    return SprintRun(
        sequence_name=sequence_name,
        distance=distance,
        seconds=seconds,
        splits=tuple(sorted(splits.items())),
        ending=SprintEnding.MISTAKE,
        achieved_at=achieved_at,
    )


def test_board_keys_of_includes_distance_board_and_each_milestone_reached():
    run = _run(25, 10.0, {10: 4.0, 20: 8.0}, datetime(2026, 1, 1))

    assert board_keys_of(run) == [
        SprintBoardKey(sequence_name="Test"),
        SprintBoardKey(sequence_name="Test", milestone=10),
        SprintBoardKey(sequence_name="Test", milestone=20),
    ]


def test_ranked_for_distance_board_orders_by_distance_then_seconds_then_date():
    earlier = _run(15, 5.0, {10: 4.0}, datetime(2026, 1, 1))
    further_along = _run(20, 5.0, {10: 4.0, 20: 5.0}, datetime(2026, 1, 2))
    slower_same_distance = _run(20, 6.0, {10: 4.0, 20: 6.0}, datetime(2026, 1, 3))

    ranked = ranked_for(
        SprintBoardKey(sequence_name="Test"),
        [earlier, further_along, slower_same_distance],
    )

    assert ranked == [further_along, slower_same_distance, earlier]


def test_ranked_for_milestone_board_orders_by_split_time_then_date():
    slow = _run(30, 12.0, {10: 5.0}, datetime(2026, 1, 2))
    fast = _run(30, 10.0, {10: 3.0}, datetime(2026, 1, 1))

    ranked = ranked_for(
        SprintBoardKey(sequence_name="Test", milestone=10), [slow, fast]
    )

    assert ranked == [fast, slow]


def test_sprint_boards_groups_runs_by_sequence_and_milestone():
    run = _run(15, 5.0, {10: 4.0}, datetime(2026, 1, 1))

    boards = sprint_boards([run])

    keys = {board.key for board in boards}
    assert keys == {
        SprintBoardKey(sequence_name="Test"),
        SprintBoardKey(sequence_name="Test", milestone=10),
    }


def test_kept_runs_keeps_run_outside_distance_top_ten_but_inside_milestone_board():
    strong_split_weak_distance = _run(50, 90.0, {10: 1.0}, datetime(2026, 1, 1))
    stronger_distance_runs = [
        _run(500, float(50 + day), {10: 20.0}, datetime(2026, 1, day + 1))
        for day in range(1, 11)
    ]

    kept = kept_runs([strong_split_weak_distance, *stronger_distance_runs])

    assert strong_split_weak_distance in kept
    assert len(kept) == 11


def test_sprint_boards_caps_best_times_at_the_kept_limit():
    runs = [
        _run(day, float(day), {}, datetime(2026, 1, day))
        for day in range(1, BEST_TIMES_KEPT + 5)
    ]

    boards = sprint_boards(runs)

    distance_board = next(board for board in boards if board.key.milestone is None)
    assert len(distance_board.best_times) == BEST_TIMES_KEPT


def test_ranked_for_still_returns_every_matching_run_uncapped():
    runs = [
        _run(day, float(day), {}, datetime(2026, 1, day))
        for day in range(1, BEST_TIMES_KEPT + 5)
    ]

    ranked = ranked_for(SprintBoardKey(sequence_name="Test"), runs)

    assert len(ranked) == len(runs)
