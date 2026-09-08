import random
from collections.abc import Iterator
from typing import Protocol

from .objects import NumberedObject


class Mode(Protocol):
    name: str
    description: str

    def targets(self, objects: list[NumberedObject]) -> Iterator[NumberedObject]: ...


class EndlessMode:
    name = "Endless"
    description = "random objects until you stop"

    def targets(self, objects: list[NumberedObject]) -> Iterator[NumberedObject]:
        while True:
            yield random.choice(objects)


class CompleteMode:
    name = "Complete"
    description = "every object once, in random order"

    def targets(self, objects: list[NumberedObject]) -> Iterator[NumberedObject]:
        yield from random.sample(objects, len(objects))


def available_modes() -> list[Mode]:
    return [EndlessMode(), CompleteMode()]
