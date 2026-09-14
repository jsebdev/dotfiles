from dataclasses import dataclass, field

from .cards import PracticeCard


@dataclass
class CardResult:
    card: PracticeCard
    wrong_attempts: int

    @property
    def correct_on_first_try(self) -> bool:
        return self.wrong_attempts == 0


@dataclass
class Scoreboard:
    results: list[CardResult] = field(default_factory=list)

    def record(self, card: PracticeCard, wrong_attempts: int) -> None:
        self.results.append(CardResult(card=card, wrong_attempts=wrong_attempts))

    def add_wrong_attempts(self, card: PracticeCard, wrong_attempts: int) -> None:
        self._result_for(card).wrong_attempts += wrong_attempts

    @property
    def cards_practiced(self) -> int:
        return len(self.results)

    @property
    def correct_on_first_try(self) -> int:
        return sum(1 for result in self.results if result.correct_on_first_try)

    @property
    def wrong_attempts(self) -> int:
        return sum(result.wrong_attempts for result in self.results)

    def _result_for(self, card: PracticeCard) -> CardResult:
        return next(result for result in self.results if result.card == card)
