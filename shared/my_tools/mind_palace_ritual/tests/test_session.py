from resources.number_sequences.models import NumberSequence

from mind_palace_practice.sprint.records import SprintEnding
from mind_palace_practice.sprint.session import run_sprint


class FakeKeys:
    def __init__(self, keystrokes):
        self._keystrokes = iter(keystrokes)

    def read_key(self):
        return next(self._keystrokes)


class RecordingDisplay:
    def __init__(self):
        self.correct_digits = []
        self.mistakes = []

    def show_intro(self, sequence):
        pass

    def show_correct_digit(self, sprint):
        self.correct_digits.append(sprint.distance)

    def show_mistake(self, sprint):
        self.mistakes.append(sprint.mistake)


def test_run_sprint_ignores_non_digit_keys_including_enter():
    sequence = NumberSequence(name="Test", whole_part="1", decimals="12")
    keys = FakeKeys([("\r", 0.0), ("1", 1.0), ("x", 1.5), ("2", 2.0)])

    run = run_sprint(sequence, keys, RecordingDisplay())

    assert run.distance == 2
    assert run.ending is SprintEnding.COMPLETED


def test_run_sprint_ends_on_first_mistake_without_a_voluntary_stop_key():
    sequence = NumberSequence(name="Test", whole_part="1", decimals="123456")
    keys = FakeKeys([("1", 0.0), ("2", 1.0), ("9", 2.0)])
    display = RecordingDisplay()

    run = run_sprint(sequence, keys, display)

    assert run.distance == 2
    assert run.ending is SprintEnding.MISTAKE
    assert len(display.mistakes) == 1


def test_run_sprint_returns_none_when_the_very_first_keystroke_is_wrong():
    sequence = NumberSequence(name="Test", whole_part="1", decimals="123")
    keys = FakeKeys([("9", 0.0)])

    run = run_sprint(sequence, keys, RecordingDisplay())

    assert run is None
