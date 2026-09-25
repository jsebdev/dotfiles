import pytest

from mind_palace_practice.sprint.milestones import MilestoneLadder


@pytest.mark.parametrize(
    "distance,expected",
    [
        (0, []),
        (9, []),
        (10, [10]),
        (15, [10]),
        (20, [10, 20]),
        (50, [10, 20, 50]),
        (99, [10, 20, 50]),
        (100, [10, 20, 50, 100]),
        (199, [10, 20, 50, 100]),
        (200, [10, 20, 50, 100, 200]),
        (350, [10, 20, 50, 100, 200, 300]),
    ],
)
def test_milestones_up_to_returns_ladder_reached_by_distance(distance, expected):
    ladder = MilestoneLadder()

    assert ladder.milestones_up_to(distance) == expected


@pytest.mark.parametrize(
    "count,expected",
    [
        (1, False),
        (10, True),
        (15, False),
        (100, True),
        (150, False),
        (200, True),
        (300, True),
        (301, False),
    ],
)
def test_is_milestone_matches_opening_and_step_ladder(count, expected):
    ladder = MilestoneLadder()

    assert ladder.is_milestone(count) is expected
