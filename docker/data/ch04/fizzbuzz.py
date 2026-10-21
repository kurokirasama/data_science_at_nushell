#!/usr/bin/env python3
import sys

CYCLE_OF_15 = ["fizzbuzz", None, None, "fizz", None,
               "buzz", "fizz", None, None, "fizz",
               "buzz", None, "fizz", None, None]

def fizz_buzz(n: int) -> str:
    return CYCLE_OF_15[n % 15] or str(n)

if __name__ == "__main__":
    for line in sys.stdin:
        line = line.strip()
        if line:
            print(fizz_buzz(int(line)))
