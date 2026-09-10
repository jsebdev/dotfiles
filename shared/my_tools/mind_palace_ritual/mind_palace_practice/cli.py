from .catalog import available_mind_palaces
from .clock import SessionClock
from .objects import numbered_objects
from .scoreboard import Scoreboard
from .selection import ask_practice_choice
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
    scoreboard = Scoreboard()
    clock = SessionClock()
    try:
        practice(
            choice.mode.targets(numbered_objects(choice.mind_palace)),
            choice.ritual,
            user_interface,
            scoreboard,
        )
        user_interface.show_mind_palace_completed(choice.mind_palace)
    except KeyboardInterrupt:
        print()
    if scoreboard.objects_practiced:
        user_interface.show_summary(scoreboard, clock.elapsed)
