import importlib
import pkgutil

import mind_palaces
from mind_palaces.models import MindPalace

MIND_PALACE_ATTRIBUTE = "mind_palace"


def available_mind_palaces() -> list[MindPalace]:
    palaces = [
        palace
        for module_name in _module_names(mind_palaces)
        if (palace := _mind_palace_in(module_name)) is not None
    ]
    return sorted(palaces, key=lambda palace: palace.name)


def _module_names(package) -> list[str]:
    return [
        f"{package.__name__}.{module.name}"
        for module in pkgutil.iter_modules(package.__path__)
    ]


def _mind_palace_in(module_name: str) -> MindPalace | None:
    module = importlib.import_module(module_name)
    return getattr(module, MIND_PALACE_ATTRIBUTE, None)
