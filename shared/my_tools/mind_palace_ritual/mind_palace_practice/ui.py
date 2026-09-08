from collections.abc import Callable, Sequence
from typing import TypeVar

import questionary

from mind_palaces.models import MindPalace

from .objects import NumberedObject
from .rituals import Question
from .scoreboard import Scoreboard

Option = TypeVar("Option")


class TerminalUserInterface:
    def choose(
        self,
        message: str,
        options: Sequence[Option],
        label: Callable[[Option], str],
    ) -> Option:
        choices = [
            questionary.Choice(title=label(option), value=option) for option in options
        ]
        return questionary.select(message, choices=choices).unsafe_ask()

    def ask_answer(self, question: Question) -> str:
        return questionary.text(question.prompt).unsafe_ask()

    def show_correct_answer(self, target: NumberedObject) -> None:
        print(
            f"  ✅ {target.number}. {target.object_name}, in the {target.room_name}\n"
        )

    def show_wrong_answer(self) -> None:
        print("  ❌ Not right, try again.")

    def show_no_mind_palaces(self) -> None:
        print("No mind palaces found.")

    def show_mind_palace_completed(self, mind_palace: MindPalace) -> None:
        print(f"🏛️  {mind_palace.name} complete.")

    def show_summary(self, scoreboard: Scoreboard) -> None:
        print("Session summary")
        print(f"  Objects practiced: {scoreboard.objects_practiced}")
        print(f"  Correct first try: {scoreboard.correct_on_first_try}")
        print(f"  Wrong attempts:    {scoreboard.wrong_attempts}")
