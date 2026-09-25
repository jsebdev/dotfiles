import importlib
import pkgutil
from types import ModuleType
from typing import Protocol, TypeVar

from resources import mind_palaces, number_sequences
from resources.mind_palaces.models import MindPalace
from resources.number_sequences.models import NumberSequence

MIND_PALACE_ATTRIBUTE = "mind_palace"
NUMBER_SEQUENCE_ATTRIBUTE = "number_sequence"


class Named(Protocol):
    name: str


Resource = TypeVar("Resource", bound=Named)


def available_mind_palaces() -> list[MindPalace]:
    return discovered(mind_palaces, MIND_PALACE_ATTRIBUTE)


def available_number_sequences() -> list[NumberSequence]:
    return discovered(number_sequences, NUMBER_SEQUENCE_ATTRIBUTE)


def discovered(package: ModuleType, attribute: str) -> list[Resource]:
    resources = [
        resource
        for module_name in _module_names(package)
        if (resource := _resource_in(module_name, attribute)) is not None
    ]
    return sorted(resources, key=lambda resource: resource.name)


def _module_names(package: ModuleType) -> list[str]:
    return [
        f"{package.__name__}.{module.name}"
        for module in pkgutil.iter_modules(package.__path__)
    ]


def _resource_in(module_name: str, attribute: str) -> Resource | None:
    module = importlib.import_module(module_name)
    return getattr(module, attribute, None)
