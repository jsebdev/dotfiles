from datetime import datetime
from typing import Protocol

from resources.number_sequences.models import NumberSequence

from .keyboard import KeySource
from .milestones import DIGIT_MILESTONES
from .race import KeyVerdict, Sprint
from .records import SprintEnding, SprintRun


class SprintDisplay(Protocol):
    def show_intro(self, sequence: NumberSequence) -> None: ...

    def show_correct_digit(self, sprint: Sprint) -> None: ...

    def show_mistake(self, sprint: Sprint) -> None: ...


def run_sprint(
    sequence: NumberSequence, keys: KeySource, display: SprintDisplay
) -> SprintRun | None:
    display.show_intro(sequence)
    sprint = Sprint(
        sequence_name=sequence.name,
        expected=sequence.decimals,
        ladder=DIGIT_MILESTONES,
    )
    while True:
        digit, at = keys.read_key()
        if not digit.isdigit():
            continue
        verdict = sprint.press(digit, at)
        if verdict is KeyVerdict.WRONG:
            display.show_mistake(sprint)
            return _finished_run(sprint, SprintEnding.MISTAKE)
        display.show_correct_digit(sprint)
        if verdict is KeyVerdict.COMPLETED:
            return _finished_run(sprint, SprintEnding.COMPLETED)


def _finished_run(sprint: Sprint, ending: SprintEnding) -> SprintRun | None:
    if sprint.distance == 0:
        return None
    return sprint.finished_run(ending, datetime.now())
