from dataclasses import dataclass, field, replace


@dataclass(frozen=True)
class PracticeCard:
    number: str
    name: str
    place: str = ""


@dataclass(frozen=True)
class CardRange:
    label: str
    cards: list[PracticeCard]


@dataclass(frozen=True)
class Deck:
    name: str
    card_noun: str
    completion_icon: str
    cards: list[PracticeCard]
    ranges: list[CardRange] = field(default_factory=list)
    range_label: str = ""

    def narrowed_to(self, card_range: CardRange) -> "Deck":
        return replace(
            self,
            name=f"{self.name} {card_range.label}",
            cards=card_range.cards,
            ranges=[],
            range_label=card_range.label,
        )
