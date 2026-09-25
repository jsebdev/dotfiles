from datetime import timedelta

from .records import BEST_TIMES_KEPT, BEST_TIMES_PREVIEWED

BLUE = "\033[38;5;75m"
GREEN = "\033[38;5;114m"
RED = "\033[38;5;203m"
RESET_COLOR = "\033[0m"


def in_color(text: str, color: str) -> str:
    return f"{color}{text}{RESET_COLOR}"


def in_blue(text: str) -> str:
    return in_color(text, BLUE)


def in_green(text: str) -> str:
    return in_color(text, GREEN)


def in_red(text: str) -> str:
    return in_color(text, RED)


def readable_duration(elapsed: timedelta) -> str:
    seconds, milliseconds = divmod(round(elapsed.total_seconds() * 1000), 1000)
    minutes, seconds = divmod(seconds, 60)
    hours, minutes = divmod(minutes, 60)
    precise_seconds = f"{seconds}.{milliseconds:03d}s"
    if hours:
        return f"{hours}h {minutes}m {precise_seconds}"
    if minutes:
        return f"{minutes}m {precise_seconds}"
    return precise_seconds


def ordinal(position: int) -> str:
    suffix = {1: "st", 2: "nd", 3: "rd"}.get(position, "th")
    return f"{position}{suffix}"


def best_times_shown_for(board_count: int) -> int:
    return BEST_TIMES_KEPT if board_count == 1 else BEST_TIMES_PREVIEWED
