import sys
import termios
import tty
from time import monotonic
from typing import Protocol


class KeySource(Protocol):
    def read_key(self) -> tuple[str, float]: ...


class TerminalKeys:
    def __enter__(self) -> "TerminalKeys":
        self._file_descriptor = sys.stdin.fileno()
        self._saved_attributes = termios.tcgetattr(self._file_descriptor)
        tty.setcbreak(self._file_descriptor)
        return self

    def __exit__(self, exception_type, exception_value, traceback) -> None:
        termios.tcsetattr(
            self._file_descriptor, termios.TCSAFLUSH, self._saved_attributes
        )

    def read_key(self) -> tuple[str, float]:
        key = sys.stdin.read(1)
        return key, monotonic()
