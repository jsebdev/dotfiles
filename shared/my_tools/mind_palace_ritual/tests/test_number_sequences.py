from decimal import Decimal, getcontext

from mind_palace_practice.catalog import available_number_sequences
from resources.number_sequences.euler import number_sequence as euler_sequence


def _independently_computed_e_decimals(count: int) -> str:
    getcontext().prec = count + 100
    total = Decimal(0)
    term = Decimal(1)
    threshold = Decimal(10) ** -(count + 90)
    term_index = 0
    while term >= threshold:
        total += term
        term_index += 1
        term /= term_index
    _, _, decimals = str(total).partition(".")
    return decimals[:count]


def test_euler_number_sequence_has_ten_thousand_decimal_digits():
    assert len(euler_sequence.decimals) == 10000


def test_euler_number_sequence_only_contains_digits():
    assert euler_sequence.decimals.isdigit()


def test_euler_number_sequence_whole_part_is_two():
    assert euler_sequence.whole_part == "2"


def test_euler_number_sequence_matches_an_independent_computation_of_e():
    assert euler_sequence.decimals[:200] == _independently_computed_e_decimals(200)


def test_available_number_sequences_discovers_euler():
    sequences = available_number_sequences()

    assert any(sequence.name == "Euler's number" for sequence in sequences)
