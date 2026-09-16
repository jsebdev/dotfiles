from dataclasses import dataclass


@dataclass(frozen=True)
class NumberQuestion:
    prompt: str
    lowest: int
    highest: int

    def error_for(self, answer: str) -> str:
        number = as_number(answer)
        if number is None:
            return f"'{answer.strip()}' is not a number."
        if not self.lowest <= number <= self.highest:
            return (
                f"That number is out of range, "
                f"choose between {self.lowest} and {self.highest}."
            )
        return ""


def as_number(answer: str) -> int | None:
    try:
        return int(answer)
    except ValueError:
        return None
