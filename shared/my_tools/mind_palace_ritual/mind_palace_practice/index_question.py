from dataclasses import dataclass


@dataclass(frozen=True)
class IndexQuestion:
    prompt: str
    lowest: int
    highest: int
    default: int | None = None

    def error_for(self, answer: str) -> str:
        index = self.index_for(answer)
        if index is None:
            return f"'{answer.strip()}' is not an index."
        if not self.lowest <= index <= self.highest:
            return (
                f"That index is out of range, "
                f"choose between {self.lowest} and {self.highest}."
            )
        return ""

    def index_for(self, answer: str) -> int | None:
        if not answer.strip() and self.default is not None:
            return self.default
        return as_index(answer)


def as_index(answer: str) -> int | None:
    try:
        return int(answer)
    except ValueError:
        return None
