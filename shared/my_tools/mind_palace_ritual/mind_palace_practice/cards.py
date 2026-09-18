from dataclasses import dataclass, field, replace


@dataclass(frozen=True)
class PracticeCard:
    index: str
    name: str
    place: str = ""


@dataclass(frozen=True)
class CardRange:
    label: str
    cards: list[PracticeCard]


@dataclass(frozen=True)
class RangeGroup:
    name: str
    question: str
    ranges: list[CardRange]


@dataclass(frozen=True)
class Deck:
    name: str
    card_noun: str
    completion_icon: str
    cards: list[PracticeCard]
    range_groups: list[RangeGroup] = field(default_factory=list)
    range_label: str = ""

    @property
    def first_card_index(self) -> int:
        return int(self.cards[0].index)

    @property
    def last_card_index(self) -> int:
        return int(self.cards[-1].index)

    def span_between(self, first_index: int, last_index: int) -> CardRange:
        first_position = first_index - self.first_card_index
        after_last_position = last_index - self.first_card_index + 1
        return CardRange(
            label=f"{self.card_noun}s {first_index} to {last_index}",
            cards=self.cards[first_position:after_last_position],
        )

    def narrowed_to(self, card_range: CardRange) -> "Deck":
        return replace(
            self,
            name=f"{self.name} {card_range.label}",
            cards=card_range.cards,
            range_groups=[],
            range_label=card_range.label,
        )
