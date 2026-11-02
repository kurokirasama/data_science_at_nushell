#!/usr/bin/env nu

# Centralized Pandoc Compilation Helper for Data Science at Nushell Textbooks
# Enforces syntax definitions, skylighting theme, XeLaTeX engine, dynamic publication date, and the hide_skip.lua filter.

def get-formatted-dates []: nothing -> record<en: string, es: string> {
  let now = (date now)
  let day = ($now | format date "%d" | into int)
  let month_num = ($now | format date "%m")
  let year = ($now | format date "%Y")
  let spanish_months = {
    "01": "Enero", "02": "Febrero", "03": "Marzo", "04": "Abril",
    "05": "Mayo", "06": "Junio", "07": "Julio", "08": "Agosto",
    "09": "Septiembre", "10": "Octubre", "11": "Noviembre", "12": "Diciembre"
  }
  let month_es = ($spanish_months | get $month_num)
  {
    en: ($now | format date "%B %d, %Y"),
    es: $"($day) ($month_es) ($year)"
  }
}

def update-source-preamble-date [file_path: string, new_date: string] {
  let content = (open --raw $file_path)
  let updated = ($content | str replace --regex '(?m)^date:\s*".*?"' $"date: \"($new_date)\"")
  if $updated != $content {
    $updated | save -f $file_path
    print $"Updated preamble date in ($file_path) -> \"($new_date)\""
  }
}

def main [
  --edition(-e): string = "all" # Target edition to compile: "all", "en", "es", or "ubb"
] {
  let dates = (get-formatted-dates)

  let targets = if $edition == "all" {
    [
      { src: "DataScienceNushell.md", out: "DataScienceNushell.pdf", lang: "en", date: $dates.en },
      { src: "DataScienceNushell.es.md", out: "DataScienceNushell.es.pdf", lang: "es", date: $dates.es },
      { src: "DataScienceNushell_ubb.md", out: "DataScienceNushell_ubb.pdf", lang: "es", date: $dates.es }
    ]
  } else if $edition == "en" {
    [{ src: "DataScienceNushell.md", out: "DataScienceNushell.pdf", lang: "en", date: $dates.en }]
  } else if $edition == "es" {
    [{ src: "DataScienceNushell.es.md", out: "DataScienceNushell.es.pdf", lang: "es", date: $dates.es }]
  } else if $edition == "ubb" {
    [{ src: "DataScienceNushell_ubb.md", out: "DataScienceNushell_ubb.pdf", lang: "es", date: $dates.es }]
  } else {
    error make { msg: $"Unknown edition: '($edition)'. Use 'all', 'en', 'es', or 'ubb'." }
  }

  let base_dir = ($env.FILE_PWD | path expand)
  cd $base_dir

  for t in $targets {
    update-source-preamble-date $t.src $t.date
    print $"Compiling ($t.src) -> ($t.out) with date '($t.date)'..."
    (
      ^pandoc --pdf-engine=xelatex
        --syntax-definition=nu.xml
        --syntax-definition=nushell.xml
        --syntax-highlighting=pandoc_highlight.theme
        --lua-filter=hide_skip.lua
        -M $"date=($t.date)"
        $t.src -o $t.out
    )
    print $"Successfully compiled ($t.out)!"
  }
}
