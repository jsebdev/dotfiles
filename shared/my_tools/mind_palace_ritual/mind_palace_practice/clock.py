from dataclasses import dataclass, field
from datetime import timedelta
from time import monotonic


@dataclass(frozen=True)
class SessionClock:
    started_at: float = field(default_factory=monotonic)

    @property
    def elapsed(self) -> timedelta:
        return timedelta(seconds=monotonic() - self.started_at)
