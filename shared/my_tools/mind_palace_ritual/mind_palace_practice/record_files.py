import json
import re
from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from .records import BoardKey, TimedRun

RECORDS_DIRECTORY = Path(__file__).resolve().parent.parent / "practice_records"


@dataclass(frozen=True)
class RecordFile:
    path: Path
    board_key: BoardKey
    run: TimedRun


@dataclass(frozen=True)
class RecordFiles:
    directory: Path = RECORDS_DIRECTORY

    def of_board(self, board_key: BoardKey) -> list[RecordFile]:
        records = (_read_record(path) for path in sorted(self.directory.glob("*.json")))
        return [record for record in records if record.board_key == board_key]

    def add(self, board_key: BoardKey, run: TimedRun) -> None:
        self.directory.mkdir(parents=True, exist_ok=True)
        destination = self.directory / _file_name(board_key, run)
        destination.write_text(json.dumps(_stored(board_key, run), indent=2) + "\n")

    def remove(self, records: Iterable[RecordFile]) -> None:
        for record in records:
            record.path.unlink(missing_ok=True)


def _read_record(path: Path) -> RecordFile:
    stored = json.loads(path.read_text())
    return RecordFile(
        path=path,
        board_key=BoardKey(
            deck_name=stored["deck"],
            cards_count=stored["cards"],
            ritual_name=stored["ritual"],
        ),
        run=TimedRun(
            seconds=stored["seconds"],
            wrong_attempts=stored["wrong_attempts"],
            achieved_at=datetime.fromisoformat(stored["achieved_at"]),
        ),
    )


def _stored(board_key: BoardKey, run: TimedRun) -> dict:
    return {
        "deck": board_key.deck_name,
        "cards": board_key.cards_count,
        "ritual": board_key.ritual_name,
        "seconds": run.seconds,
        "wrong_attempts": run.wrong_attempts,
        "achieved_at": run.achieved_at.isoformat(),
    }


def _file_name(board_key: BoardKey, run: TimedRun) -> str:
    name_parts = [
        _sanitized(board_key.deck_name),
        f"{board_key.cards_count}-cards",
        _sanitized(board_key.ritual_name),
        run.achieved_at.strftime("%Y%m%d-%H%M%S-%f"),
    ]
    return f"{'__'.join(name_parts)}.json"


def _sanitized(text: str) -> str:
    return re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
