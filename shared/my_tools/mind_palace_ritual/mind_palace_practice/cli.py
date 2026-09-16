import argparse

from .board_selection import ask_boards_to_show
from .clock import SessionClock
from .mind_palace_decks import available_decks
from .record_book import RecordBook
from .records import BoardKey, completed_run
from .scoreboard import Scoreboard
from .selection import PracticeChoice, ask_practice_choice
from .session import practice
from .ui import TerminalUserInterface


def main() -> None:
    user_interface = TerminalUserInterface()
    if _command_line_arguments().best_times:
        _show_best_times(user_interface)
        return
    _practice_session(user_interface)


def _command_line_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Practice your mind palaces.")
    parser.add_argument(
        "--best-times",
        action="store_true",
        help="show recorded best times instead of practicing",
    )
    return parser.parse_args()


def _show_best_times(user_interface: TerminalUserInterface) -> None:
    boards = RecordBook().boards()
    if not boards:
        user_interface.show_no_best_times()
        return
    try:
        chosen_boards = ask_boards_to_show(user_interface, boards)
    except KeyboardInterrupt:
        print()
        return
    user_interface.show_boards(chosen_boards)


def _practice_session(user_interface: TerminalUserInterface) -> None:
    decks = available_decks()
    if not decks:
        user_interface.show_nothing_to_practice()
        return
    try:
        choice = ask_practice_choice(user_interface, decks)
    except KeyboardInterrupt:
        print()
        return
    scoreboard = Scoreboard()
    clock = SessionClock()
    completed = _practice_completed(choice, user_interface, scoreboard)
    if scoreboard.cards_practiced:
        user_interface.show_summary(scoreboard, clock.elapsed)
    if completed and choice.mode.records_best_times:
        user_interface.show_placement(
            RecordBook().place(
                _board_key(choice),
                completed_run(clock.elapsed, scoreboard.wrong_attempts),
            )
        )


def _practice_completed(
    choice: PracticeChoice,
    user_interface: TerminalUserInterface,
    scoreboard: Scoreboard,
) -> bool:
    try:
        practice(
            choice.mode.targets(choice.deck.cards),
            choice.ritual,
            user_interface,
            scoreboard,
        )
    except KeyboardInterrupt:
        print()
        return False
    user_interface.show_deck_completed(choice.deck)
    return True


def _board_key(choice: PracticeChoice) -> BoardKey:
    return BoardKey(
        deck_name=choice.deck.name,
        cards_count=len(choice.deck.cards),
        ritual_name=choice.ritual.name,
    )
