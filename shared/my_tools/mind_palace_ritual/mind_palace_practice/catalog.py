import importlib
import pkgutil

from resources import mind_palaces
from resources.mind_palaces.models import MindPalace

MIND_PALACE_ATTRIBUTE = "mind_palace"


def available_mind_palaces() -> list[MindPalace]:
    palaces = [
        palace
        for module_name in _module_names()
        if (palace := _mind_palace_in(module_name)) is not None
    ]
    return sorted(palaces, key=lambda palace: palace.name)


def _module_names() -> list[str]:
    return [
        f"{mind_palaces.__name__}.{module.name}"
        for module in pkgutil.iter_modules(mind_palaces.__path__)
    ]


def _mind_palace_in(module_name: str) -> MindPalace | None:
    module = importlib.import_module(module_name)
    return getattr(module, MIND_PALACE_ATTRIBUTE, None)
