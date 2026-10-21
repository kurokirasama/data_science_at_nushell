#!/usr/bin/env bash
tr '[:upper:]' '[:lower:]' |
grep -oE "[a-z\']{2,}" |
sort |
grep -Fvwf stopwords |
uniq -c |
sort -nr |
head -n 5
