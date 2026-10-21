open --raw alice.txt
| str lowercase
| parse --regex "(?P<word>[a-z]{2,})"
| get word
| uniq -c
| sort-by count --reverse
| first 10
