from dataclasses import dataclass, field

from .board_selection import ask_boards_to_show
from .clock import SessionClock
from .mind_palace_decks import available_decks
from .record_book import RecordBook
from .records import BoardKey, completed_run
from .scoreboard import Scoreboard
from .selection import PracticeChoice, ask_practice_choice
from .session import practice
from .ui import TerminalUserInterface


@dataclass(frozen=True)
class MindPalaceDiscipline:
    user_interface: TerminalUserInterface = field(default_factory=TerminalUserInterface)
    name: str = "Mind palaces"

    def can_practice(self) -> bool:
        return bool(available_decks())

    def practice(self) -> None:
        decks = available_decks()
        try:
            choice = ask_practice_choice(self.user_interface, decks)
        except KeyboardInterrupt:
            print()
            return
        scoreboard = Scoreboard()
        clock = SessionClock()
        completed = self._practice_completed(choice, scoreboard)
        if scoreboard.cards_practiced:
            self.user_interface.show_summary(scoreboard, clock.elapsed)
        if completed and choice.mode.records_best_times:
            self.user_interface.show_placement(
                RecordBook().place(
                    _board_key(choice),
                    completed_run(clock.elapsed, scoreboard.wrong_attempts),
                )
            )

    def has_best_times(self) -> bool:
        return bool(RecordBook().boards())

    def show_best_times(self) -> None:
        boards = RecordBook().boards()
        try:
            chosen_boards = ask_boards_to_show(self.user_interface, boards)
        except KeyboardInterrupt:
            print()
            return
        self.user_interface.show_boards(chosen_boards)

    def _practice_completed(
        self, choice: PracticeChoice, scoreboard: Scoreboard
    ) -> bool:
        try:
            practice(
                choice.mode.targets(choice.deck.cards),
                choice.ritual,
                self.user_interface,
                scoreboard,
            )
        except KeyboardInterrupt:
            print()
            return False
        self.user_interface.show_deck_completed(choice.deck)
        return True


def _board_key(choice: PracticeChoice) -> BoardKey:
    return BoardKey(
        deck_name=choice.deck.name,
        cards_count=len(choice.deck.cards),
        ritual_name=choice.ritual.name,
    )
