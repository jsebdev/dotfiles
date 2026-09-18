from dataclasses import dataclass


@dataclass(frozen=True)
class IndexQuestion:
    prompt: str
    lowest: int
    highest: int

    def error_for(self, answer: str) -> str:
        index = as_index(answer)
        if index is None:
            return f"'{answer.strip()}' is not an index."
        if not self.lowest <= index <= self.highest:
            return (
                f"That index is out of range, "
                f"choose between {self.lowest} and {self.highest}."
            )
        return ""


def as_index(answer: str) -> int | None:
    try:
        return int(answer)
    except ValueError:
        return None
