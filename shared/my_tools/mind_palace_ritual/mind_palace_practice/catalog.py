import importlib
import pkgutil
from types import ModuleType
from typing import Any

import major_system
import mind_palaces
from major_system.models import MajorSystem
from mind_palaces.models import MindPalace

MIND_PALACE_ATTRIBUTE = "mind_palace"
MAJOR_SYSTEM_ATTRIBUTE = "major_system"


def available_mind_palaces() -> list[MindPalace]:
    palaces = _attribute_of_every_module(mind_palaces, MIND_PALACE_ATTRIBUTE)
    return sorted(palaces, key=lambda palace: palace.name)


def available_major_systems() -> list[MajorSystem]:
    systems = _attribute_of_every_module(major_system, MAJOR_SYSTEM_ATTRIBUTE)
    return sorted(systems, key=lambda system: system.name)


def _attribute_of_every_module(package: ModuleType, attribute_name: str) -> list[Any]:
    return [
        value
        for module_name in _module_names(package)
        if (value := _attribute_in(module_name, attribute_name)) is not None
    ]


def _module_names(package: ModuleType) -> list[str]:
    return [
        f"{package.__name__}.{module.name}"
        for module in pkgutil.iter_modules(package.__path__)
    ]


def _attribute_in(module_name: str, attribute_name: str) -> Any:
    module = importlib.import_module(module_name)
    return getattr(module, attribute_name, None)
