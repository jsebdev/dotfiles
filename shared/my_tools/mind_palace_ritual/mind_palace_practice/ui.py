from collections.abc import Callable, Sequence
from datetime import timedelta
from typing import TypeVar

import questionary

from .cards import Deck, PracticeCard
from .index_question import IndexQuestion
from .records import Board, BoardKey, Placement, TimedRun
from .rituals import Question
from .scoreboard import Scoreboard
from .terminal_text import (
    best_times_shown_for,
    in_blue,
    in_green,
    ordinal,
    readable_duration,
)

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

    def ask_index(self, question: IndexQuestion) -> int:
        while True:
            answer = questionary.text(question.prompt).unsafe_ask()
            error = question.error_for(answer)
            if not error:
                return int(answer)
            print(f"  ❌ {error}")

    def ask_answer(self, question: Question) -> str:
        return questionary.text(question.prompt).unsafe_ask()

    def show_correct_answer(self, card: PracticeCard) -> None:
        print(f"  ✅ {card.index}. {in_green(card.name)}{_place_of(card)}\n")

    def show_revealed_answer(self, card: PracticeCard) -> None:
        print(
            f"  🙈 The answer was {card.index}. "
            f"{in_green(card.name)}{_place_of(card)}\n"
        )

    def show_wrong_answer(self) -> None:
        print("  ❌ Not right, try again.")

    def show_misspelled_answer(self, expected_answer: str) -> None:
        print(f"  📝 Close enough, but it is spelled '{in_green(expected_answer)}'.")

    def show_no_best_times(self) -> None:
        print("No best times recorded yet.")

    def show_boards(self, boards: Sequence[Board]) -> None:
        shown_per_board = best_times_shown_for(len(boards))
        print()
        print("Best times")
        for board in boards:
            print()
            print(_board_title(board.key))
            for position, run in enumerate(board.best_times[:shown_per_board], start=1):
                print(_best_time_row(position, run, None))

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


def _place_of(card: PracticeCard) -> str:
    return f", in the {in_blue(card.place)}" if card.place else ""


def _placement_headline(placement: Placement) -> str:
    if placement.position is None:
        return "No top ten spot this time."
    if placement.position == 1:
        return "🥇 New best time!"
    return f"🏅 {ordinal(placement.position)} best time."


def _board_title(key: BoardKey) -> str:
    return f"{key.deck_name} · {key.cards_count} cards · {key.ritual_name}"


def _best_time_row(position: int, run: TimedRun, achieved: int | None) -> str:
    row = (
        f"  {position:2}. {readable_duration(run.elapsed):>11}"
        f"   {run.wrong_attempts:2} wrong   {run.achieved_on}"
    )
    return f"{row}   ← this run" if position == achieved else row
