from dataclasses import dataclass, field

from resources.number_sequences.models import NumberSequence

from ..catalog import available_number_sequences
from .board_selection import ask_boards_to_show
from .keyboard import TerminalKeys
from .record_book import SprintRecordBook
from .session import run_sprint
from .ui import SprintTerminalDisplay


@dataclass(frozen=True)
class DigitSprintDiscipline:
    display: SprintTerminalDisplay = field(default_factory=SprintTerminalDisplay)
    name: str = "Digit sprints"

    def can_practice(self) -> bool:
        return bool(available_number_sequences())

    def practice(self) -> None:
        try:
            sequence = self._chosen_sequence()
            with TerminalKeys() as keys:
                run = run_sprint(sequence, keys, self.display)
        except KeyboardInterrupt:
            print()
            return
        if run is None:
            return
        placements = SprintRecordBook().place(run)
        self.display.show_summary(placements)

    def has_best_times(self) -> bool:
        return bool(SprintRecordBook().boards())

    def show_best_times(self) -> None:
        boards = SprintRecordBook().boards()
        try:
            chosen_boards = ask_boards_to_show(self.display, boards)
        except KeyboardInterrupt:
            print()
            return
        self.display.show_boards(chosen_boards)

    def _chosen_sequence(self) -> NumberSequence:
        sequences = available_number_sequences()
        if len(sequences) == 1:
            return sequences[0]
        return self.display.choose(
            "Which sequence?", sequences, lambda sequence: sequence.name
        )
