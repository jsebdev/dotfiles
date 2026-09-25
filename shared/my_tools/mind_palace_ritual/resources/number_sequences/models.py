from dataclasses import dataclass


@dataclass(frozen=True)
class NumberSequence:
    name: str
    whole_part: str
    decimals: str
