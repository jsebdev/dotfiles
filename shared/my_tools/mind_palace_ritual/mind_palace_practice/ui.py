from collections.abc import Callable, Sequence
from datetime import timedelta
from typing import TypeVar

import questionary

from .cards import Deck, PracticeCard
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

    def show_correct_answer(self, card: PracticeCard) -> None:
        print(f"  ✅ {card.number}. {card.name}{_place_of(card)}\n")

    def show_wrong_answer(self) -> None:
        print("  ❌ Not right, try again.")

    def show_nothing_to_practice(self) -> None:
        print("Nothing to practice yet.")

    def show_deck_completed(self, deck: Deck) -> None:
        print(f"{deck.completion_icon}  {deck.name} complete.")

    def show_summary(self, scoreboard: Scoreboard, elapsed: timedelta) -> None:
        print("Session summary")
        print(f"  Cards practiced:   {scoreboard.cards_practiced}")
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


def _place_of(card: PracticeCard) -> str:
    return f", in the {card.place}" if card.place else ""


def _placement_headline(placement: Placement) -> str:
    if placement.position is None:
        return "No top ten spot this time."
    if placement.position == 1:
        return "🥇 New best time!"
    return f"🏅 {_ordinal(placement.position)} best time."


def _board_title(key: BoardKey) -> str:
    return f"{key.deck_name} · {key.cards_count} cards · {key.ritual_name}"


def _best_time_row(position: int, run: TimedRun, achieved: int | None) -> str:
    row = (
        f"  {position:2}. {readable_duration(run.elapsed):>9}"
        f"   {run.wrong_attempts:2} wrong   {run.achieved_on}"
    )
    return f"{row}   ← this run" if position == achieved else row


def _ordinal(position: int) -> str:
    suffix = {1: "st", 2: "nd", 3: "rd"}.get(position, "th")
    return f"{position}{suffix}"
