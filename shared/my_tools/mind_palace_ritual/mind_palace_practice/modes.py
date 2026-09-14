import random
from collections.abc import Iterator
from typing import Protocol

from .cards import PracticeCard
from .session import PracticeTargets


class Mode(Protocol):
    name: str
    description: str
    records_best_times: bool

    def targets(self, cards: list[PracticeCard]) -> PracticeTargets: ...


class RandomCardsForever:
    def __init__(self, cards: list[PracticeCard]) -> None:
        self._cards = cards

    def __iter__(self) -> Iterator[PracticeCard]:
        while True:
            yield random.choice(self._cards)

    def put_back(self, card: PracticeCard) -> None:
        pass


class EveryCardOnce:
    def __init__(self, cards: list[PracticeCard]) -> None:
        self._remaining = random.sample(cards, len(cards))

    def __iter__(self) -> Iterator[PracticeCard]:
        while self._remaining:
            yield self._remaining.pop(0)

    def put_back(self, card: PracticeCard) -> None:
        self._remaining.insert(random.randint(0, len(self._remaining)), card)


class EndlessMode:
    name = "Endless"
    description = "random cards until you stop"
    records_best_times = False

    def targets(self, cards: list[PracticeCard]) -> PracticeTargets:
        return RandomCardsForever(cards)


class CompleteMode:
    name = "Complete"
    description = "every card in random order, missed ones come back"
    records_best_times = True

    def targets(self, cards: list[PracticeCard]) -> PracticeTargets:
        return EveryCardOnce(cards)


def available_modes() -> list[Mode]:
    return [CompleteMode(), EndlessMode()]
