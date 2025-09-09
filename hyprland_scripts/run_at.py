#!/usr/bin/env python
"""
run_at.py  START END  COMMAND
Run the given shell command only if the current local time
lies between START and END (inclusive, HH:MM 24-hour clock).

Examples
--------
$ python run_at.py 07:30 08:00 "echo 123"
# executes only when local time is between 07:30 and 08:00
"""

import datetime
import subprocess
import sys


def parse_hhmm(s: str) -> int:
    """Convert 'HH:MM' -> minutes since midnight."""
    try:
        h, m = map(int, s.split(":"))
        if not (0 <= h < 24 and 0 <= m < 60):
            raise ValueError
        return h * 60 + m
    except ValueError:
        sys.exit(f"Invalid time format '{s}'. Use HH:MM (24-hour).")


def inside_window(now: int, start: int, end: int) -> bool:
    """Return True if now is in [start, end], handling midnight wrap."""
    if start <= end:
        return start <= now <= end
    return now >= start or now <= end  # spans midnight


def main(argv: list[str]) -> None:
    if len(argv) < 4:
        sys.exit("Usage: run_at.py HH:MM HH:MM COMMAND")

    start_str, end_str = argv[1], argv[2]
    cmd = " ".join(argv[3:])  # re-join in case command contained spaces

    start_min = parse_hhmm(start_str)
    end_min = parse_hhmm(end_str)

    now = datetime.datetime.now()
    now_min = now.hour * 60 + now.minute

    if inside_window(now_min, start_min, end_min):
        subprocess.run(cmd, shell=True, check=False)  # or check=True if desired
    else:
        print(
            f"Not running '{cmd}' because it's not between "  # pyright: ignore[reportImplicitStringConcatenation]
            f"{start_str} and {end_str}."
        )
        sys.exit(1)


if __name__ == "__main__":
    main(sys.argv)
