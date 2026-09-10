from collections.abc import Callable, Sequence
from datetime import timedelta
from typing import TypeVar

import questionary

from mind_palaces.models import MindPalace

from .objects import NumberedObject
from .records import BoardKey, Placement, TimedRun
from .rituals import Question
from .scoreboard import Scoreboard

Option = TypeVar("Option")


class TerminalUserInterface:
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option:
        choices = [
            questionary.Choice(title=label(option), value=option) for option in options
        ]
        return questionary.select(message, choices=choices).unsafe_ask()

    def ask_answer(self, question: Question) -> str:
        return questionary.text(question.prompt).unsafe_ask()

    def show_correct_answer(self, target: NumberedObject) -> None:
        print(
            f"  ✅ {target.number}. {target.object_name}, in the {target.room_name}\n"
        )

    def show_wrong_answer(self) -> None:
        print("  ❌ Not right, try again.")

    def show_no_mind_palaces(self) -> None:
        print("No mind palaces found.")

    def show_mind_palace_completed(self, mind_palace: MindPalace) -> None:
        print(f"🏛️  {mind_palace.name} complete.")

    def show_summary(self, scoreboard: Scoreboard, elapsed: timedelta) -> None:
        print("Session summary")
        print(f"  Objects practiced: {scoreboard.objects_practiced}")
        print(f"  Correct first try: {scoreboard.correct_on_first_try}")
        print(f"  Wrong attempts:    {scoreboard.wrong_attempts}")
        print(f"  Time practicing:   {readable_duration(elapsed)}")

    def show_placement(self, placement: Placement) -> None:
        print()
        print(_placement_headline(placement))
        print(f"Best times · {_board_title(placement.key)}")
        for position, run in enumerate(placement.best_times, start=1):
            print(_best_time_row(position, run, placement.position))


def readable_duration(elapsed: timedelta) -> str:
    minutes, seconds = divmod(int(elapsed.total_seconds()), 60)
    hours, minutes = divmod(minutes, 60)
    if hours:
        return f"{hours}h {minutes}m {seconds}s"
    if minutes:
        return f"{minutes}m {seconds}s"
    return f"{seconds}s"


def _placement_headline(placement: Placement) -> str:
    if placement.position is None:
        return "No top ten spot this time."
    if placement.position == 1:
        return "🥇 New best time!"
    return f"🏅 {_ordinal(placement.position)} best time."


def _board_title(key: BoardKey) -> str:
    return f"{key.mind_palace_name} · {key.objects_count} objects · {key.ritual_name}"


def _best_time_row(position: int, run: TimedRun, achieved: int | None) -> str:
    row = (
        f"  {position:2}. {readable_duration(run.elapsed):>9}"
        f"   {run.wrong_attempts:2} wrong   {run.achieved_on}"
    )
    return f"{row}   ← this run" if position == achieved else row


def _ordinal(position: int) -> str:
    suffix = {1: "st", 2: "nd", 3: "rd"}.get(position, "th")
    return f"{position}{suffix}"
