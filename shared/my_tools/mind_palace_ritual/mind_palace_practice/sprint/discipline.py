from dataclasses import dataclass, field

from resources.number_sequences.models import NumberSequence

from ..catalog import available_number_sequences
from ..index_question import IndexQuestion
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
            starting_digit = self._chosen_starting_digit(sequence)
            with TerminalKeys() as keys:
                run = run_sprint(sequence, starting_digit, keys, self.display)
        except KeyboardInterrupt:
            print()
            return
        if run is None:
            return
        if starting_digit != 1:
            self.display.show_unscored_summary(run, starting_digit)
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

    def _chosen_starting_digit(self, sequence: NumberSequence) -> int:
        question = IndexQuestion(
            prompt="Start from which digit? (Enter for 1, the only scored start)",
            lowest=1,
            highest=len(sequence.decimals),
            default=1,
        )
        return self.display.ask_index(question)
