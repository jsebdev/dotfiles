from datetime import datetime

import pytest

from mind_palace_practice.sprint.milestones import MilestoneLadder
from mind_palace_practice.sprint.race import KeyVerdict, Sprint
from mind_palace_practice.sprint.records import SprintEnding


def _sprint(expected: str, opening: tuple[int, ...] = (10,), step: int = 100) -> Sprint:
    return Sprint(
        sequence_name="Test",
        expected=expected,
        ladder=MilestoneLadder(opening=opening, step=step),
    )


def test_press_returns_correct_for_matching_digit_before_the_end():
    sprint = _sprint("123")

    assert sprint.press("1", at=0.0) is KeyVerdict.CORRECT


def test_press_returns_completed_on_the_last_digit_of_the_sequence():
    sprint = _sprint("12")
    sprint.press("1", at=0.0)

    assert sprint.press("2", at=1.0) is KeyVerdict.COMPLETED


def test_press_returns_wrong_and_records_mistake_for_mismatched_digit():
    sprint = _sprint("123")
    sprint.press("1", at=0.0)

    verdict = sprint.press("9", at=1.0)

    assert verdict is KeyVerdict.WRONG
    assert sprint.mistake.position == 2
    assert sprint.mistake.typed == "9"
    assert sprint.mistake.expected == "2"


def test_clock_starts_on_the_first_keystroke_not_before():
    sprint = _sprint("1234567890123", opening=(2,), step=100)

    sprint.press("1", at=100.0)
    sprint.press("2", at=100.5)

    assert sprint.splits[2] == pytest.approx(0.5)


def test_finished_run_carries_sequence_name_distance_and_splits():
    sprint = _sprint("12345", opening=(2, 4), step=100)
    sprint.press("1", at=0.0)
    sprint.press("2", at=1.0)
    sprint.press("3", at=2.0)
    sprint.press("4", at=3.0)

    run = sprint.finished_run(SprintEnding.COMPLETED, achieved_at=datetime(2026, 1, 1))

    assert run.sequence_name == "Test"
    assert run.distance == 4
    assert run.splits == ((2, 1.0), (4, 3.0))
    assert run.ending is SprintEnding.COMPLETED


def test_finished_run_reports_zero_distance_and_zero_seconds_on_immediate_mistake():
    sprint = _sprint("123")

    sprint.press("9", at=5.0)
    run = sprint.finished_run(SprintEnding.MISTAKE, achieved_at=datetime(2026, 1, 1))

    assert run.distance == 0
    assert run.seconds == 0.0


def test_finished_run_uses_last_correct_digit_time_not_the_mistake_time():
    sprint = _sprint("123")
    sprint.press("1", at=0.0)
    sprint.press("2", at=1.0)
    sprint.press("9", at=100.0)

    run = sprint.finished_run(SprintEnding.MISTAKE, achieved_at=datetime(2026, 1, 1))

    assert run.seconds == pytest.approx(1.0)
