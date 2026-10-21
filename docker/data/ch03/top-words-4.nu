#!/usr/bin/env -S nu --stdin
def main [] {
    $in
    | str lowercase
    | parse --regex "(?P<word>[a-z]{2,})"
    | get word
    | uniq -c
    | sort-by count --reverse
    | first 10
}
