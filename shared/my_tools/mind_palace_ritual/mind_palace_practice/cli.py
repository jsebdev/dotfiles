from .clock import SessionClock
from .records import BoardKey, RecordBook, completed_run
from .scoreboard import Scoreboard
from .selection import PracticeChoice, ask_practice_choice
from .session import practice
from .subjects import available_subjects
from .ui import TerminalUserInterface


def main() -> None:
    user_interface = TerminalUserInterface()
    subjects = available_subjects()
    if not subjects:
        user_interface.show_nothing_to_practice()
        return
    try:
        choice = ask_practice_choice(user_interface, subjects)
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
