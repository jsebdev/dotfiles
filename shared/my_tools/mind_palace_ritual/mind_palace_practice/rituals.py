import random
from dataclasses import dataclass
from typing import Protocol

from .objects import NumberedObject


@dataclass(frozen=True)
class Question:
    prompt: str
    expected_answer: str
    target: NumberedObject

    def accepts(self, answer: str) -> bool:
        return _comparable(answer) == _comparable(self.expected_answer)


def _comparable(answer: str) -> str:
    return " ".join(answer.replace("_", " ").lower().split())


class Ritual(Protocol):
    name: str

    def question_for(self, target: NumberedObject) -> Question: ...


class NumberToObjectRitual:
    name = "Number to object"

    def question_for(self, target: NumberedObject) -> Question:
        return Question(
            prompt=f"Which object is number {target.number}?",
            expected_answer=target.object_name,
            target=target,
        )


class ObjectToNumberRitual:
    name = "Object to number"

    def question_for(self, target: NumberedObject) -> Question:
        return Question(
            prompt=f"Which number is '{target.object_name}'?",
            expected_answer=str(target.number),
            target=target,
        )


@dataclass(frozen=True)
class MixedRitual:
    rituals: list[Ritual]
    name = "Mixed"

    def question_for(self, target: NumberedObject) -> Question:
        return random.choice(self.rituals).question_for(target)


def available_rituals() -> list[Ritual]:
    one_way_rituals: list[Ritual] = [NumberToObjectRitual(), ObjectToNumberRitual()]
    return [*one_way_rituals, MixedRitual(one_way_rituals)]
