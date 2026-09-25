from resources import mind_palaces, number_sequences

from mind_palace_practice.catalog import (
    available_mind_palaces,
    available_number_sequences,
    discovered,
)


def test_available_mind_palaces_returns_palaces_sorted_by_name():
    palaces = available_mind_palaces()

    names = [palace.name for palace in palaces]
    assert names == sorted(names)
    assert len(palaces) >= 1


def test_available_number_sequences_returns_sequences_sorted_by_name():
    sequences = available_number_sequences()

    names = [sequence.name for sequence in sequences]
    assert names == sorted(names)
    assert len(sequences) >= 1


def test_discovered_finds_mind_palaces_through_the_generic_attribute_lookup():
    assert discovered(mind_palaces, "mind_palace") == available_mind_palaces()


def test_discovered_finds_number_sequences_through_the_generic_attribute_lookup():
    assert (
        discovered(number_sequences, "number_sequence") == available_number_sequences()
    )
