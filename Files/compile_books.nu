#!/usr/bin/env nu

# Centralized Pandoc Compilation Helper for Data Science at Nushell Textbooks
# Enforces syntax definitions, skylighting theme, XeLaTeX engine, and the hide_skip.lua filter.

def main [
  --edition(-e): string = "all" # Target edition to compile: "all", "en", "es", or "ubb"
] {
  let targets = if $edition == "all" {
    [
      { src: "DataScienceNushell.md", out: "DataScienceNushell.pdf" },
      { src: "DataScienceNushell.es.md", out: "DataScienceNushell.es.pdf" },
      { src: "DataScienceNushell_ubb.md", out: "DataScienceNushell_ubb.pdf" }
    ]
  } else if $edition == "en" {
    [{ src: "DataScienceNushell.md", out: "DataScienceNushell.pdf" }]
  } else if $edition == "es" {
    [{ src: "DataScienceNushell.es.md", out: "DataScienceNushell.es.pdf" }]
  } else if $edition == "ubb" {
    [{ src: "DataScienceNushell_ubb.md", out: "DataScienceNushell_ubb.pdf" }]
  } else {
    error make { msg: $"Unknown edition: '($edition)'. Use 'all', 'en', 'es', or 'ubb'." }
  }

  let base_dir = ($env.FILE_PWD | path expand)
  cd $base_dir

  for t in $targets {
    print $"Compiling ($t.src) -> ($t.out)..."
    (
      ^pandoc --pdf-engine=xelatex
        --syntax-definition=nu.xml
        --syntax-definition=nushell.xml
        --syntax-highlighting=pandoc_highlight.theme
        --lua-filter=hide_skip.lua
        $t.src -o $t.out
    )
    print $"Successfully compiled ($t.out)!"
  }
}
