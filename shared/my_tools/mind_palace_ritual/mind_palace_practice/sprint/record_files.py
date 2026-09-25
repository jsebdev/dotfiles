import json
from collections.abc import Iterable
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path

from ..record_files import RECORDS_DIRECTORY, sanitized
from .records import SprintEnding, SprintRun

SPRINT_RECORDS_DIRECTORY = RECORDS_DIRECTORY / "sprints"


@dataclass(frozen=True)
class SprintRecordFile:
    path: Path
    run: SprintRun


@dataclass(frozen=True)
class SprintRecordFiles:
    directory: Path = SPRINT_RECORDS_DIRECTORY

    def every_record(self) -> list[SprintRecordFile]:
        return [_read_record(path) for path in sorted(self.directory.glob("*.json"))]

    def of_sequence(self, sequence_name: str) -> list[SprintRecordFile]:
        return [
            record
            for record in self.every_record()
            if record.run.sequence_name == sequence_name
        ]

    def add(self, run: SprintRun) -> None:
        self.directory.mkdir(parents=True, exist_ok=True)
        destination = self.directory / _file_name(run)
        destination.write_text(json.dumps(_stored(run), indent=2) + "\n")

    def remove(self, records: Iterable[SprintRecordFile]) -> None:
        for record in records:
            record.path.unlink(missing_ok=True)


def _read_record(path: Path) -> SprintRecordFile:
    stored = json.loads(path.read_text())
    return SprintRecordFile(
        path=path,
        run=SprintRun(
            sequence_name=stored["sequence"],
            distance=stored["distance"],
            seconds=stored["seconds"],
            splits=tuple(
                sorted(
                    (int(milestone), seconds)
                    for milestone, seconds in stored["splits"].items()
                )
            ),
            ending=SprintEnding[stored["ending"]],
            achieved_at=datetime.fromisoformat(stored["achieved_at"]),
        ),
    )


def _stored(run: SprintRun) -> dict:
    return {
        "sequence": run.sequence_name,
        "distance": run.distance,
        "seconds": run.seconds,
        "splits": {str(milestone): seconds for milestone, seconds in run.splits},
        "ending": run.ending.name,
        "achieved_at": run.achieved_at.isoformat(),
    }


def _file_name(run: SprintRun) -> str:
    name_parts = [
        sanitized(run.sequence_name),
        f"{run.distance}-digits",
        run.achieved_at.strftime("%Y%m%d-%H%M%S-%f"),
    ]
    return f"{'__'.join(name_parts)}.json"
