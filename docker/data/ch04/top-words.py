#!/usr/bin/env python3
import re
import sys
from collections import Counter
from pathlib import Path

def top_words(text, n):
    sw_path = Path("stopwords")
    if sw_path.exists():
        stopwords = set(sw_path.read_text(encoding="utf-8").splitlines())
    else:
        stopwords = set()

    words = re.findall(r"[a-z\x27]{2,}", text.lower())
    words = (w for w in words if w not in stopwords)

    for word, count in Counter(words).most_common(n):
        print(f"{count},{word}")

if __name__ == "__main__":
    text = sys.stdin.read()
    n = int(sys.argv[1]) if len(sys.argv) > 1 else 10
    print("count,word")
    top_words(text, n)
