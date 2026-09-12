import random
from collections.abc import Iterator
from typing import Protocol

from .cards import PracticeCard


class Mode(Protocol):
    name: str
    description: str
    records_best_times: bool

    def targets(self, cards: list[PracticeCard]) -> Iterator[PracticeCard]: ...


class EndlessMode:
    name = "Endless"
    description = "random cards until you stop"
    records_best_times = False

    def targets(self, cards: list[PracticeCard]) -> Iterator[PracticeCard]:
        while True:
            yield random.choice(cards)


class CompleteMode:
    name = "Complete"
    description = "every card once, in random order"
    records_best_times = True

    def targets(self, cards: list[PracticeCard]) -> Iterator[PracticeCard]:
        yield from random.sample(cards, len(cards))


def available_modes() -> list[Mode]:
    return [EndlessMode(), CompleteMode()]
