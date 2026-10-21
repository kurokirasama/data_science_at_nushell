# =========================================================
# GENERAL CONFIG (Data Science at Nushell — dsin)
# =========================================================
$env.config.show_banner = false
$env.config.ls.clickable_links = false
$env.config.completions.algorithm = "prefix" # fuzzy
$env.config.float_precision = 4

# =========================================================
# TABLE CONFIG
# =========================================================
$env.config.table.show_empty = false
$env.config.table.trim = {
  methodology: "truncating" # wrapping
  wrapping_try_keep_words: true
  truncating_suffix: "❱" # ...
}

# =========================================================
# HOOKS
# =========================================================
$env.config.hooks.display_output = {|| table }
$env.config.hooks.env_change.PWD = [
  { |before, after|
    try { print (ls | sort-by -i type name | grid -ci) }
  }
]

# =========================================================
# ENVIRONMENT VARIABLES
# =========================================================
$env.EDITOR = "ttt"
$env.VISUAL = "ttt"
$env.NU_LIB_DIRS = ["/home/dsin/.config/nushell/nu_modules"]
$env.PATH = ($env.PATH | split row (char esep) | prepend ["/home/dsin/bin", "/usr/local/bin"] | uniq)

# =========================================================
# PROMPT CONFIGURATION
# =========================================================
$env.PROMPT_COMMAND = {||
  [
    (ansi -e { fg: '#00ff00' })
    (char -u f525)
    (char -u e621)
    ($env.PWD | path split | last)
    (ansi reset)
  ]
  | str join
}

$env.PROMPT_COMMAND_RIGHT = {||
  [
    (ansi -e { fg: '#00ff00' })
    (char -u e0b3)
    $"(($env.CMD_DURATION_MS | into float) / 1000 | math round -p 3)s"
    (ansi reset)
  ]
  | str join
}

$env.PROMPT_INDICATOR = {||
  [
    (ansi -e { fg: '#00ff00' })
    $"(char -u e0b1) "
    (ansi reset)
  ]
  | str join
}

# =========================================================
# COURSE MODULES & PLUGINS
# =========================================================
use /home/dsin/.config/nushell/nu_modules/dsin_tools.nu *
use /home/dsin/.config/nushell/nu_modules/custom_l.nu *
plugin use polars
plugin use formats
plugin use gstat
plugin use inc
plugin use query
plugin use file
plugin use plot
plugin use port_extension
