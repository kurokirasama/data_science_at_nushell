#!/usr/bin/env nu

# Centralized Pandoc Compilation Helper for Data Science at Nushell Textbooks
# Builds PDF (XeLaTeX), EPUB3, and static HTML5 web books (chunkedhtml)
# while enforcing syntax definitions, skylighting theme, dynamic publication date, and hide_skip.lua.

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

def build-pdf [t: record] {
  print $"Compiling ($t.src) -> ($t.pdf_out) with date '($t.date)'..."
  let crossref_args = if $t.use_crossref {
    [-F pandoc-crossref -M $"figureTitle=($t.fig_title)" -M $"figPrefix=($t.fig_title)" -M linkReferences=true]
  } else {
    []
  }
  (
    ^pandoc --pdf-engine=xelatex
      ...$crossref_args
      --syntax-definition=nu.xml
      --syntax-definition=nushell.xml
      --syntax-highlighting=pandoc_highlight.theme
      --lua-filter=hide_skip.lua
      -M $"date=($t.date)"
      $t.src -o $t.pdf_out
  )
  print $"Successfully compiled ($t.pdf_out)!"
}

def build-epub [t: record] {
  print $"Compiling ($t.src) -> ($t.epub_out) \(EPUB3\)..."
  (
    ^pandoc -t epub3
      -F pandoc-crossref
      --lua-filter=hide_skip.lua
      --syntax-definition=nu.xml
      --syntax-definition=nushell.xml
      --syntax-highlighting=pandoc_highlight.theme
      --number-sections
      --split-level=1
      --toc --toc-depth=2
      --math-method=mathml
      --css=epub.css
      -M $"lang=($t.lang)"
      -M $"figureTitle=($t.fig_title)"
      -M $"figPrefix=($t.fig_title)"
      -M linkReferences=true
      -M $"date=($t.date)"
      $t.src -o $t.epub_out
  )
  print $"Successfully compiled ($t.epub_out)!"
}

def build-web [t: record] {
  print $"Compiling ($t.src) -> ($t.web_out) \(chunkedhtml\)..."
  if ($t.web_out | path exists) {
    rm -rf $t.web_out
  }
  (
    ^pandoc -t chunkedhtml
      --standalone
      -F pandoc-crossref
      --lua-filter=hide_skip.lua
      --lua-filter=web_assets.lua
      --syntax-definition=nu.xml
      --syntax-definition=nushell.xml
      --syntax-highlighting=pandoc_highlight.theme
      --template=web_book.html
      --number-sections
      --split-level=1
      --toc --toc-depth=2
      --math-method=mathml
      --css=$t.web_css
      -M $"lang=($t.lang)"
      -M $"figureTitle=($t.fig_title)"
      -M $"figPrefix=($t.fig_title)"
      -M linkReferences=true
      -M $"image_prefix=($t.img_prefix)"
      -M $"portal_url=($t.portal_url)"
      -M $"portal_label=($t.portal_label)"
      -M $"alt_lang_url=($t.alt_lang_url)"
      -M $"alt_lang_label=($t.alt_lang_label)"
      -M $"pdf_url=($t.pdf_url)"
      -M $"epub_url=($t.epub_url)"
      -M $"js_url=($t.web_js)"
      -M $"toc_heading=($t.toc_heading)"
      -M $"footer_note=($t.footer_note)"
      -M $"date=($t.date)"
      $t.src -o $t.web_out
  )
  print $"Successfully compiled ($t.web_out)/!"
}

def main [
  --edition(-e): string = "all" # Target edition: "all", "en", "es", or "ubb"
  --format(-f): string = "all"  # Output format: "all", "pdf", "epub", or "web"
] {
  if $format not-in ["all", "pdf", "epub", "web"] {
    error make { msg: $"Unknown format: '($format)'. Use 'all', 'pdf', 'epub', or 'web'." }
  }

  let dates = (get-formatted-dates)

  let en_target = {
    id: "en",
    src: "DataScienceNushell.md",
    pdf_out: "DataScienceNushell.pdf",
    epub_out: "DataScienceNushell.epub",
    web_out: "../read",
    lang: "en",
    date: $dates.en,
    fig_title: "Figure",
    use_crossref: true,
    pdf_only: false,
    img_prefix: "../Files/",
    web_css: "../Files/web_book.css",
    web_js: "../Files/web_book.js",
    portal_url: "../",
    portal_label: "Course Portal",
    alt_lang_url: "../es/read/",
    alt_lang_label: "Español",
    pdf_url: "../Files/DataScienceNushell.pdf",
    epub_url: "../Files/DataScienceNushell.epub",
    toc_heading: "Contents",
    footer_note: "Data Science at the Linux Terminal with Nushell"
  }

  let es_target = {
    id: "es",
    src: "DataScienceNushell.es.md",
    pdf_out: "DataScienceNushell.es.pdf",
    epub_out: "DataScienceNushell.es.epub",
    web_out: "../es/read",
    lang: "es",
    date: $dates.es,
    fig_title: "Figura",
    use_crossref: true,
    pdf_only: false,
    img_prefix: "../../Files/",
    web_css: "../../Files/web_book.css",
    web_js: "../../Files/web_book.js",
    portal_url: "../",
    portal_label: "Portal del Curso",
    alt_lang_url: "../../read/",
    alt_lang_label: "English",
    pdf_url: "../../Files/DataScienceNushell.es.pdf",
    epub_url: "../../Files/DataScienceNushell.es.epub",
    toc_heading: "Contenido",
    footer_note: "Ciencia de Datos en la Terminal Linux con Nushell"
  }

  let ubb_target = {
    id: "ubb",
    src: "DataScienceNushell_ubb.md",
    pdf_out: "DataScienceNushell_ubb.pdf",
    epub_out: "",
    web_out: "",
    lang: "es",
    date: $dates.es,
    fig_title: "Figura",
    use_crossref: false,
    pdf_only: true,
    img_prefix: "",
    web_css: "",
    web_js: "",
    portal_url: "",
    portal_label: "",
    alt_lang_url: "",
    alt_lang_label: "",
    pdf_url: "",
    epub_url: "",
    toc_heading: "",
    footer_note: ""
  }

  let targets = if $edition == "all" {
    [$en_target, $es_target, $ubb_target]
  } else if $edition == "en" {
    [$en_target]
  } else if $edition == "es" {
    [$es_target]
  } else if $edition == "ubb" {
    [$ubb_target]
  } else {
    error make { msg: $"Unknown edition: '($edition)'. Use 'all', 'en', 'es', or 'ubb'." }
  }

  let base_dir = ($env.FILE_PWD | path expand)
  cd $base_dir

  for t in $targets {
    if $t.pdf_only and ($format in ["epub", "web"]) {
      print $"Skipping ($format) for UBB edition \(($t.src) is PDF-only\)."
      continue
    }

    update-source-preamble-date $t.src $t.date

    if ($format == "all") or ($format == "pdf") {
      build-pdf $t
    }
    if (not $t.pdf_only) and (($format == "all") or ($format == "epub")) {
      build-epub $t
    }
    if (not $t.pdf_only) and (($format == "all") or ($format == "web")) {
      build-web $t
    }
  }
}
