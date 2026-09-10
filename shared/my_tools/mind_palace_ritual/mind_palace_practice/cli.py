from .catalog import available_mind_palaces
from .clock import SessionClock
from .objects import NumberedObject, numbered_objects
from .records import BoardKey, RecordBook, completed_run
from .scoreboard import Scoreboard
from .selection import PracticeChoice, ask_practice_choice
from .session import practice
from .ui import TerminalUserInterface


def main() -> None:
    user_interface = TerminalUserInterface()
    mind_palaces = available_mind_palaces()
    if not mind_palaces:
        user_interface.show_no_mind_palaces()
        return
    try:
        choice = ask_practice_choice(user_interface, mind_palaces)
    except KeyboardInterrupt:
        print()
        return
    objects = numbered_objects(choice.mind_palace)
    scoreboard = Scoreboard()
    clock = SessionClock()
    completed = _practice_completed(choice, objects, user_interface, scoreboard)
    if scoreboard.objects_practiced:
        user_interface.show_summary(scoreboard, clock.elapsed)
    if completed and choice.mode.records_best_times:
        user_interface.show_placement(
            RecordBook().place(
                _board_key(choice, objects),
                completed_run(clock.elapsed, scoreboard.wrong_attempts),
            )
        )


def _practice_completed(
    choice: PracticeChoice,
    objects: list[NumberedObject],
    user_interface: TerminalUserInterface,
    scoreboard: Scoreboard,
) -> bool:
    try:
        practice(
            choice.mode.targets(objects), choice.ritual, user_interface, scoreboard
        )
    except KeyboardInterrupt:
        print()
        return False
    user_interface.show_mind_palace_completed(choice.mind_palace)
    return True


def _board_key(choice: PracticeChoice, objects: list[NumberedObject]) -> BoardKey:
    return BoardKey(
        mind_palace_name=choice.mind_palace.name,
        objects_count=len(objects),
        ritual_name=choice.ritual.name,
    )
