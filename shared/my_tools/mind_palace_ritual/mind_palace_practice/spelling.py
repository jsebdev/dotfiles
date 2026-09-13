def levenshtein_distance(source: str, target: str) -> int:
    previous_row = list(range(len(target) + 1))
    for source_index, source_character in enumerate(source, start=1):
        current_row = [source_index]
        for target_index, target_character in enumerate(target, start=1):
            substitution_cost = 0 if source_character == target_character else 1
            current_row.append(
                min(
                    previous_row[target_index] + 1,
                    current_row[target_index - 1] + 1,
                    previous_row[target_index - 1] + substitution_cost,
                )
            )
        previous_row = current_row
    return previous_row[-1]


def allowed_spelling_slips(expected_answer: str) -> int:
    if len(expected_answer) <= 3:
        return 0
    if len(expected_answer) <= 6:
        return 1
    return 2


def is_spelling_slip(answer: str, expected_answer: str) -> bool:
    return levenshtein_distance(answer, expected_answer) <= allowed_spelling_slips(
        expected_answer
    )
