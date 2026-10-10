from mind_palace_practice.index_question import IndexQuestion


def test_index_for_returns_the_default_when_the_answer_is_blank():
    question = IndexQuestion(prompt="Which?", lowest=1, highest=10, default=1)

    assert question.index_for("  ") == 1
    assert question.error_for("") == ""


def test_index_for_returns_the_typed_index_even_when_a_default_exists():
    question = IndexQuestion(prompt="Which?", lowest=1, highest=10, default=1)

    assert question.index_for("7") == 7


def test_error_for_rejects_a_blank_answer_when_there_is_no_default():
    question = IndexQuestion(prompt="Which?", lowest=1, highest=10)

    assert question.error_for("") == "'' is not an index."
