from datetime import datetime

from mind_palace_practice.sprint.record_files import SprintRecordFiles
from mind_palace_practice.sprint.records import SprintEnding, SprintRun


def _run(sequence_name="Euler's number", achieved_at=datetime(2026, 1, 1)):
    return SprintRun(
        sequence_name=sequence_name,
        distance=237,
        seconds=192.4,
        splits=((10, 4.1), (50, 31.8), (100, 69.0), (200, 158.5)),
        ending=SprintEnding.MISTAKE,
        achieved_at=achieved_at,
    )


def test_add_and_every_record_round_trips_a_sprint_run(tmp_path):
    files = SprintRecordFiles(directory=tmp_path)
    run = _run()

    files.add(run)
    loaded = files.every_record()

    assert len(loaded) == 1
    assert loaded[0].run == run


def test_of_sequence_filters_records_by_sequence_name(tmp_path):
    files = SprintRecordFiles(directory=tmp_path)
    euler_run = _run(sequence_name="Euler's number", achieved_at=datetime(2026, 1, 1))
    pi_run = _run(sequence_name="Pi", achieved_at=datetime(2026, 1, 2))
    files.add(euler_run)
    files.add(pi_run)

    matching = files.of_sequence("Euler's number")

    assert [record.run for record in matching] == [euler_run]


def test_remove_deletes_the_stored_files(tmp_path):
    files = SprintRecordFiles(directory=tmp_path)
    run = _run()
    files.add(run)

    files.remove(files.every_record())

    assert files.every_record() == []
