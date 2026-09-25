import argparse
from collections.abc import Callable, Sequence
from typing import Protocol, TypeVar

from .disciplines import Discipline, available_disciplines
from .ui import TerminalUserInterface

Option = TypeVar("Option")


class Chooser(Protocol):
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option: ...

    def show_no_best_times(self) -> None: ...

    def show_nothing_to_practice(self) -> None: ...


def main() -> None:
    chooser = TerminalUserInterface()
    disciplines = available_disciplines()
    if _command_line_arguments().best_times:
        _show_best_times(chooser, disciplines)
        return
    _practice_session(chooser, disciplines)


def _command_line_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Practice your mind palaces.")
    parser.add_argument(
        "--best-times",
        action="store_true",
        help="show recorded best times instead of practicing",
    )
    return parser.parse_args()


def _show_best_times(chooser: Chooser, disciplines: list[Discipline]) -> None:
    practicable = [
        discipline for discipline in disciplines if discipline.has_best_times()
    ]
    if not practicable:
        chooser.show_no_best_times()
        return
    try:
        discipline = _chosen_discipline(
            chooser, practicable, "Which best times do you want to see?"
        )
    except KeyboardInterrupt:
        print()
        return
    discipline.show_best_times()


def _practice_session(chooser: Chooser, disciplines: list[Discipline]) -> None:
    practicable = [
        discipline for discipline in disciplines if discipline.can_practice()
    ]
    if not practicable:
        chooser.show_nothing_to_practice()
        return
    try:
        discipline = _chosen_discipline(
            chooser, practicable, "What do you want to practice?"
        )
    except KeyboardInterrupt:
        print()
        return
    discipline.practice()


def _chosen_discipline(
    chooser: Chooser,
    disciplines: list[Discipline],
    question: str,
) -> Discipline:
    if len(disciplines) == 1:
        return disciplines[0]
    return chooser.choose(question, disciplines, lambda discipline: discipline.name)
