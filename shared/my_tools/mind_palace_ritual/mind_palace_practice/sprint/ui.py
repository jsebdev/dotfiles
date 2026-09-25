from collections.abc import Callable, Sequence
from dataclasses import dataclass, field
from datetime import timedelta
from typing import TypeVar

from resources.number_sequences.models import NumberSequence

from ..terminal_text import (
    best_times_shown_for,
    in_green,
    in_red,
    ordinal,
    readable_duration,
)
from ..ui import TerminalUserInterface
from .race import Sprint
from .records import (
    SprintBoard,
    SprintBoardKey,
    SprintEnding,
    SprintPlacement,
    SprintPlacements,
    SprintRun,
)

Option = TypeVar("Option")

DIGITS_PER_GROUP = 10
DIGITS_PER_LINE = 50


@dataclass(frozen=True)
class SprintTerminalDisplay:
    chooser: TerminalUserInterface = field(default_factory=TerminalUserInterface)

    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option:
        return self.chooser.choose(message, options, label)

    def show_intro(self, sequence: NumberSequence) -> None:
        print(f"{sequence.name}: {sequence.whole_part}.")
        print("Clock starts on your first digit.")
        print("Ctrl-C quits without recording.")
        print()

    def show_correct_digit(self, sprint: Sprint) -> None:
        position = sprint.distance
        digit = sprint.expected[position - 1]
        print(_leading_separator(position) + digit, end="", flush=True)

    def show_mistake(self, sprint: Sprint) -> None:
        mistake = sprint.mistake
        digits = f"{in_red(mistake.typed)}/{in_green(mistake.expected)}"
        print(_leading_separator(mistake.position) + digits)
        print(
            f"\n✗ Stopped at digit {mistake.position} "
            f"(typed {mistake.typed}, expected {mistake.expected})"
        )

    def show_summary(self, placements: SprintPlacements) -> None:
        run = placements.run
        if run.ending is SprintEnding.COMPLETED:
            print(f"✓ Completed all {run.distance} digits")
        print(
            f"Distance: {run.distance} digits in {readable_duration(run.elapsed)}"
            f"   {_badge(placements.distance_placement)}"
        )
        if run.splits:
            print(f"Splits:   {_splits_line(run, placements)}")

    def show_boards(self, boards: Sequence[SprintBoard]) -> None:
        shown_per_board = best_times_shown_for(len(boards))
        print()
        print("Best times")
        for board in boards:
            print()
            print(_board_title(board.key))
            for position, run in enumerate(board.best_times[:shown_per_board], start=1):
                print(_best_time_row(position, run, board.key))


def _leading_separator(position: int) -> str:
    if position == 1:
        return _line_prefix(position)
    if (position - 1) % DIGITS_PER_LINE == 0:
        return "\n" + _line_prefix(position)
    if (position - 1) % DIGITS_PER_GROUP == 0:
        return " "
    return ""


def _line_prefix(position: int) -> str:
    return f"{position:4} │ "


def _badge(placement: SprintPlacement) -> str:
    if placement.position is None:
        return ""
    if placement.position == 1:
        return "🥇 new best"
    return f"({ordinal(placement.position)})"


def _splits_line(run: SprintRun, placements: SprintPlacements) -> str:
    placements_by_milestone = {
        placement.board_key.milestone: placement
        for placement in placements.milestone_placements
    }
    parts = [
        f"{milestone} → {readable_duration(timedelta(seconds=seconds))} "
        f"{_badge(placements_by_milestone[milestone])}"
        for milestone, seconds in run.splits
    ]
    return "   ".join(parts)


def _board_title(key: SprintBoardKey) -> str:
    if key.milestone is None:
        return f"{key.sequence_name} · Distance"
    return f"{key.sequence_name} · {key.milestone} digits"


def _best_time_row(position: int, run: SprintRun, board_key: SprintBoardKey) -> str:
    value = _row_value(run, board_key.milestone)
    return f"  {position:2}. {value:>11}   {run.distance:5} digits   {run.achieved_on}"


def _row_value(run: SprintRun, milestone: int | None) -> str:
    if milestone is None:
        return readable_duration(run.elapsed)
    return readable_duration(timedelta(seconds=run.split_seconds(milestone)))
