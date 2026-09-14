from collections.abc import Callable, Sequence
from datetime import timedelta
from typing import TypeVar

import questionary

from .cards import Deck, PracticeCard
from .records import BoardKey, Placement, TimedRun
from .rituals import Question
from .scoreboard import Scoreboard

Option = TypeVar("Option")

BLUE = "\033[38;5;75m"
GREEN = "\033[38;5;114m"
RESET_COLOR = "\033[0m"


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
        print(f"  ✅ {card.number}. {_in_green(card.name)}{_place_of(card)}\n")

    def show_revealed_answer(self, card: PracticeCard) -> None:
        print(
            f"  🙈 The answer was {card.number}. "
            f"{_in_green(card.name)}{_place_of(card)}\n"
        )

    def show_wrong_answer(self) -> None:
        print("  ❌ Not right, try again.")

    def show_misspelled_answer(self, expected_answer: str) -> None:
        print(f"  📝 Close enough, but it is spelled '{_in_green(expected_answer)}'.")

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
    seconds, milliseconds = divmod(round(elapsed.total_seconds() * 1000), 1000)
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    precise_seconds = f"{seconds}.{milliseconds:03d}s"
    if hours:
        return f"{hours}h {minutes}m {precise_seconds}"
    if minutes:
        return f"{minutes}m {precise_seconds}"
    return precise_seconds


def _place_of(card: PracticeCard) -> str:
    return f", in the {_in_blue(card.place)}" if card.place else ""


def _in_blue(text: str) -> str:
    return _in_color(text, BLUE)


def _in_green(text: str) -> str:
    return _in_color(text, GREEN)


def _in_color(text: str, color: str) -> str:
    return f"{color}{text}{RESET_COLOR}"


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
        f"  {position:2}. {readable_duration(run.elapsed):>11}"
        f"   {run.wrong_attempts:2} wrong   {run.achieved_on}"
    )
    return f"{row}   ← this run" if position == achieved else row


def _ordinal(position: int) -> str:
    suffix = {1: "st", 2: "nd", 3: "rd"}.get(position, "th")
    return f"{position}{suffix}"
